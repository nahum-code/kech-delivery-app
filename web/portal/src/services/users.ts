import { requestJson } from "@/services/http";

export type AdminUser = {
  user_id: number;
  phone: string;
  name: string | null;
  role: string;
  status: "active" | "inactive" | "suspended";
  created_at: string;
};

export type CreateSalesAgentInput = {
  phone: string;
  password: string;
  name: string;
};

export type CreateSalesAgentResponse = {
  user_id: number;
  phone: string;
  name: string;
  role: string;
};

export async function createSalesAgent(
  payload: CreateSalesAgentInput,
): Promise<CreateSalesAgentResponse> {
  return requestJson<CreateSalesAgentResponse>(
    "/api/v1/auth/create-sales-agent/",
    {
      method: "POST",
      body: JSON.stringify(payload),
    },
  );
}

export async function fetchAdminUsers(search?: string): Promise<AdminUser[]> {
  const q = search?.trim();
  const path =
    q && q.length > 0
      ? `/api/v1/auth/users/?q=${encodeURIComponent(q)}`
      : "/api/v1/auth/users/";
  return requestJson<AdminUser[]>(path);
}
