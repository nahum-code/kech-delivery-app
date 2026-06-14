import { getAccessToken } from "@/lib/auth-storage";
import { authJson, getApiBase } from "./http";

export type CustomerSearchResult = {
  id: number;
  phone: string;
  name: string;
};

export type PaginatedCustomers = {
  count: number;
  next: string | null;
  previous: string | null;
  results: CustomerSearchResult[];
};

export async function searchCustomers(q: string): Promise<PaginatedCustomers> {
  const params = new URLSearchParams({ q });
  return authJson<PaginatedCustomers>(`/api/v1/auth/customers/search/?${params.toString()}`);
}

export type CreateCustomerInput = {
  phone: string;
  name: string;
  password: string;
  email?: string;
};

export async function createCustomer(input: CreateCustomerInput): Promise<CustomerSearchResult> {
  const headers = new Headers({ "Content-Type": "application/json" });
  const token = getAccessToken();
  if (token) headers.set("Authorization", `Bearer ${token}`);

  const res = await fetch(`${getApiBase()}/api/v1/auth/register/customer`, {
    method: "POST",
    headers,
    body: JSON.stringify(input),
  });

  const raw = await res.text();
  if (!res.ok) {
    throw new Error(formatRegistrationError(raw, res.status));
  }

  const data = JSON.parse(raw) as { user_id: number; role: string };
  return { id: data.user_id, phone: input.phone, name: input.name };
}

function formatRegistrationError(body: string, status: number): string {
  try {
    const data = JSON.parse(body) as Record<string, unknown>;
    if (typeof data.detail === "string") return data.detail;
    const parts: string[] = [];
    for (const [field, value] of Object.entries(data)) {
      const msg = Array.isArray(value) ? value.join(" ") : String(value);
      parts.push(`${field}: ${msg}`);
    }
    if (parts.length) return parts.join(" • ");
  } catch {
    /* fall through */
  }
  return body || `Request failed (${status})`;
}
