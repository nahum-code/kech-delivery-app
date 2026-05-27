"use client";

import { useMemo } from "react";
import { KpiCard } from "@/components/shared/KpiCard";
import {
  Package,
  Truck,
  AlertCircle,
  CheckCircle,
  XCircle,
  DollarSign,
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { format } from "date-fns";
import { useAnalytics } from "@/hooks/use-analytics";

const STATUS_COLORS = ["#10b981", "#800020", "#f97316", "#6b7280", "#06b6d4", "#f59e0b"];

function money(value: string | number, currency: string): string {
  const amount = Number(value);
  if (!Number.isFinite(amount)) {
    return `0.00 ${currency}`;
  }
  return `${amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ${currency}`;
}

export function Dashboard() {
  const { revenue, profit, loading, error, reload } = useAnalytics("7d");

  const statusMap = useMemo(() => {
    const map = new Map<string, number>();
    for (const row of revenue?.order_status_distribution ?? []) {
      map.set(row.status, row.count);
    }
    return map;
  }, [revenue?.order_status_distribution]);

  const completedOrders = statusMap.get("delivered") ?? 0;
  const cancelledOrders = statusMap.get("cancelled") ?? 0;
  const activeOrders =
    (statusMap.get("assigned") ?? 0) +
    (statusMap.get("picked_up") ?? 0) +
    (statusMap.get("delivering") ?? 0);
  const searchingDriver =
    (statusMap.get("pending") ?? 0) +
    (statusMap.get("confirmed") ?? 0) +
    (statusMap.get("preparing") ?? 0) +
    (statusMap.get("ready_for_pickup") ?? 0);
  const totalOrders = (revenue?.order_status_distribution ?? []).reduce(
    (sum, row) => sum + row.count,
    0,
  );
  const todayOrders = revenue?.totals.orders_count ?? 0;
  const completionRate =
    totalOrders > 0 ? ((completedOrders / totalOrders) * 100).toFixed(1) : "0.0";
  const cancellationRate =
    totalOrders > 0 ? ((cancelledOrders / totalOrders) * 100).toFixed(1) : "0.0";

  const ordersOverTimeData = (revenue?.trends ?? []).map((point) => ({
    date: format(new Date(point.date), "MMM dd"),
    orders: point.orders_count,
  }));

  const ordersByStatusData = (revenue?.order_status_distribution ?? []).map((row, index) => ({
    name: row.status.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()),
    value: row.count,
    color: STATUS_COLORS[index % STATUS_COLORS.length],
  }));

  if (loading) {
    return <div className="p-8 text-sm text-gray-600">Loading dashboard analytics...</div>;
  }

  if (error) {
    return (
      <div className="space-y-4">
        <h1 className="text-3xl font-semibold text-gray-900">Dashboard</h1>
        <Card>
          <CardContent className="p-6 space-y-3">
            <p className="text-red-600">{error}</p>
            <Button className="bg-[#800020] hover:bg-[#600018]" onClick={() => void reload()}>
              Retry
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-1">
          Welcome back! Here&apos;s your operations overview.
        </p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <KpiCard
          title="Total Orders Today"
          value={todayOrders}
          change="+12% from yesterday"
          changeType="increase"
          icon={Package}
        />
        <KpiCard
          title="Active Deliveries"
          value={activeOrders}
          change="In progress right now"
          changeType="neutral"
          icon={Truck}
        />
        <KpiCard
          title="Unassigned Orders"
          value={searchingDriver}
          change="Awaiting driver assignment"
          changeType="neutral"
          icon={AlertCircle}
        />
        <KpiCard
          title="Completion Rate"
          value={`${completionRate}%`}
          change="+2.3% this week"
          changeType="increase"
          icon={CheckCircle}
        />
        <KpiCard
          title="Cancellation Rate"
          value={`${cancellationRate}%`}
          change="-0.5% this week"
          changeType="increase"
          icon={XCircle}
        />
        <KpiCard
          title="Platform Balance"
          value={money(profit?.totals.platform_balance ?? "0", profit?.currency ?? "ETB")}
          change="Accumulated platform fees"
          changeType="neutral"
          icon={DollarSign}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Orders Over Time Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Orders Over Time</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={ordersOverTimeData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="orders"
                  stroke="#800020"
                  strokeWidth={2}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Orders by Status Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Orders by Status</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={ordersByStatusData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) =>
                    `${name}: ${(percent * 100).toFixed(0)}%`
                  }
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {ordersByStatusData.map((entry, index) => (
                    <Cell key={`cell-${entry.name}-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Needs Attention Panel */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertCircle className="w-5 h-5 text-orange-500" />
              Needs Attention
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {(revenue?.top_restaurants ?? [])
                .slice(0, 3)
                .map((restaurant) => (
                  <div
                    key={restaurant.restaurant_id}
                    className="flex items-center justify-between p-3 bg-orange-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium">{restaurant.restaurant_name}</p>
                      <p className="text-sm text-gray-600">
                        {restaurant.orders_count} paid orders in selected period
                      </p>
                    </div>
                    <StatusBadge status="Completed" type="order" />
                  </div>
                ))}
              {(revenue?.top_restaurants ?? []).length === 0 && (
                <p className="text-gray-500 text-center py-4">
                  No paid orders in selected period.
                </p>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Recent Activity Feed */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {(revenue?.trends ?? []).slice(-5).reverse().map((point) => (
                <div key={point.date} className="flex gap-3">
                  <div className="w-2 h-2 rounded-full bg-[#800020] mt-2"></div>
                  <div className="flex-1">
                    <p className="text-sm">
                      Revenue {money(point.revenue, revenue?.currency ?? "ETB")} from{" "}
                      {point.orders_count} paid orders
                    </p>
                    <p className="text-xs text-gray-500">
                      {format(new Date(point.date), "MMM dd")}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}