/** OpenStreetMap Nominatim helpers (client-side; respect 1 req/s in production). */

export type GeoPick = {
  latitude: number;
  longitude: number;
  address: string;
};

/** Short label for address fields (first segments of Nominatim display_name). */
export function shortenDisplayName(full: string, maxParts = 4): string {
  const parts = full
    .split(",")
    .map((p) => p.trim())
    .filter(Boolean);
  if (parts.length <= maxParts) {
    return full.trim();
  }
  return parts.slice(0, maxParts).join(", ");
}

export async function reverseGeocode(latitude: number, longitude: number): Promise<string | null> {
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
    return null;
  }
  const url = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`;
  try {
    const res = await fetch(url, {
      headers: {
        Accept: "application/json",
        "User-Agent": "kech-delivery-admin/1.0",
      },
    });
    if (!res.ok) {
      return null;
    }
    const data = (await res.json()) as { display_name?: string };
    const name = data.display_name?.trim();
    return name && name.length > 0 ? name : null;
  } catch {
    return null;
  }
}

export async function resolveGeoPick(latitude: number, longitude: number): Promise<GeoPick> {
  const resolved = await reverseGeocode(latitude, longitude);
  return {
    latitude,
    longitude,
    address: resolved ? shortenDisplayName(resolved) : "",
  };
}
