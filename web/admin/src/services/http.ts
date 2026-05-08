import { clearSession, getAccessToken, getRefreshToken, setSessionTokens } from "@/lib/auth-storage";

export function getApiBase(): string {
  const base = process.env.NEXT_PUBLIC_API_URL?.trim();
  if (!base) {
    throw new Error(
      "NEXT_PUBLIC_API_URL is not set. Add it to web/admin/.env.local (e.g. NEXT_PUBLIC_API_URL=http://127.0.0.1:8000) — not backend/.env — then restart npm run dev."
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

  setSessionTokens(payload.access, payload.refresh ?? refresh);
  return true;
}

async function parseErrorMessage(response: Response): Promise<string> {
  const payload = await response.json().catch(() => null) as Record<string, unknown> | null;
  if (payload?.detail) {
    return String(payload.detail);
  }
  if (payload && typeof payload === "object") {
    const firstValue = Object.values(payload)[0];
    if (Array.isArray(firstValue) && firstValue.length > 0) {
      return String(firstValue[0]);
    }
    if (typeof firstValue === "string") {
      return firstValue;
    }
  }
  const bodyText = await response.text().catch(() => "");
  return bodyText || `Request failed (${response.status})`;
}

export async function requestJson<T>(
  path: string,
  init: RequestInit = {},
  options: RequestOptions = {},
): Promise<T> {
  const { requireAuth = true, retryOnUnauthorized = true } = options;
  const token = requireAuth ? getAccessToken() : null;
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
    throw new Error(await parseErrorMessage(response));
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}
