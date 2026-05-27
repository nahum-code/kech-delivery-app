import type {
  DriverAnalyticsResponse,
  PlatformProfitAnalyticsResponse,
  RevenueAnalyticsResponse,
} from "@/services/analytics";

function escapeCsv(value: string | number | null | undefined): string {
  const text = value == null ? "" : String(value);
  if (text.includes(",") || text.includes('"') || text.includes("\n")) {
    return `"${text.replace(/"/g, '""')}"`;
  }
  return text;
}

function row(cells: Array<string | number | null | undefined>): string {
  return cells.map(escapeCsv).join(",");
}

export function buildAnalyticsCsv(params: {
  rangeLabel: string;
  revenue: RevenueAnalyticsResponse | null;
  driver: DriverAnalyticsResponse | null;
  profit: PlatformProfitAnalyticsResponse | null;
}): string {
  const lines: string[] = [];
  const { rangeLabel, revenue, driver, profit } = params;

  lines.push(row(["Kech Analytics Export"]));
  lines.push(row(["Range", rangeLabel]));
  if (revenue?.date_range) {
    lines.push(row(["Start date", revenue.date_range.start_date]));
    lines.push(row(["End date", revenue.date_range.end_date]));
  }
  lines.push("");

  lines.push(row(["Revenue totals"]));
  if (revenue?.totals) {
    lines.push(row(["Metric", "Value"]));
    lines.push(row(["Orders count", revenue.totals.orders_count]));
    lines.push(row(["Successful payments", revenue.totals.successful_payments_count]));
    lines.push(row(["Revenue total", revenue.totals.revenue_total]));
    lines.push(row(["Revenue today", revenue.totals.revenue_today]));
    lines.push(row(["Revenue weekly", revenue.totals.revenue_weekly]));
    lines.push(row(["Revenue monthly", revenue.totals.revenue_monthly]));
  }
  lines.push("");

  lines.push(row(["Revenue trends"]));
  lines.push(row(["Date", "Revenue", "Orders"]));
  for (const point of revenue?.trends ?? []) {
    lines.push(row([point.date, point.revenue, point.orders_count]));
  }
  lines.push("");

  lines.push(row(["Order status distribution"]));
  lines.push(row(["Status", "Count"]));
  for (const item of revenue?.order_status_distribution ?? []) {
    lines.push(row([item.status, item.count]));
  }
  lines.push("");

  lines.push(row(["Top restaurants"]));
  lines.push(row(["Restaurant", "Revenue", "Orders"]));
  for (const r of revenue?.top_restaurants ?? []) {
    lines.push(row([r.restaurant_name, r.revenue, r.orders_count]));
  }
  lines.push("");

  lines.push(row(["Driver payouts summary"]));
  if (driver?.summary) {
    lines.push(row(["Total drivers", driver.summary.total_drivers]));
    lines.push(row(["Total deliveries", driver.summary.total_deliveries]));
    lines.push(row(["Driver payout total", driver.summary.driver_payout_total]));
  }
  lines.push("");

  lines.push(row(["Driver payouts detail"]));
  lines.push(row(["Driver ID", "Phone", "Deliveries", "Payout total"]));
  for (const d of driver?.drivers ?? []) {
    lines.push(row([d.driver_id, d.driver_phone, d.deliveries_count, d.payout_total]));
  }
  lines.push("");

  lines.push(row(["Platform profit"]));
  if (profit?.totals) {
    lines.push(row(["Gross revenue", profit.totals.gross_revenue]));
    lines.push(row(["Delivery fee total", profit.totals.delivery_fee_total]));
    lines.push(row(["Driver payout total", profit.totals.driver_payout_total]));
    lines.push(row(["Platform balance", profit.totals.platform_balance]));
    lines.push(row(["Total deliveries", profit.totals.total_deliveries]));
  }

  return lines.join("\n");
}

export function downloadAnalyticsCsv(filename: string, csv: string): void {
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
}
