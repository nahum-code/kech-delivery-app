import { requestJson } from "./http";

export type PaymentRecord = {
  id: number;
  order: number;
  order_reference: string;
  customer: number;
  customer_phone: string;
  amount: string;
  currency: string;
  chapa_tx_ref: string;
  chapa_reference: string;
  payment_method: string;
  status: string;
  checkout_url: string;
  paid_at: string | null;
  created_at: string;
  updated_at: string;
};

export type PaginatedPayments = {
  count: number;
  next: string | null;
  previous: string | null;
  results: PaymentRecord[];
};

export async function fetchPayments(params?: {
  status?: string;
  search?: string;
  order_id?: number;
  page?: number;
}): Promise<PaginatedPayments> {
  const q = new URLSearchParams();
  if (params?.status) q.set("status", params.status);
  if (params?.search) q.set("search", params.search);
  if (params?.order_id) q.set("order_id", String(params.order_id));
  if (params?.page) q.set("page", String(params.page));
  const suffix = q.toString() ? `?${q.toString()}` : "";
  return requestJson<PaginatedPayments>(`/api/v1/payments/${suffix}`);
}

export async function fetchPayment(id: number): Promise<PaymentRecord> {
  return requestJson<PaymentRecord>(`/api/v1/payments/${id}/`);
}

export function paymentStatusLabel(status: string): string {
  return status.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

export function paymentStatusBadgeClass(status: string): string {
  switch (status) {
    case "success":
      return "bg-green-100 text-green-800 border-green-200";
    case "failed":
    case "cancelled":
      return "bg-red-100 text-red-800 border-red-200";
    case "pending":
      return "bg-amber-100 text-amber-800 border-amber-200";
    default:
      return "bg-gray-100 text-gray-800 border-gray-200";
  }
}
