import { requestJson } from "./http";

export type RestaurantRecord = {
  id: number;
  name: string;
  description: string;
  phone: string;
  address_text: string;
  latitude: string;
  longitude: string;
  opening_hours: string;
  is_active: boolean;
  logo_url: string | null;
  cover_image_url: string | null;
  menu_item_count: number;
  updated_at: string;
};

export type RestaurantWritePayload = {
  name: string;
  description?: string;
  phone?: string;
  address_text?: string;
  latitude: string | number;
  longitude: string | number;
  opening_hours?: string;
  is_active?: boolean;
  logo?: File | null;
  cover_image?: File | null;
};

function toFormData(payload: Partial<RestaurantWritePayload>): FormData {
  const fd = new FormData();
  if (payload.name != null) fd.append("name", payload.name);
  if (payload.description != null) fd.append("description", payload.description);
  if (payload.phone != null) fd.append("phone", payload.phone);
  if (payload.address_text != null) fd.append("address_text", payload.address_text);
  if (payload.latitude != null) fd.append("latitude", String(payload.latitude));
  if (payload.longitude != null) fd.append("longitude", String(payload.longitude));
  if (payload.opening_hours != null) fd.append("opening_hours", payload.opening_hours);
  if (payload.is_active != null) fd.append("is_active", payload.is_active ? "true" : "false");
  if (payload.logo) fd.append("logo", payload.logo);
  if (payload.cover_image) fd.append("cover_image", payload.cover_image);
  return fd;
}

export async function fetchRestaurants(search?: string): Promise<RestaurantRecord[]> {
  const q = search?.trim() ? `?search=${encodeURIComponent(search.trim())}` : "";
  return requestJson<RestaurantRecord[]>(`/api/v1/restaurants/${q}`);
}

export async function createRestaurant(payload: RestaurantWritePayload): Promise<RestaurantRecord> {
  return requestJson<RestaurantRecord>("/api/v1/restaurants/", {
    method: "POST",
    body: toFormData(payload),
  });
}

export async function updateRestaurant(
  id: number,
  payload: Partial<RestaurantWritePayload>,
): Promise<RestaurantRecord> {
  return requestJson<RestaurantRecord>(`/api/v1/restaurants/${id}/`, {
    method: "PATCH",
    body: toFormData(payload as RestaurantWritePayload),
  });
}

export async function deleteRestaurant(id: number): Promise<void> {
  return requestJson<void>(`/api/v1/restaurants/${id}/`, { method: "DELETE" });
}
