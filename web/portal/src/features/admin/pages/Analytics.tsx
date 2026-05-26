"use client";

import { useMemo, useState } from "react";
import { format } from "date-fns";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { KpiCard } from "@/components/shared/KpiCard";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Download,
  TrendingUp,
  Clock,
  CheckCircle,
  XCircle,
  DollarSign,
} from "lucide-react";
import { toast } from "sonner";
import { useAnalytics, type AnalyticsRange } from "@/hooks/use-analytics";
import { buildAnalyticsCsv, downloadAnalyticsCsv } from "@/lib/export-analytics-csv";

function money(value: string | number, currency: string): string {
  const amount = Number(value);
  if (!Number.isFinite(amount)) return `0.00 ${currency}`;
  return `${amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ${currency}`;
}

function dateRangeToHookRange(value: string): AnalyticsRange {
  if (value === "24h" || value === "7d" || value === "30d" || value === "90d") {
    return value;
  }
  return "7d";
}

export function Analytics() {
  const [dateRange, setDateRange] = useState<AnalyticsRange>("7d");
  const { revenue, driver, profit, loading, error, reload } =
    useAnalytics(dateRange);

  const handleExport = () => {
    if (!revenue && !driver && !profit) {
      toast.error("No analytics data to export yet.");
      return;
    }
    const csv = buildAnalyticsCsv({
      rangeLabel: dateRange,
      revenue,
      driver,
      profit,
    });
    const stamp = new Date().toISOString().slice(0, 10);
    downloadAnalyticsCsv(`kech-analytics-${dateRange}-${stamp}.csv`, csv);
    toast.success("Analytics report downloaded");
  };

  const orderVolumeData = useMemo(
    () =>
      (revenue?.trends ?? []).map((point) => ({
        date: point.date,
        orders: point.orders_count,
        revenue: Number(point.revenue),
      })),
    [revenue?.trends],
  );

  const statusDistributionData = useMemo(
    () =>
      (revenue?.order_status_distribution ?? []).map((row) => ({
        status: row.status
          .replace(/_/g, " ")
          .replace(/\b\w/g, (c) => c.toUpperCase()),
        count: row.count,
      })),
    [revenue?.order_status_distribution],
  );

  const completionRate = useMemo(() => {
    const delivered =
      revenue?.order_status_distribution.find(
        (row) => row.status === "delivered",
      )?.count ?? 0;
    const total = (revenue?.order_status_distribution ?? []).reduce(
      (sum, row) => sum + row.count,
      0,
    );
    return total > 0 ? ((delivered / total) * 100).toFixed(1) : "0.0";
  }, [revenue?.order_status_distribution]);

  const cancellationRate = useMemo(() => {
    const cancelled =
      revenue?.order_status_distribution.find(
        (row) => row.status === "cancelled",
      )?.count ?? 0;
    const total = (revenue?.order_status_distribution ?? []).reduce(
      (sum, row) => sum + row.count,
      0,
    );
    return total > 0 ? ((cancelled / total) * 100).toFixed(1) : "0.0";
  }, [revenue?.order_status_distribution]);

  if (loading) {
    return (
      <div className="p-8 text-sm text-gray-600">Loading analytics...</div>
    );
  }

  if (error) {
    return (
      <div className="space-y-4">
        <h1 className="text-3xl font-semibold text-gray-900">Analytics</h1>
        <Card>
          <CardContent className="p-6 space-y-3">
            <p className="text-red-600">{error}</p>
            <Button
              className="bg-[#800020] hover:bg-[#600018]"
              onClick={() => void reload()}
            >
              Retry
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-gray-900">Analytics</h1>
          <p className="text-gray-600 mt-1">
            Operations and financial insights for data-driven decisions
          </p>
        </div>
        <div className="flex gap-3">
          <Select
            value={dateRange}
            onValueChange={(value) => setDateRange(dateRangeToHookRange(value))}
          >
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Select range" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="24h">Last 24 hours</SelectItem>
              <SelectItem value="7d">Last 7 days</SelectItem>
              <SelectItem value="30d">Last 30 days</SelectItem>
              <SelectItem value="90d">Last 90 days</SelectItem>
            </SelectContent>
          </Select>
          <Button className="bg-[#800020] hover:bg-[#600018]" onClick={handleExport}>
            <Download className="w-4 h-4 mr-2" />
            Export Report
          </Button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KpiCard
          title="Total Order Volume"
          value={revenue?.totals.orders_count ?? 0}
          change="Paid orders in selected period"
          changeType="neutral"
          icon={TrendingUp}
        />
        <KpiCard
          title="Successful Payments"
          value={revenue?.totals.successful_payments_count ?? 0}
          change="Confirmed successful transactions"
          changeType="neutral"
          icon={Clock}
        />
        <KpiCard
          title="Gross Revenue"
          value={money(
            profit?.totals.gross_revenue ?? "0",
            profit?.currency ?? "ETB",
          )}
          change="From successful payments"
          changeType="neutral"
          icon={Clock}
        />
        <KpiCard
          title="Estimated Platform Profit"
          value={money(
            profit?.totals.estimated_platform_profit ?? "0",
            profit?.currency ?? "ETB",
          )}
          change="MVP formula (gross - driver payouts)"
          changeType="neutral"
          icon={DollarSign}
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <KpiCard
          title="Completion Rate"
          value={`${completionRate}%`}
          change="Delivered orders ratio"
          changeType="neutral"
          icon={CheckCircle}
        />
        <KpiCard
          title="Cancellation Rate"
          value={`${cancellationRate}%`}
          change="Cancelled orders ratio"
          changeType="neutral"
          icon={XCircle}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Order Volume & Revenue Trend */}
        <Card>
          <CardHeader>
            <CardTitle>Order Volume & Revenue Trend</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={orderVolumeData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis
                  dataKey="date"
                  tickFormatter={(value) => format(new Date(value), "MMM dd")}
                />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip />
                <Legend />
                <Line
                  yAxisId="left"
                  type="monotone"
                  dataKey="orders"
                  stroke="#800020"
                  strokeWidth={2}
                  name="Orders"
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="revenue"
                  stroke="#10b981"
                  strokeWidth={2}
                  name="Revenue (ETB)"
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Driver Payout by Driver */}
        <Card>
          <CardHeader>
            <CardTitle>Driver Payout by Driver</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart
                data={(driver?.drivers ?? []).slice(0, 8).map((row) => ({
                  driver: row.driver_phone,
                  payout: Number(row.payout_total),
                }))}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="driver" hide />
                <YAxis
                  label={{ value: "ETB", angle: -90, position: "insideLeft" }}
                />
                <Tooltip />
                <Legend />
                <Bar
                  dataKey="payout"
                  fill="#800020"
                  name="Driver payout (ETB)"
                />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Order Status Distribution */}
        <Card>
          <CardHeader>
            <CardTitle>Order Status Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={statusDistributionData} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" />
                <YAxis dataKey="status" type="category" width={100} />
                <Tooltip />
                <Bar dataKey="count" fill="#800020" name="Count" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Top Restaurants by Volume */}
        <Card>
          <CardHeader>
            <CardTitle>Top Restaurants by Revenue</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Restaurant</TableHead>
                  <TableHead className="text-right">Orders</TableHead>
                  <TableHead className="text-right">Revenue</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {(revenue?.top_restaurants ?? []).map((restaurant) => (
                  <TableRow key={`restaurant-${restaurant.restaurant_id}`}>
                    <TableCell className="font-medium">
                      {restaurant.restaurant_name}
                    </TableCell>
                    <TableCell className="text-right">
                      {restaurant.orders_count}
                    </TableCell>
                    <TableCell className="text-right">
                      {money(restaurant.revenue, revenue?.currency ?? "ETB")}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      {/* Financial Summary */}
      <Card>
        <CardHeader>
          <CardTitle>Financial Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="space-y-2">
              <p className="text-sm text-gray-600">Total Delivery Fees</p>
              <p className="text-2xl font-semibold">
                {money(
                  revenue?.totals.revenue_total ?? "0",
                  revenue?.currency ?? "ETB",
                )}
              </p>
              <p className="text-sm text-gray-600">
                Successful payment revenue
              </p>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-gray-600">Total Driver Payouts</p>
              <p className="text-2xl font-semibold">
                {money(
                  driver?.summary.driver_payout_total ?? "0",
                  driver?.currency ?? "ETB",
                )}
              </p>
              <p className="text-sm text-gray-600">
                {driver?.summary.total_deliveries ?? 0} delivered orders
              </p>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-gray-600">Total Platform Fees</p>
              <p className="text-2xl font-semibold text-[#800020]">
                {money(
                  profit?.totals.estimated_platform_profit ?? "0",
                  profit?.currency ?? "ETB",
                )}
              </p>
              <p className="text-sm text-gray-600">Estimated (MVP formula)</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
