import { requestJson } from "./http";

export type MenuCategoryRecord = {
  id: number;
  name: string;
  sort_order: number;
  is_active: boolean;
};

export type MenuItemRecord = {
  id: number;
  category_id: number;
  category_name: string;
  name: string;
  description: string;
  price: string;
  currency: string;
  is_available: boolean;
  image_url: string | null;
  sort_order: number;
};

export async function fetchCategories(restaurantId: number): Promise<MenuCategoryRecord[]> {
  return requestJson<MenuCategoryRecord[]>(`/api/v1/restaurants/${restaurantId}/categories/`);
}

export async function createCategory(
  restaurantId: number,
  payload: { name: string; sort_order?: number; is_active?: boolean },
): Promise<MenuCategoryRecord> {
  return requestJson<MenuCategoryRecord>(`/api/v1/restaurants/${restaurantId}/categories/`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function updateCategory(
  restaurantId: number,
  categoryId: number,
  payload: Partial<{ name: string; sort_order: number; is_active: boolean }>,
): Promise<MenuCategoryRecord> {
  return requestJson<MenuCategoryRecord>(
    `/api/v1/restaurants/${restaurantId}/categories/${categoryId}/`,
    { method: "PATCH", body: JSON.stringify(payload) },
  );
}

export async function deleteCategory(restaurantId: number, categoryId: number): Promise<void> {
  return requestJson<void>(`/api/v1/restaurants/${restaurantId}/categories/${categoryId}/`, {
    method: "DELETE",
  });
}

export async function fetchMenuItems(
  restaurantId: number,
  categoryId?: number,
): Promise<MenuItemRecord[]> {
  const q = categoryId != null ? `?category_id=${categoryId}` : "";
  return requestJson<MenuItemRecord[]>(`/api/v1/restaurants/${restaurantId}/menu-items/${q}`);
}

export async function createMenuItem(
  restaurantId: number,
  payload: {
    category_id: number;
    name: string;
    description?: string;
    price: string | number;
    is_available?: boolean;
    image?: File | null;
    sort_order?: number;
  },
): Promise<MenuItemRecord> {
  const fd = new FormData();
  fd.append("category_id", String(payload.category_id));
  fd.append("name", payload.name);
  if (payload.description) fd.append("description", payload.description);
  fd.append("price", String(payload.price));
  fd.append("currency", "ETB");
  if (payload.is_available != null) fd.append("is_available", payload.is_available ? "true" : "false");
  if (payload.sort_order != null) fd.append("sort_order", String(payload.sort_order));
  if (payload.image) fd.append("image", payload.image);
  return requestJson<MenuItemRecord>(`/api/v1/restaurants/${restaurantId}/menu-items/`, {
    method: "POST",
    body: fd,
  });
}

export async function updateMenuItem(
  restaurantId: number,
  itemId: number,
  payload: Partial<{
    category_id: number;
    name: string;
    description: string;
    price: string | number;
    is_available: boolean;
    image: File | null;
    sort_order: number;
  }>,
): Promise<MenuItemRecord> {
  const fd = new FormData();
  if (payload.category_id != null) fd.append("category_id", String(payload.category_id));
  if (payload.name != null) fd.append("name", payload.name);
  if (payload.description != null) fd.append("description", payload.description);
  if (payload.price != null) fd.append("price", String(payload.price));
  fd.append("currency", "ETB");
  if (payload.is_available != null) fd.append("is_available", payload.is_available ? "true" : "false");
  if (payload.sort_order != null) fd.append("sort_order", String(payload.sort_order));
  if (payload.image) fd.append("image", payload.image);
  return requestJson<MenuItemRecord>(`/api/v1/restaurants/${restaurantId}/menu-items/${itemId}/`, {
    method: "PATCH",
    body: fd,
  });
}

export async function deleteMenuItem(restaurantId: number, itemId: number): Promise<void> {
  return requestJson<void>(`/api/v1/restaurants/${restaurantId}/menu-items/${itemId}/`, {
    method: "DELETE",
  });
}
