import type { ZodType } from "zod";

import {
  errorResult,
  serverErrorResult,
} from "@/features/shared/infrastructure/errors/api-error-result";
import type {
  ApiActionResult,
  ApiFileResult,
  ApiResult,
} from "@/features/shared/infrastructure/types/api-resource";

type ApiMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

type RequestConfig = {
  url: string;
  method: ApiMethod;
  token?: string;
  cache?: RequestCache;
  body?: unknown;
};

type JsonRequestConfig<TParsed, TResult> = RequestConfig & {
  fallbackMessage: string;
  responseSchema: ZodType<TParsed>;
  mapData: (data: TParsed) => TResult;
};

type StatusRequestConfig = RequestConfig & {
  fallbackMessage: string;
};

type FileRequestConfig = RequestConfig & {
  fallbackMessage: string;
  defaultFileName: string;
  defaultContentType?: string;
};

function buildHeaders(token?: string): HeadersInit {
  return {
    "Content-Type": "application/json",
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
}

async function request(config: RequestConfig) {
  return fetch(config.url, {
    method: config.method,
    headers: buildHeaders(config.token),
    cache: config.cache,
    ...(config.body !== undefined ? { body: JSON.stringify(config.body) } : {}),
  });
}

export async function apiRequestJson<TParsed, TResult>(
  config: JsonRequestConfig<TParsed, TResult>,
): Promise<ApiResult<TResult>> {
  try {
    const res = await request(config);
    if (!res.ok) {
      return serverErrorResult(res, config.fallbackMessage);
    }

    const responseData = await res.json();
    const parsed = config.responseSchema.safeParse(responseData);
    if (!parsed.success) {
      return errorResult("Error en la respuesta del servidor");
    }

    return {
      ok: true,
      data: config.mapData(parsed.data),
    };
  } catch {
    return errorResult("Error de conexion. Intenta mas tarde.");
  }
}

export async function apiRequestStatus(
  config: StatusRequestConfig,
): Promise<ApiActionResult> {
  try {
    const res = await request(config);
    if (!res.ok) {
      return serverErrorResult(res, config.fallbackMessage);
    }

    return { ok: true };
  } catch {
    return errorResult("Error de conexion. Intenta mas tarde.");
  }
}

export async function apiRequestFile(
  config: FileRequestConfig,
): Promise<ApiFileResult> {
  try {
    const res = await request(config);
    if (!res.ok) {
      return serverErrorResult(res, config.fallbackMessage);
    }

    const blob = await res.blob();
    const disposition = res.headers.get("content-disposition") || "";
    const fileNameMatch = disposition.match(/filename="([^"]+)"/);
    const fileName = fileNameMatch?.[1] ?? config.defaultFileName;
    const contentType =
      res.headers.get("content-type") ||
      config.defaultContentType ||
      "application/octet-stream";

    return {
      ok: true,
      data: {
        fileName,
        contentType,
        blob,
      },
    };
  } catch {
    return errorResult("Error de conexion. Intenta mas tarde.");
  }
}
