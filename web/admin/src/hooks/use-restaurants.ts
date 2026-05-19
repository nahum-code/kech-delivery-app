"use client";

import { useCallback, useEffect, useState } from "react";
import {
  createRestaurant,
  deleteRestaurant,
  fetchRestaurants,
  RestaurantRecord,
  RestaurantWritePayload,
  updateRestaurant,
} from "@/services/restaurants";

export function useRestaurants() {
  const [restaurants, setRestaurants] = useState<RestaurantRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");

  const load = useCallback(async (term?: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchRestaurants(term);
      setRestaurants(data);
    } catch (e) {
      const message = e instanceof Error ? e.message : "Failed to load restaurants";
      setError(message);
      throw new Error(message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const handle = setTimeout(() => {
      void load(search).catch(() => undefined);
    }, 300);
    return () => clearTimeout(handle);
  }, [search, load]);

  const save = async (
    payload: RestaurantWritePayload,
    id?: number,
  ): Promise<RestaurantRecord> => {
    const record =
      id != null ? await updateRestaurant(id, payload) : await createRestaurant(payload);
    try {
      await load(search);
    } catch {
      // Keep saved record even if list refresh fails; caller already succeeded.
    }
    return record;
  };

  const remove = async (id: number) => {
    await deleteRestaurant(id);
    await load(search);
  };

  return { restaurants, loading, error, search, setSearch, reload: load, save, remove };
}
