import json
from base64 import b64encode
from datetime import datetime

import requests
from fastapi import HTTPException

from app.core.config import settings


class AttendanceAudioInterpreterService:
    def __init__(self):
        self.api_key = settings.GEMINI_API_KEY
        self.timeout_sec = settings.GEMINI_TIMEOUT_SEC

    # Devuelve cadena de modelos en prioridad con fallback.
    def _get_model_chain(self) -> list[str]:
        models = [settings.GEMINI_MODEL_PRIMARY]
        fallbacks = [item.strip() for item in settings.GEMINI_MODEL_FALLBACKS.split(",") if item.strip()]
        models.extend(fallbacks)
        deduped = []
        for model in models:
            if model not in deduped:
                deduped.append(model)
        return deduped

    # Extrae bloque JSON del texto de respuesta del modelo.
    def _extract_json(self, text: str) -> dict:
        normalized = text.strip()
        if normalized.startswith("```"):
            normalized = normalized.strip("`")
            if normalized.startswith("json"):
                normalized = normalized[4:].strip()

        try:
            return json.loads(normalized)
        except json.JSONDecodeError:
            start = normalized.find("{")
            end = normalized.rfind("}")
            if start >= 0 and end > start:
                return json.loads(normalized[start : end + 1])
            raise

    # Normaliza payload de IA a contrato esperado por reportes.
    def _normalize(self, payload: dict) -> dict:
        allowed_columns = {
            "student_last_name",
            "student_first_name",
            "attendance_date",
            "status_name",
            "observation",
        }
        allowed_status = {"all", "presente", "falta", "licencia"}

        columns = payload.get("columns") if isinstance(payload.get("columns"), list) else []
        columns = [item for item in columns if isinstance(item, str) and item in allowed_columns]
        if not columns:
            columns = [
                "student_last_name",
                "student_first_name",
                "attendance_date",
                "status_name",
                "observation",
            ]

        def as_date(value):
            if not value or not isinstance(value, str):
                return None
            try:
                datetime.strptime(value, "%Y-%m-%d")
                return value
            except ValueError:
                return None

        status_filter = payload.get("attendance_status_filter")
        if not isinstance(status_filter, str) or status_filter not in allowed_status:
            status_filter = "all"

        return {
            "mode": "student_specific",
            "student_last_name": payload.get("student_last_name") if isinstance(payload.get("student_last_name"), str) else None,
            "student_first_name": payload.get("student_first_name") if isinstance(payload.get("student_first_name"), str) else None,
            "from_date": as_date(payload.get("from_date")),
            "to_date": as_date(payload.get("to_date")),
            "attendance_status_filter": status_filter,
            "columns": columns,
            "summary": payload.get("summary") if isinstance(payload.get("summary"), str) else None,
        }

    # Solicita a Gemini interpretar audio y devolver filtros JSON de reporte.
    def parse_to_attendance_filters(self, audio_bytes: bytes, mime_type: str) -> dict:
        if not self.api_key:
            raise HTTPException(status_code=500, detail="Falta configurar GEMINI_API_KEY")

        audio_b64 = b64encode(audio_bytes).decode("utf-8")
        prompt = (
            "Eres un parser para reportes escolares. Devuelve SOLO JSON valido sin texto adicional. "
            "Extrae filtros de asistencia para modo student_specific. \n"
            "Campos esperados: student_last_name (string|null), student_first_name (string|null), "
            "from_date (YYYY-MM-DD|null), to_date (YYYY-MM-DD|null), "
            "attendance_status_filter (all|presente|falta|licencia), "
            "columns (lista de: student_last_name, student_first_name, attendance_date, status_name, observation), "
            "summary (string|null).\n"
            "Si no menciona fechas, usa null en ambas. Si no menciona estado, usa all."
        )

        errors = []
        for model in self._get_model_chain():
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={self.api_key}"
            body = {
                "contents": [
                    {
                        "parts": [
                            {"text": prompt},
                            {
                                "inline_data": {
                                    "mime_type": mime_type,
                                    "data": audio_b64,
                                }
                            },
                        ]
                    }
                ]
            }
            try:
                response = requests.post(url, json=body, timeout=self.timeout_sec)
                if response.status_code >= 400:
                    errors.append(f"{model}:{response.status_code}")
                    continue
                data = response.json()
                candidates = data.get("candidates") if isinstance(data, dict) else None
                if not isinstance(candidates, list) or not candidates:
                    errors.append(f"{model}:no_candidates")
                    continue
                parts = candidates[0].get("content", {}).get("parts", [])
                text_parts = [part.get("text") for part in parts if isinstance(part, dict) and isinstance(part.get("text"), str)]
                if not text_parts:
                    errors.append(f"{model}:no_text")
                    continue
                raw_text = "\n".join(text_parts)
                print(f"[Gemini][{model}] raw_response: {raw_text}")
                parsed = self._extract_json(raw_text)
                print(f"[Gemini][{model}] parsed_json: {json.dumps(parsed, ensure_ascii=False)}")
                return self._normalize(parsed)
            except Exception as exc:
                errors.append(f"{model}:{type(exc).__name__}")
                continue

        raise HTTPException(status_code=502, detail=f"No se pudo interpretar audio con Gemini ({'; '.join(errors)})")
