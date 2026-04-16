import { clearSession, setSessionTokens } from "@/lib/auth-storage";
import { requestJson } from "./http";

export type MeResponse = {
  id: number;
  phone: string;
  role: string;
  is_active: boolean;
  created_at: string;
  profile: Record<string, unknown>;
};

const ROLE = "admin";

function assertRole(me: MeResponse): void {
  if (me.role !== ROLE) {
    clearSession();
    throw new Error("This account does not have admin access.");
  }
}

export async function loginWithPhone(phone: string, password: string) {
  const response = await requestJson<{ access: string; refresh: string; role: string; detail?: string }>(
    "/api/v1/auth/token/",
    {
      method: "POST",
      body: JSON.stringify({ phone, password }),
    },
    { requireAuth: false, retryOnUnauthorized: false },
  );

  const access = response.access;
  const refresh = response.refresh;
  const role = String(response.role || "");
  if (role !== ROLE) {
    clearSession();
    throw new Error("This account does not have admin access.");
  }

  setSessionTokens(access, refresh);
  return { access, refresh, role };
}

export async function fetchMe(): Promise<MeResponse> {
  const me = await requestJson<MeResponse>("/api/v1/auth/me");
  assertRole(me);
  return me;
}

export async function logoutRemote(): Promise<void> {
  const refresh = typeof window !== "undefined" ? sessionStorage.getItem("kech_admin_refresh_token") : null;

  if (refresh) {
    await requestJson<void>(
      "/api/v1/auth/logout",
      {
        method: "POST",
        body: JSON.stringify({ refresh }),
      },
      { retryOnUnauthorized: false },
    ).catch(() => undefined);
  }

  clearSession();
}
