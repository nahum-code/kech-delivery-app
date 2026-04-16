"use client";

import { useState, useMemo } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { KpiCard } from "../components/KpiCard";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../components/ui/select";
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
} from "../components/ui/table";
import { Download, TrendingUp, Clock, CheckCircle, XCircle, DollarSign } from "lucide-react";
import { mockOrders, mockRestaurants } from "../data/mockData";

const orderVolumeData = [
  { date: "Mar 13", orders: 45, revenue: 1260 },
  { date: "Mar 14", orders: 52, revenue: 1456 },
  { date: "Mar 15", orders: 48, revenue: 1344 },
  { date: "Mar 16", orders: 61, revenue: 1708 },
  { date: "Mar 17", orders: 55, revenue: 1540 },
  { date: "Mar 18", orders: 67, revenue: 1876 },
  { date: "Mar 19", orders: 58, revenue: 1624 },
];

const deliveryTimeData = [
  { hour: "08:00", avgTime: 22 },
  { hour: "10:00", avgTime: 18 },
  { hour: "12:00", avgTime: 28 },
  { hour: "14:00", avgTime: 25 },
  { hour: "16:00", avgTime: 20 },
  { hour: "18:00", avgTime: 32 },
  { hour: "20:00", avgTime: 35 },
  { hour: "22:00", avgTime: 24 },
];

const statusDistributionData = [
  { status: "Completed", count: 156 },
  { status: "Cancelled", count: 12 },
  { status: "In Progress", count: 23 },
  { status: "Pending", count: 8 },
];

export function Analytics() {
  const [dateRange, setDateRange] = useState("7d");

  const topRestaurants = useMemo(() => {
    return mockRestaurants
      .map((restaurant) => {
        const restaurantOrders = mockOrders.filter(
          (order) => order.restaurant === restaurant.name,
        );

        return {
          ...restaurant,
          orders: restaurantOrders.length,
          revenue: restaurantOrders.reduce(
            (sum, order) => sum + order.deliveryFee,
            0,
          ),
        };
      })
      .sort((a, b) => b.orders - a.orders)
      .slice(0, 5);
  }, []);

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
          <Select value={dateRange} onValueChange={setDateRange}>
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
          <Button className="bg-[#800020] hover:bg-[#600018]">
            <Download className="w-4 h-4 mr-2" />
            Export Report
          </Button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KpiCard
          title="Total Order Volume"
          value="386"
          change="+15.3% vs last period"
          changeType="increase"
          icon={TrendingUp}
        />
        <KpiCard
          title="Avg. Assignment Time"
          value="2.3 min"
          change="-0.4 min vs last period"
          changeType="increase"
          icon={Clock}
        />
        <KpiCard
          title="Avg. Delivery Time"
          value="26 min"
          change="+2 min vs last period"
          changeType="neutral"
          icon={Clock}
        />
        <KpiCard
          title="Platform Fee Total"
          value="1,158 MAD"
          change="+18% vs last period"
          changeType="increase"
          icon={DollarSign}
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <KpiCard
          title="Completion Rate"
          value="92.5%"
          change="+2.3% vs last period"
          changeType="increase"
          icon={CheckCircle}
        />
        <KpiCard
          title="Cancellation Rate"
          value="3.8%"
          change="-0.5% vs last period"
          changeType="increase"
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
                <XAxis dataKey="date" />
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
                  name="Revenue (MAD)"
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Average Delivery Time by Hour */}
        <Card>
          <CardHeader>
            <CardTitle>Average Delivery Time by Hour</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={deliveryTimeData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="hour" />
                <YAxis label={{ value: "Minutes", angle: -90, position: "insideLeft" }} />
                <Tooltip />
                <Legend />
                <Bar dataKey="avgTime" fill="#800020" name="Avg. Time (min)" />
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
            <CardTitle>Top Restaurants by Order Volume</CardTitle>
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
                {topRestaurants.map((restaurant) => (
                  <TableRow key={`restaurant-${restaurant.id}`}>
                    <TableCell className="font-medium">{restaurant.name}</TableCell>
                    <TableCell className="text-right">{restaurant.orders}</TableCell>
                    <TableCell className="text-right">
                      {restaurant.revenue} MAD
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
              <p className="text-2xl font-semibold">5,814 MAD</p>
              <p className="text-sm text-green-600">+15.3% vs last period</p>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-gray-600">Total Driver Payouts</p>
              <p className="text-2xl font-semibold">4,656 MAD</p>
              <p className="text-sm text-gray-600">80.1% of delivery fees</p>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-gray-600">Total Platform Fees</p>
              <p className="text-2xl font-semibold text-[#800020]">1,158 MAD</p>
              <p className="text-sm text-green-600">+18% vs last period</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}