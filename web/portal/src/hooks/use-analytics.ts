import { useCallback, useEffect, useMemo, useState } from "react";
import {
  fetchDriverAnalytics,
  fetchPlatformProfitAnalytics,
  fetchRevenueAnalytics,
  type DriverAnalyticsResponse,
  type PlatformProfitAnalyticsResponse,
  type RevenueAnalyticsResponse,
} from "@/services/analytics";

export type AnalyticsRange = "24h" | "7d" | "30d" | "90d";

function rangeToDates(range: AnalyticsRange): { start_date: string; end_date: string } {
  const now = new Date();
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const start = new Date(end);
  if (range === "24h") {
    start.setDate(start.getDate() - 1);
  } else if (range === "7d") {
    start.setDate(start.getDate() - 6);
  } else if (range === "30d") {
    start.setDate(start.getDate() - 29);
  } else {
    start.setDate(start.getDate() - 89);
  }
  const fmt = (d: Date) =>
    `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  return { start_date: fmt(start), end_date: fmt(end) };
}

export function useAnalytics(range: AnalyticsRange) {
  const [revenue, setRevenue] = useState<RevenueAnalyticsResponse | null>(null);
  const [driver, setDriver] = useState<DriverAnalyticsResponse | null>(null);
  const [profit, setProfit] = useState<PlatformProfitAnalyticsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const dateParams = useMemo(() => rangeToDates(range), [range]);

  const reload = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [revenueRes, driverRes, profitRes] = await Promise.all([
        fetchRevenueAnalytics(dateParams),
        fetchDriverAnalytics(dateParams),
        fetchPlatformProfitAnalytics(dateParams),
      ]);
      setRevenue(revenueRes);
      setDriver(driverRes);
      setProfit(profitRes);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to load analytics");
    } finally {
      setLoading(false);
    }
  }, [dateParams]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void reload();
  }, [reload]);

  return { revenue, driver, profit, loading, error, reload, dateParams };
}
