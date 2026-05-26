import { clearSession, getAccessToken, getRefreshToken, setSessionTokens, getRole } from "@/lib/auth-storage";

export function getApiBase(): string {
  const base = process.env.NEXT_PUBLIC_API_URL?.trim();
  if (!base) {
    throw new Error(
      "NEXT_PUBLIC_API_URL is not set. Add it to web/portal/.env.local (e.g. NEXT_PUBLIC_API_URL=http://127.0.0.1:8000) then restart npm run dev."
    );
  }
  return base.replace(/\/$/, "");
}

type RequestOptions = {
  requireAuth?: boolean;
  retryOnUnauthorized?: boolean;
};

async function refreshAccessToken(): Promise<boolean> {
  const refresh = getRefreshToken();
  if (!refresh) return false;

  const response = await fetch(`${getApiBase()}/api/v1/auth/token/refresh/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refresh }),
  });

  if (!response.ok) {
    clearSession();
    return false;
  }

  const payload = (await response.json()) as { access?: string; refresh?: string };
  if (!payload.access) {
    clearSession();
    return false;
  }

  const role = getRole() ?? "";
  setSessionTokens(payload.access, payload.refresh ?? refresh, role);
  return true;
}

export class ApiError extends Error {
  readonly status: number;

  constructor(message: string, status: number) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

async function parseErrorMessage(response: Response): Promise<string> {
  const raw = await response.text().catch(() => "");
  if (!raw) {
    return `Request failed (${response.status})`;
  }

  try {
    const payload = JSON.parse(raw) as Record<string, unknown>;
    if (payload.detail) {
      return String(payload.detail);
    }
    if (typeof payload === "object") {
      const firstValue = Object.values(payload)[0];
      if (Array.isArray(firstValue) && firstValue.length > 0) {
        return String(firstValue[0]);
      }
      if (typeof firstValue === "string") {
        return firstValue;
      }
    }
  } catch {
    if (raw.length < 200 && !raw.includes("<html")) {
      return raw;
    }
  }

  return `Request failed (${response.status})`;
}

export async function requestJson<T>(
  path: string,
  init: RequestInit = {},
  options: RequestOptions = {},
): Promise<T> {
  const { requireAuth = true, retryOnUnauthorized = true } = options;
  const token = requireAuth ? getAccessToken() : null;
  if (requireAuth && !token) {
    clearSession();
    throw new Error("Not signed in");
  }
  const headers = new Headers(init.headers || {});
  if (!(init.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }
  if (requireAuth && token) headers.set("Authorization", `Bearer ${token}`);

  const response = await fetch(`${getApiBase()}${path}`, { ...init, headers });
  if (response.status === 401 && requireAuth && retryOnUnauthorized) {
    const refreshed = await refreshAccessToken();
    if (refreshed) {
      return requestJson<T>(path, init, { ...options, retryOnUnauthorized: false });
    }
    throw new Error("Session expired");
  }

  if (!response.ok) {
    const message = await parseErrorMessage(response);
    throw new ApiError(
      response.status === 403
        ? message || "You do not have permission for this action."
        : message,
      response.status,
    );
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

export async function authJson<T>(path: string, init: RequestInit = {}): Promise<T> {
  return requestJson<T>(path, init);
}
