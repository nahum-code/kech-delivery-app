import { clearSession, getAccessToken, getRefreshToken, setSessionTokens } from "@/lib/auth-storage";
import { getApiBase } from "./http";

export type MeResponse = {
  id: number;
  phone: string;
  role: string;
  is_active: boolean;
  created_at: string;
  profile: Record<string, unknown>;
};

const ROLE = "sales";

function assertRole(me: MeResponse): void {
  if (me.role !== ROLE) {
    clearSession();
    throw new Error("This account does not have sales access.");
  }
}

export async function loginWithPhone(phone: string, password: string) {
  const res = await fetch(`${getApiBase()}/api/v1/auth/token/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone, password }),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const detail = typeof data === "object" && data && "detail" in data ? String((data as { detail: unknown }).detail) : "Login failed";
    throw new Error(detail);
  }

  const access = data.access as string;
  const refresh = data.refresh as string;
  const role = String(data.role || "");
  if (role !== ROLE) {
    clearSession();
    throw new Error("This account does not have sales access.");
  }

  setSessionTokens(access, refresh);
  return { access, refresh, role };
}

async function tryRefreshAccess(): Promise<boolean> {
  const refresh = getRefreshToken();
  if (!refresh) return false;

  const res = await fetch(`${getApiBase()}/api/v1/auth/token/refresh/`, {
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

export async function fetchMe(retried = false): Promise<MeResponse> {
  const token = getAccessToken();
  if (!token) throw new Error("Not logged in");

  const res = await fetch(`${getApiBase()}/api/v1/auth/me`, {
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
    throw new Error(text || `Profile request failed (${res.status})`);
  }

  const me = (await res.json()) as MeResponse;
  assertRole(me);
  return me;
}

export async function logoutRemote(): Promise<void> {
  const access = getAccessToken();
  const refresh = getRefreshToken();

  if (access && refresh) {
    await fetch(`${getApiBase()}/api/v1/auth/logout`, {
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
