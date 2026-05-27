import { requestJson } from "./http";

export type AnalyticsDateRangeParams = {
  start_date?: string;
  end_date?: string;
  driver_id?: number;
  page?: number;
  page_size?: number;
};

export type RevenueTrendPoint = {
  date: string;
  revenue: string;
  orders_count: number;
};

export type RevenueAnalyticsResponse = {
  currency: string;
  date_range: { start_date: string; end_date: string };
  totals: {
    revenue_total: string;
    revenue_today: string;
    revenue_weekly: string;
    revenue_monthly: string;
    orders_count: number;
    successful_payments_count: number;
  };
  trends: RevenueTrendPoint[];
  order_status_distribution: Array<{ status: string; count: number }>;
  top_restaurants: Array<{
    restaurant_id: number;
    restaurant_name: string;
    revenue: string;
    orders_count: number;
  }>;
};

export type DriverAnalyticsResponse = {
  currency: string;
  date_range: { start_date: string; end_date: string };
  assumptions: Record<string, string>;
  summary: {
    total_drivers: number;
    total_deliveries: number;
    driver_payout_total: string;
  };
  drivers: Array<{
    driver_id: number;
    driver_phone: string;
    deliveries_count: number;
    payout_total: string;
  }>;
  drivers_pagination?: {
    count: number;
    next: string | null;
    previous: string | null;
  };
};

export type PlatformProfitAnalyticsResponse = {
  currency: string;
  date_range: { start_date: string; end_date: string };
  totals: {
    gross_revenue: string;
    delivery_fee_total: string;
    driver_payout_total: string;
    platform_balance: string;
    total_deliveries: number;
  };
};

function qs(params?: AnalyticsDateRangeParams): string {
  const q = new URLSearchParams();
  if (params?.start_date) q.set("start_date", params.start_date);
  if (params?.end_date) q.set("end_date", params.end_date);
  if (params?.driver_id) q.set("driver_id", String(params.driver_id));
  if (params?.page) q.set("page", String(params.page));
  if (params?.page_size) q.set("page_size", String(params.page_size));
  const suffix = q.toString();
  return suffix ? `?${suffix}` : "";
}

export async function fetchRevenueAnalytics(
  params?: AnalyticsDateRangeParams,
): Promise<RevenueAnalyticsResponse> {
  return requestJson<RevenueAnalyticsResponse>(`/api/v1/admin/analytics/revenue/${qs(params)}`);
}

export async function fetchDriverAnalytics(
  params?: AnalyticsDateRangeParams,
): Promise<DriverAnalyticsResponse> {
  return requestJson<DriverAnalyticsResponse>(`/api/v1/admin/analytics/drivers/${qs(params)}`);
}

export async function fetchPlatformProfitAnalytics(
  params?: AnalyticsDateRangeParams,
): Promise<PlatformProfitAnalyticsResponse> {
  return requestJson<PlatformProfitAnalyticsResponse>(`/api/v1/admin/analytics/platform-profit/${qs(params)}`);
}
