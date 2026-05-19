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
      setError(e instanceof Error ? e.message : "Failed to load restaurants");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const handle = setTimeout(() => {
      void load(search);
    }, 300);
    return () => clearTimeout(handle);
  }, [search, load]);

  const save = async (payload: RestaurantWritePayload, id?: number) => {
    if (id != null) {
      await updateRestaurant(id, payload);
    } else {
      await createRestaurant(payload);
    }
    await load(search);
  };

  const remove = async (id: number) => {
    await deleteRestaurant(id);
    await load(search);
  };

  return { restaurants, loading, error, search, setSearch, reload: load, save, remove };
}
