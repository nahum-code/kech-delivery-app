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

function toFormData(payload: RestaurantWritePayload): FormData {
  const fd = new FormData();
  fd.append("name", payload.name);
  if (payload.description != null) fd.append("description", payload.description);
  if (payload.phone != null) fd.append("phone", payload.phone);
  if (payload.address_text != null) fd.append("address_text", payload.address_text);
  fd.append("latitude", String(payload.latitude));
  fd.append("longitude", String(payload.longitude));
  if (payload.opening_hours != null) fd.append("opening_hours", payload.opening_hours);
  if (payload.is_active != null) fd.append("is_active", payload.is_active ? "true" : "false");
  if (payload.logo) fd.append("logo", payload.logo);
  if (payload.cover_image) fd.append("cover_image", payload.cover_image);
  return fd;
}

function toJsonBody(payload: RestaurantWritePayload): string {
  const latitude = Number(payload.latitude);
  const longitude = Number(payload.longitude);
  if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) {
    throw new Error("Latitude must be a number between -90 and 90.");
  }
  if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
    throw new Error("Longitude must be a number between -180 and 180.");
  }

  return JSON.stringify({
    name: payload.name.trim(),
    description: payload.description ?? "",
    phone: payload.phone ?? "",
    address_text: payload.address_text ?? "",
    latitude,
    longitude,
    opening_hours: payload.opening_hours ?? "",
    is_active: payload.is_active ?? true,
  });
}

function toPatchJsonBody(payload: Partial<RestaurantWritePayload>): string {
  const body: Record<string, unknown> = {};
  if (payload.name != null) body.name = payload.name.trim();
  if (payload.description != null) body.description = payload.description;
  if (payload.phone != null) body.phone = payload.phone;
  if (payload.address_text != null) body.address_text = payload.address_text;
  if (payload.latitude != null) {
    const latitude = Number(payload.latitude);
    if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) {
      throw new Error("Latitude must be a number between -90 and 90.");
    }
    body.latitude = latitude;
  }
  if (payload.longitude != null) {
    const longitude = Number(payload.longitude);
    if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
      throw new Error("Longitude must be a number between -180 and 180.");
    }
    body.longitude = longitude;
  }
  if (payload.opening_hours != null) body.opening_hours = payload.opening_hours;
  if (payload.is_active != null) body.is_active = payload.is_active;
  return JSON.stringify(body);
}

export async function fetchRestaurants(search?: string): Promise<RestaurantRecord[]> {
  const term = search?.trim();
  const path = term
    ? `/api/v1/restaurants/?search=${encodeURIComponent(term)}`
    : "/api/v1/restaurants/";
  return requestJson<RestaurantRecord[]>(path);
}

export async function createRestaurant(payload: RestaurantWritePayload): Promise<RestaurantRecord> {
  const hasFiles = Boolean(payload.logo || payload.cover_image);
  if (hasFiles) {
    return requestJson<RestaurantRecord>("/api/v1/restaurants/", {
      method: "POST",
      body: toFormData(payload),
    });
  }
  return requestJson<RestaurantRecord>("/api/v1/restaurants/", {
    method: "POST",
    body: toJsonBody(payload),
  });
}

export async function updateRestaurant(
  id: number,
  payload: Partial<RestaurantWritePayload>,
): Promise<RestaurantRecord> {
  const hasFiles = Boolean(payload.logo || payload.cover_image);
  if (hasFiles) {
    return requestJson<RestaurantRecord>(`/api/v1/restaurants/${id}/`, {
      method: "PATCH",
      body: toFormData(payload as RestaurantWritePayload),
    });
  }
  return requestJson<RestaurantRecord>(`/api/v1/restaurants/${id}/`, {
    method: "PATCH",
    body: toPatchJsonBody(payload),
  });
}

export async function deleteRestaurant(id: number): Promise<void> {
  return requestJson<void>(`/api/v1/restaurants/${id}/`, { method: "DELETE" });
}
