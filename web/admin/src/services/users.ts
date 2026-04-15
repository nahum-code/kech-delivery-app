import { requestJson } from "@/services/http";

export type AdminUser = {
  user_id: number;
  phone: string;
  role: string;
  status: "active" | "inactive";
  created_at: string;
};

export type CreateSalesAgentInput = {
  phone: string;
  password: string;
};

export type CreateSalesAgentResponse = {
  user_id: number;
  phone: string;
  role: string;
};

export async function createSalesAgent(payload: CreateSalesAgentInput): Promise<CreateSalesAgentResponse> {
  return requestJson<CreateSalesAgentResponse>(
    "/api/v1/auth/create-sales-agent/",
    {
      method: "POST",
      body: JSON.stringify(payload),
    },
  );
}

export async function fetchAdminUsers(): Promise<AdminUser[]> {
  return requestJson<AdminUser[]>("/api/v1/auth/users/");
}
