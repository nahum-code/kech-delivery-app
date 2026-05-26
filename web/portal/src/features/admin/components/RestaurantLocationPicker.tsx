"use client";



import { useEffect, useRef, useState } from "react";

import { Search } from "lucide-react";

import "leaflet/dist/leaflet.css";



import { resolveGeoPick, shortenDisplayName, type GeoPick } from "@/lib/nominatim";

import type { Map as LeafletMap, Marker as LeafletMarker } from "leaflet";



const ICON_BASE = "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images";

const DEFAULT_CENTER: [number, number] = [9.0192, 38.7525]; // Addis Ababa



export type RestaurantLocationPickerProps = {

  latitude: number | null;

  longitude: number | null;

  onPick: (pos: GeoPick) => void;

  /** Pre-fill search when editing an existing restaurant. */
  initialAddress?: string;

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

  initialAddress = "",

  height = 280,

}: RestaurantLocationPickerProps) {

  const containerRef = useRef<HTMLDivElement | null>(null);

  const mapRef = useRef<LeafletMap | null>(null);

  const markerRef = useRef<LeafletMarker | null>(null);

  const onPickRef = useRef(onPick);



  const [query, setQuery] = useState("");

  const [results, setResults] = useState<SearchResult[]>([]);

  const [searching, setSearching] = useState(false);

  const [resolvingAddress, setResolvingAddress] = useState(false);

  const [resultsOpen, setResultsOpen] = useState(false);

  const [mapReady, setMapReady] = useState(false);



  useEffect(() => {

    onPickRef.current = onPick;

  }, [onPick]);

  useEffect(() => {
    if (initialAddress.trim().length > 0) {
      setQuery(initialAddress.trim());
    }
  }, [initialAddress]);

  useEffect(() => {

    if (!containerRef.current) {

      return;

    }



    let cancelled = false;



    void (async () => {

      const L = (await import("leaflet")).default;

      if (cancelled || !containerRef.current) {

        return;

      }



      const restaurantIcon = L.icon({

        iconUrl: `${ICON_BASE}/marker-icon.png`,

        iconRetinaUrl: `${ICON_BASE}/marker-icon-2x.png`,

        shadowUrl: `${ICON_BASE}/marker-shadow.png`,

        iconSize: [25, 41],

        iconAnchor: [12, 41],

        popupAnchor: [1, -34],

        shadowSize: [41, 41],

      });



      const initial: [number, number] =

        Number.isFinite(latitude) && Number.isFinite(longitude)

          ? [latitude as number, longitude as number]

          : DEFAULT_CENTER;



      const map = L.map(containerRef.current, {

        center: initial,

        zoom: latitude != null && longitude != null ? 16 : 13,

      });



      L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {

        attribution:

          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',

        maxZoom: 19,

      }).addTo(map);



      map.on("click", (e) => {

        void (async () => {

          setResolvingAddress(true);

          try {

            const pick = await resolveGeoPick(e.latlng.lat, e.latlng.lng);

            onPickRef.current(pick);

            setQuery(pick.address);

          } finally {

            setResolvingAddress(false);

          }

        })();

      });



      mapRef.current = map;



      if (Number.isFinite(latitude) && Number.isFinite(longitude)) {

        markerRef.current = L.marker(initial, { icon: restaurantIcon }).addTo(map);

      }



      requestAnimationFrame(() => map.invalidateSize());

      if (!cancelled) {

        setMapReady(true);

      }

    })();



    return () => {

      cancelled = true;

      mapRef.current?.remove();

      mapRef.current = null;

      markerRef.current = null;

      setMapReady(false);

    };

    // eslint-disable-next-line react-hooks/exhaustive-deps

  }, []);



  useEffect(() => {

    const q = query.trim();

    if (q.length < 3) {

      const id = window.setTimeout(() => {

        setResults([]);

        setSearching(false);

      }, 0);

      return () => window.clearTimeout(id);

    }



    const controller = new AbortController();

    const timer = window.setTimeout(async () => {

      setSearching(true);

      try {

        const url = `https://nominatim.openstreetmap.org/search?format=jsonv2&limit=5&q=${encodeURIComponent(q)}`;

        const res = await fetch(url, {

          signal: controller.signal,

          headers: { Accept: "application/json", "User-Agent": "kech-delivery-admin/1.0" },

        });

        if (!res.ok) {

          setResults([]);

          return;

        }

        const data = (await res.json()) as SearchResult[];

        setResults(data);

        setResultsOpen(true);

      } catch (e) {

        if ((e as { name?: string }).name !== "AbortError") {

          setResults([]);

        }

      } finally {

        setSearching(false);

      }

    }, 400);



    return () => {

      controller.abort();

      window.clearTimeout(timer);

    };

  }, [query]);



  const handleSelectResult = (r: SearchResult) => {

    const lat = Number.parseFloat(r.lat);

    const lng = Number.parseFloat(r.lon);

    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {

      return;

    }

    const address = shortenDisplayName(r.display_name);

    onPickRef.current({ latitude: lat, longitude: lng, address });

    setQuery(address);

    setResultsOpen(false);

  };



  useEffect(() => {

    if (!mapReady || !mapRef.current) {

      return;

    }



    void (async () => {

      const L = (await import("leaflet")).default;

      const restaurantIcon = L.icon({

        iconUrl: `${ICON_BASE}/marker-icon.png`,

        iconRetinaUrl: `${ICON_BASE}/marker-icon-2x.png`,

        shadowUrl: `${ICON_BASE}/marker-shadow.png`,

        iconSize: [25, 41],

        iconAnchor: [12, 41],

        popupAnchor: [1, -34],

        shadowSize: [41, 41],

      });



      if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {

        markerRef.current?.remove();

        markerRef.current = null;

        return;

      }



      const pos: [number, number] = [latitude as number, longitude as number];

      if (markerRef.current) {

        markerRef.current.setLatLng(pos);

      } else {

        markerRef.current = L.marker(pos, { icon: restaurantIcon }).addTo(mapRef.current!);

      }

      mapRef.current!.setView(pos, Math.max(mapRef.current!.getZoom(), 15));

    })();

  }, [latitude, longitude, mapReady]);



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

        {(searching || resolvingAddress || (resultsOpen && results.length > 0)) && (

          <div className="absolute z-[1000] mt-1 max-h-64 w-full overflow-auto rounded-md border bg-popover text-popover-foreground shadow-md">

            {resolvingAddress && (

              <div className="px-3 py-2 text-xs text-muted-foreground">Resolving address…</div>

            )}

            {searching && (

              <div className="px-3 py-2 text-xs text-muted-foreground">Searching…</div>

            )}

            {!searching && !resolvingAddress && results.length === 0 && (

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

        className="overflow-hidden rounded-lg border"

        onClick={() => setResultsOpen(false)}

      />

      {resolvingAddress ? (

        <p className="text-xs text-muted-foreground">Updating address from map pin…</p>

      ) : null}

    </div>

  );

}


