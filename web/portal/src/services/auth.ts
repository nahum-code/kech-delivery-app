import { clearSession, setSessionTokens } from "@/lib/auth-storage";
import { requestJson } from "./http";

export type MeResponse = {
  id: number;
  phone: string;
  role: string;
  is_active: boolean;
  is_staff?: boolean;
  is_superuser?: boolean;
  created_at: string;
  profile: Record<string, unknown>;
};

export async function loginWithPhone(phone: string, password: string) {
  const response = await requestJson<{
    access: string;
    refresh: string;
    role: string;
    detail?: string;
  }>(
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

  if (role !== "admin" && role !== "sales") {
    clearSession();
    throw new Error("Your account does not have portal access.");
  }

  setSessionTokens(access, refresh, role);
  return { access, refresh, role };
}

export async function fetchMe(): Promise<MeResponse> {
  return requestJson<MeResponse>("/api/v1/auth/me");
}

export async function logoutRemote(): Promise<void> {
  const refresh =
    typeof window !== "undefined"
      ? sessionStorage.getItem("kech_portal_refresh_token")
      : null;

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
