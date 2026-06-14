import { authJson } from "./http";

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

export type PublicMenuItem = {
  id: number;
  name: string;
  description: string;
  price: string;
  takeaway_box_price: string;
  currency: string;
  image_url: string | null;
  sort_order: number;
};

export type PublicMenuCategory = {
  id: number;
  name: string;
  sort_order: number;
  items: PublicMenuItem[];
};

export type RestaurantMenuPayload = {
  restaurant_id: number;
  restaurant_name: string;
  categories: PublicMenuCategory[];
};

export async function fetchRestaurants(search?: string): Promise<RestaurantRecord[]> {
  const q = search?.trim() ? `?search=${encodeURIComponent(search.trim())}` : "";
  return authJson<RestaurantRecord[]>(`/api/v1/restaurants/${q}`);
}

export async function fetchRestaurantMenu(restaurantId: number): Promise<RestaurantMenuPayload> {
  return authJson<RestaurantMenuPayload>(`/api/v1/restaurants/${restaurantId}/menu/`);
}
