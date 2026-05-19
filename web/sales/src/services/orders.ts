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
}): Promise<PaginatedOrders> {
  const q = new URLSearchParams();
  if (params?.status) q.set("status", params.status);
  if (params?.search) q.set("search", params.search);
  if (params?.assigned) q.set("assigned", params.assigned);
  if (params?.page) q.set("page", String(params.page));
  const suffix = q.toString() ? `?${q.toString()}` : "";
  return authJson<PaginatedOrders>(`/api/v1/orders/${suffix}`);
}

export async function fetchOrder(id: number): Promise<OrderDetail> {
  return authJson<OrderDetail>(`/api/v1/orders/${id}/`);
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
  };
  customer_note?: string;
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

export async function fetchApprovedDrivers(): Promise<
  Array<{ id: number; full_name: string; phone: string }>
> {
  return authJson(`/api/v1/admin/drivers/approved/`);
}
