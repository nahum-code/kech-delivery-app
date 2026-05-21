"use client";

import { useEffect, useRef, useState } from "react";
import { Search } from "lucide-react";
import L from "leaflet";

const ICON_BASE = "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images";

const restaurantIcon = L.icon({
  iconUrl: `${ICON_BASE}/marker-icon.png`,
  iconRetinaUrl: `${ICON_BASE}/marker-icon-2x.png`,
  shadowUrl: `${ICON_BASE}/marker-shadow.png`,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
});

const DEFAULT_CENTER: [number, number] = [9.0192, 38.7525]; // Addis Ababa

export type RestaurantLocationPickerProps = {
  latitude: number | null;
  longitude: number | null;
  onPick: (pos: { latitude: number; longitude: number }) => void;
  height?: number;
};

type SearchResult = {
  place_id: number;
  display_name: string;
  lat: string;
  lon: string;
};

export function RestaurantLocationPicker({
  latitude,
  longitude,
  onPick,
  height = 280,
}: RestaurantLocationPickerProps) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<L.Map | null>(null);
  const markerRef = useRef<L.Marker | null>(null);
  const onPickRef = useRef(onPick);
  onPickRef.current = onPick;

  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [searching, setSearching] = useState(false);
  const [resultsOpen, setResultsOpen] = useState(false);

  useEffect(() => {
    if (!containerRef.current) return;
    const initial: [number, number] =
      Number.isFinite(latitude) && Number.isFinite(longitude)
        ? [latitude as number, longitude as number]
        : DEFAULT_CENTER;
    const map = L.map(containerRef.current, {
      center: initial,
      zoom: latitude != null && longitude != null ? 16 : 13,
    });
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(map);
    map.on("click", (e: L.LeafletMouseEvent) => {
      onPickRef.current({ latitude: e.latlng.lat, longitude: e.latlng.lng });
    });
    mapRef.current = map;
    if (Number.isFinite(latitude) && Number.isFinite(longitude)) {
      markerRef.current = L.marker(initial, { icon: restaurantIcon }).addTo(map);
    }
    requestAnimationFrame(() => map.invalidateSize());
    return () => {
      map.remove();
      mapRef.current = null;
      markerRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Debounced forward-geocoding search via OSM Nominatim (free, ~1 req/sec).
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

  // Sync marker + view when lat/lng change (typed manually or picked).
  useEffect(() => {
    if (!mapRef.current) return;
    if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
      if (markerRef.current) {
        markerRef.current.remove();
        markerRef.current = null;
      }
      return;
    }
    const pos: L.LatLngExpression = [latitude as number, longitude as number];
    if (markerRef.current) {
      markerRef.current.setLatLng(pos);
    } else {
      markerRef.current = L.marker(pos, { icon: restaurantIcon }).addTo(mapRef.current);
    }
    mapRef.current.setView(pos, Math.max(mapRef.current.getZoom(), 15));
  }, [latitude, longitude]);

  return (
    <div className="space-y-2">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <input
          type="text"
          value={query}
          placeholder="Search a place (e.g. Bole, Atlas Hotel)"
          onChange={(e) => {
            setQuery(e.target.value);
            setResultsOpen(true);
          }}
          onFocus={() => results.length > 0 && setResultsOpen(true)}
          className="flex h-9 w-full rounded-md border border-input bg-transparent pl-9 pr-3 py-1 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
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
