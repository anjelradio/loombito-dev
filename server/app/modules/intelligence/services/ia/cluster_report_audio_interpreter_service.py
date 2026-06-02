import json
from base64 import b64encode

import requests
from fastapi import HTTPException

from app.core.config import settings


class ClusterReportAudioInterpreterService:
    def __init__(self):
        self.api_key = settings.GEMINI_API_KEY
        self.timeout_sec = settings.GEMINI_TIMEOUT_SEC

    def _get_model_chain(self) -> list[str]:
        models = [settings.GEMINI_MODEL_PRIMARY]
        fallbacks = [item.strip() for item in settings.GEMINI_MODEL_FALLBACKS.split(",") if item.strip()]
        models.extend(fallbacks)
        deduped = []
        for model in models:
            if model not in deduped:
                deduped.append(model)
        return deduped

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

    def _normalize(self, payload: dict) -> dict:
        allowed_clusters = {"alto_rendimiento", "rendimiento_medio", "en_riesgo", "all"}
        allowed_columns = {
            "student_last_name",
            "student_first_name",
            "cluster_label",
            "final_score",
            "attendance_rate",
            "present_count",
            "absence_count",
            "license_count",
            "total_sessions",
        }

        cluster_label = payload.get("cluster_label")
        if not isinstance(cluster_label, str) or cluster_label not in allowed_clusters:
            cluster_label = "alto_rendimiento"

        columns = payload.get("columns") if isinstance(payload.get("columns"), list) else []
        columns = [item for item in columns if isinstance(item, str) and item in allowed_columns]
        if not columns:
            columns = [
                "student_last_name",
                "student_first_name",
                "final_score",
                "absence_count",
                "present_count",
            ]

        return {
            "cluster_label": cluster_label,
            "columns": columns,
            "summary": payload.get("summary") if isinstance(payload.get("summary"), str) else None,
        }

    def parse_to_cluster_report_filters(self, audio_bytes: bytes, mime_type: str) -> dict:
        if not self.api_key:
            raise HTTPException(status_code=500, detail="Falta configurar GEMINI_API_KEY")

        audio_b64 = b64encode(audio_bytes).decode("utf-8")
        prompt = (
            "Eres un parser para reportes escolares. Devuelve SOLO JSON valido sin texto adicional. "
            "Interpreta audio de un docente para generar reporte de clasificacion de rendimiento. "
            "Campos esperados: cluster_label (alto_rendimiento|rendimiento_medio|en_riesgo|all), "
            "columns (lista de: student_last_name, student_first_name, cluster_label, final_score, attendance_rate, present_count, absence_count, license_count, total_sessions), "
            "summary (string|null). "
            "Si menciona mejores alumnos o alto rendimiento usa alto_rendimiento. "
            "Si no especifica columnas, usa columnas basicas de nombre, nota y faltas."
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
                parsed = self._extract_json(raw_text)
                return self._normalize(parsed)
            except Exception as exc:
                errors.append(f"{model}:{type(exc).__name__}")
                continue

        raise HTTPException(status_code=502, detail=f"No se pudo interpretar audio con Gemini ({'; '.join(errors)})")
