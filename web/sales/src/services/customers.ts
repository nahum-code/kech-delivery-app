import { authJson } from "./http";

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
