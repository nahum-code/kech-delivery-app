import { authJson } from "./http";

export type OrderRecord = {
  id: number;
  reference: string;
  restaurant: number;
  restaurant_name: string;
  customer_phone: string;
  customer_name: string;
  assigned_driver: number | null;
  assigned_driver_name: string | null;
  status: string;
  payment_status: string;
  subtotal: string;
  delivery_fee: string;
  total_amount: string;
  placed_at: string;
  updated_at: string;
  item_count: number;
};

export type OrderDetail = OrderRecord & {
  customer: number;
  customer_phone: string;
  delivery_address: Record<string, string>;
  customer_note: string;
  assigned_driver: number | null;
  items: Array<{
    id: number;
    menu_item: number;
    item_name: string;
    quantity: number;
    unit_price: string;
    total_price: string;
    image_url: string | null;
  }>;
};

export type PaginatedOrders = {
  count: number;
  next: string | null;
  previous: string | null;
  results: OrderRecord[];
};

export async function fetchOrders(params?: {
  status?: string;
  search?: string;
  assigned?: "true" | "false";
  page?: number;
  page_size?: number;
}): Promise<PaginatedOrders> {
  const q = new URLSearchParams();
  if (params?.status) q.set("status", params.status);
  if (params?.search) q.set("search", params.search);
  if (params?.assigned) q.set("assigned", params.assigned);
  if (params?.page) q.set("page", String(params.page));
  if (params?.page_size) q.set("page_size", String(params.page_size));
  const query = q.toString();
  const path = query ? `/api/v1/orders/?${query}` : "/api/v1/orders/";
  return authJson<PaginatedOrders>(path);
}

/**
 * Walk the paginated endpoint until `next` is null. Uses the DRF max
 * page size (100) to minimise round trips. Same pattern as admin's
 * fetchAllOrders — used by Monitor Orders so the sales agent sees the
 * full set instead of the first 20.
 */
export async function fetchAllOrders(params?: {
  status?: string;
  search?: string;
  assigned?: "true" | "false";
}): Promise<OrderRecord[]> {
  const out: OrderRecord[] = [];
  let page = 1;
  while (true) {
    const data = await fetchOrders({ ...params, page, page_size: 100 });
    out.push(...data.results);
    if (!data.next) return out;
    page += 1;
  }
}

export async function fetchOrder(id: number): Promise<OrderDetail> {
  return authJson<OrderDetail>(`/api/v1/orders/${id}/`);
}

export type DeliveryFeeQuote = {
  distance_km: string | null;
  driver_payout: string;
  platform_fee: string;
  delivery_fee: string;
};

export async function quoteDeliveryFee(input: {
  restaurant_id: number;
  latitude: number;
  longitude: number;
}): Promise<DeliveryFeeQuote> {
  return authJson<DeliveryFeeQuote>("/api/v1/orders/quote-delivery-fee/", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function createSalesOrder(payload: {
  customer_id: number;
  restaurant_id: number;
  items: Array<{ menu_item_id: number; quantity: number }>;
  delivery_address: {
    receiver_name: string;
    phone: string;
    address_line: string;
    landmark?: string;
    latitude?: number;
    longitude?: number;
  };
  customer_note?: string;
  payment_status?: "pending" | "paid" | "failed";
}): Promise<OrderDetail> {
  return authJson<OrderDetail>("/api/v1/orders/", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function updateOrderStatus(id: number, status: string): Promise<OrderDetail> {
  return authJson<OrderDetail>(`/api/v1/orders/${id}/status/`, {
    method: "PATCH",
    body: JSON.stringify({ status }),
  });
}

export async function assignDriver(orderId: number, driverId: number): Promise<OrderDetail> {
  return authJson<OrderDetail>(`/api/v1/orders/${orderId}/assign-driver/`, {
    method: "POST",
    body: JSON.stringify({ driver_id: driverId }),
  });
}

export async function fetchApprovedDrivers(options?: {
  includeBusy?: boolean;
}): Promise<
  Array<{ id: number; full_name: string; phone: string; operational_status?: string }>
> {
  const q = options?.includeBusy ? "?include_busy=true" : "";
  return authJson(`/api/v1/admin/drivers/approved${q}`);
}
