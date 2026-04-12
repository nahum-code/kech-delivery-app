import { clearSession, getAccessToken, getRefreshToken, setSessionTokens } from "./auth-storage";

function apiBase(): string {
  const base = process.env.NEXT_PUBLIC_API_URL;
  if (!base) {
    throw new Error("NEXT_PUBLIC_API_URL is not set (e.g. http://127.0.0.1:8000)");
  }
  return base.replace(/\/$/, "");
}

export type MeResponse = {
  id: number;
  phone: string;
  role: string;
  is_active: boolean;
  created_at: string;
  profile: Record<string, unknown>;
};

export async function loginWithPhone(phone: string, password: string) {
  const res = await fetch(`${apiBase()}/api/v1/auth/token/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone, password }),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const detail =
      typeof data === "object" && data && "detail" in data
        ? String((data as { detail: unknown }).detail)
        : JSON.stringify(data);
    throw new Error(detail || `Login failed (${res.status})`);
  }
  const access = data.access as string;
  const refresh = data.refresh as string;
  setSessionTokens(access, refresh);
  return { access, refresh, role: data.role as string | undefined };
}

export async function fetchMe(retried = false): Promise<MeResponse> {
  const token = getAccessToken();
  if (!token) throw new Error("Not logged in");
  const res = await fetch(`${apiBase()}/api/v1/auth/me`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (res.status === 401) {
    if (retried) {
      clearSession();
      throw new Error("Session expired");
    }
    const refreshed = await tryRefreshAccess();
    if (refreshed) return fetchMe(true);
    clearSession();
    throw new Error("Session expired");
  }
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || `me failed (${res.status})`);
  }
  return res.json() as Promise<MeResponse>;
}

async function tryRefreshAccess(): Promise<boolean> {
  const refresh = getRefreshToken();
  if (!refresh) return false;
  const res = await fetch(`${apiBase()}/api/v1/auth/token/refresh/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refresh }),
  });
  if (!res.ok) return false;
  const data = await res.json();
  const access = data.access as string;
  const newRefresh = (data.refresh as string) || refresh;
  setSessionTokens(access, newRefresh);
  return true;
}

export async function logoutRemote(): Promise<void> {
  const access = getAccessToken();
  const refresh = getRefreshToken();
  if (access && refresh) {
    await fetch(`${apiBase()}/api/v1/auth/logout`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${access}`,
      },
      body: JSON.stringify({ refresh }),
    }).catch(() => undefined);
  }
  clearSession();
}
