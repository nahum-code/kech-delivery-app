"use client";

import { useEffect, useRef, useState } from "react";
import { Search } from "lucide-react";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import { Input } from "./ui/input";

const ICON_BASE = "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images";

const restaurantIcon = L.icon({
  iconUrl: `${ICON_BASE}/marker-icon.png`,
  iconRetinaUrl: `${ICON_BASE}/marker-icon-2x.png`,
  shadowUrl: `${ICON_BASE}/marker-shadow.png`,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
  className: "leaflet-restaurant-marker",
});

const dropoffIcon = L.divIcon({
  className: "",
  html: `<div style="
    width:22px;height:22px;border-radius:50%;
    background:#2563eb;border:3px solid white;
    box-shadow:0 0 0 1px #2563eb, 0 2px 6px rgba(0,0,0,0.35);
  "></div>`,
  iconSize: [22, 22],
  iconAnchor: [11, 11],
});

export type DropoffMapPickerProps = {
  restaurant: { latitude: number; longitude: number; name: string };
  dropoff?: { latitude: number; longitude: number } | null;
  onPick: (pos: { latitude: number; longitude: number }) => void;
  height?: number;
};

type SearchResult = {
  place_id: number;
  display_name: string;
  lat: string;
  lon: string;
};

export function DropoffMapPicker({
  restaurant,
  dropoff,
  onPick,
  height = 280,
}: DropoffMapPickerProps) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<L.Map | null>(null);
  const restaurantMarkerRef = useRef<L.Marker | null>(null);
  const dropoffMarkerRef = useRef<L.Marker | null>(null);
  const onPickRef = useRef(onPick);
  onPickRef.current = onPick;

  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [searching, setSearching] = useState(false);
  const [resultsOpen, setResultsOpen] = useState(false);

  useEffect(() => {
    const q = query.trim();
    if (q.length < 3) {
      setResults([]);
      setSearching(false);
      return;
    }
    const controller = new AbortController();
    const timer = setTimeout(async () => {
      setSearching(true);
      try {
        const url =
          `https://nominatim.openstreetmap.org/search?format=jsonv2&limit=5&q=${encodeURIComponent(q)}`;
        const res = await fetch(url, {
          signal: controller.signal,
          headers: { Accept: "application/json" },
        });
        if (!res.ok) {
          setResults([]);
          return;
        }
        const data = (await res.json()) as SearchResult[];
        setResults(data);
        setResultsOpen(true);
      } catch (e) {
        if ((e as { name?: string }).name !== "AbortError") setResults([]);
      } finally {
        setSearching(false);
      }
    }, 400);
    return () => {
      controller.abort();
      clearTimeout(timer);
    };
  }, [query]);

  const handleSelectResult = (r: SearchResult) => {
    const lat = Number.parseFloat(r.lat);
    const lng = Number.parseFloat(r.lon);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return;
    onPickRef.current({ latitude: lat, longitude: lng });
    setQuery(r.display_name);
    setResultsOpen(false);
  };

  // Mount once. React Strict Mode in dev may double-invoke effects; the
  // cleanup tears the map down so the second pass re-initialises cleanly.
  useEffect(() => {
    if (!containerRef.current) return;
    const map = L.map(containerRef.current, {
      center: [restaurant.latitude, restaurant.longitude],
      zoom: 15,
    });
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(map);
    const rMarker = L.marker([restaurant.latitude, restaurant.longitude], {
      icon: restaurantIcon,
    })
      .addTo(map)
      .bindPopup(restaurant.name);
    map.on("click", (e: L.LeafletMouseEvent) => {
      onPickRef.current({ latitude: e.latlng.lat, longitude: e.latlng.lng });
    });
    mapRef.current = map;
    restaurantMarkerRef.current = rMarker;
    // Tiles sometimes render blank if the container's final size differs from
    // the size at init — recompute after the next frame.
    requestAnimationFrame(() => map.invalidateSize());
    return () => {
      map.remove();
      mapRef.current = null;
      restaurantMarkerRef.current = null;
      dropoffMarkerRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update restaurant marker when the selected restaurant changes.
  useEffect(() => {
    if (!mapRef.current || !restaurantMarkerRef.current) return;
    restaurantMarkerRef.current.setLatLng([restaurant.latitude, restaurant.longitude]);
    restaurantMarkerRef.current.bindPopup(restaurant.name);
    if (!dropoffMarkerRef.current) {
      mapRef.current.setView([restaurant.latitude, restaurant.longitude], 15);
    } else {
      mapRef.current.fitBounds(
        L.latLngBounds(
          restaurantMarkerRef.current.getLatLng(),
          dropoffMarkerRef.current.getLatLng(),
        ),
        { padding: [40, 40] },
      );
    }
  }, [restaurant.latitude, restaurant.longitude, restaurant.name]);

  // Sync dropoff marker.
  useEffect(() => {
    if (!mapRef.current) return;
    if (!dropoff) {
      if (dropoffMarkerRef.current) {
        dropoffMarkerRef.current.remove();
        dropoffMarkerRef.current = null;
      }
      return;
    }
    const latlng: L.LatLngExpression = [dropoff.latitude, dropoff.longitude];
    if (dropoffMarkerRef.current) {
      dropoffMarkerRef.current.setLatLng(latlng);
    } else {
      dropoffMarkerRef.current = L.marker(latlng, { icon: dropoffIcon }).addTo(mapRef.current);
    }
    if (restaurantMarkerRef.current) {
      mapRef.current.fitBounds(
        L.latLngBounds(restaurantMarkerRef.current.getLatLng(), latlng),
        { padding: [40, 40] },
      );
    }
  }, [dropoff]);

  return (
    <div className="space-y-2">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground z-10 pointer-events-none" />
        <Input
          type="text"
          value={query}
          placeholder="Search a place (e.g. Bole, Atlas Hotel)"
          onChange={(e) => {
            setQuery(e.target.value);
            setResultsOpen(true);
          }}
          onFocus={() => results.length > 0 && setResultsOpen(true)}
          className="pl-9"
        />
        {(searching || (resultsOpen && results.length > 0)) && (
          <div className="absolute z-[1000] mt-1 max-h-64 w-full overflow-auto rounded-md border bg-popover text-popover-foreground shadow-md">
            {searching && (
              <div className="px-3 py-2 text-xs text-muted-foreground">Searching…</div>
            )}
            {!searching && results.length === 0 && (
              <div className="px-3 py-2 text-xs text-muted-foreground">No results</div>
            )}
            {results.map((r) => (
              <button
                key={r.place_id}
                type="button"
                className="block w-full px-3 py-2 text-left text-sm hover:bg-accent hover:text-accent-foreground"
                onClick={() => handleSelectResult(r)}
              >
                {r.display_name}
              </button>
            ))}
          </div>
        )}
      </div>
      <div
        ref={containerRef}
        style={{ height, width: "100%" }}
        className="rounded-lg overflow-hidden border"
        onClick={() => setResultsOpen(false)}
      />
    </div>
  );
}

export type NominatimResult = { display_name: string; lat: string; lon: string };

export async function reverseGeocode(
  latitude: number,
  longitude: number,
): Promise<string | null> {
  const url = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`;
  try {
    const res = await fetch(url, {
      headers: { Accept: "application/json" },
    });
    if (!res.ok) return null;
    const data = (await res.json()) as { display_name?: string };
    return data.display_name ?? null;
  } catch {
    return null;
  }
}
