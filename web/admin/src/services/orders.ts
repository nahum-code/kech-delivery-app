import { requestJson } from "./http";

export type OrderRecord = {
  id: number;
  reference: string;
  restaurant: number;
  restaurant_name: string;
  customer_phone: string;
  customer_name: string;
  sales_agent: number | null;
  sales_agent_name: string | null;
  order_channel: "app" | "sales";
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
  restaurant_address: string;
  sales_agent: number | null;
  assigned_driver: number | null;
  delivery_address: {
    receiver_name: string;
    phone: string;
    address_line: string;
    landmark?: string;
  };
  customer_note: string;
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
  page?: number;
}): Promise<PaginatedOrders> {
  const q = new URLSearchParams();
  if (params?.status) q.set("status", params.status);
  if (params?.search) q.set("search", params.search);
  if (params?.page) q.set("page", String(params.page));
  const query = q.toString();
  const path = query ? `/api/v1/orders/?${query}` : "/api/v1/orders/";
  return requestJson<PaginatedOrders>(path);
}

export async function fetchOrder(id: number): Promise<OrderDetail> {
  return requestJson<OrderDetail>(`/api/v1/orders/${id}/`);
}

export async function updateOrderStatus(
  id: number,
  status: string,
): Promise<OrderDetail> {
  return requestJson<OrderDetail>(`/api/v1/orders/${id}/status/`, {
    method: "PATCH",
    body: JSON.stringify({ status }),
  });
}

export async function assignDriver(
  orderId: number,
  driverId: number,
): Promise<OrderDetail> {
  return requestJson<OrderDetail>(`/api/v1/orders/${orderId}/assign-driver/`, {
    method: "POST",
    body: JSON.stringify({ driver_id: driverId }),
  });
}

export async function fetchApprovedDrivers(options?: {
  includeBusy?: boolean;
}): Promise<
  Array<{
    id: number;
    full_name: string;
    phone: string;
    vehicle_type: string;
    operational_status?: string;
  }>
> {
  const q = options?.includeBusy ? "?include_busy=true" : "";
  return requestJson(`/api/v1/admin/drivers/approved${q}`);
}
