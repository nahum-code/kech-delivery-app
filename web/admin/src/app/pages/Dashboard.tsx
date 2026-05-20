import { KpiCard } from "../components/KpiCard";
import {
  Package,
  Truck,
  AlertCircle,
  CheckCircle,
  XCircle,
  DollarSign,
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
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
import { StatusBadge } from "../components/StatusBadge";
import { mockOrders, mockActivities } from "../data/mockData";
import { format } from "date-fns";

const ordersOverTimeData = [
  { date: "Mar 13", orders: 45 },
  { date: "Mar 14", orders: 52 },
  { date: "Mar 15", orders: 48 },
  { date: "Mar 16", orders: 61 },
  { date: "Mar 17", orders: 55 },
  { date: "Mar 18", orders: 67 },
  { date: "Mar 19", orders: 58 },
];

const ordersByStatusData = [
  { name: "Completed", value: 156, color: "#10b981" },
  { name: "In Progress", value: 23, color: "#800020" },
  { name: "Searching Driver", value: 8, color: "#f97316" },
  { name: "Cancelled", value: 12, color: "#6b7280" },
];

export function Dashboard() {
  const activeOrders = mockOrders.filter(
    (o) => o.status === "PickedUp" || o.status === "Accepted"
  ).length;
  const searchingDriver = mockOrders.filter(
    (o) => o.status === "SearchingDriver"
  ).length;
  const totalPlatformFee = mockOrders.reduce(
    (sum, o) => sum + o.platformFee,
    0
  );
  const todayOrders = mockOrders.length;
  const completedOrders = mockOrders.filter(
    (o) => o.status === "Completed" || o.status === "Delivered"
  ).length;
  const cancelledOrders = mockOrders.filter((o) => o.status === "Cancelled")
    .length;
  const totalOrders = todayOrders;
  const completionRate =
    totalOrders > 0 ? ((completedOrders / totalOrders) * 100).toFixed(1) : "0.0";
  const cancellationRate =
    totalOrders > 0 ? ((cancelledOrders / totalOrders) * 100).toFixed(1) : "0.0";

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
          title="Total Platform Fee"
          value={`${totalPlatformFee} ETB`}
          change="Today's earnings"
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
              {mockOrders
                .filter((o) => o.status === "SearchingDriver")
                .map((order) => (
                  <div
                    key={order.id}
                    className="flex items-center justify-between p-3 bg-orange-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium">{order.orderNumber}</p>
                      <p className="text-sm text-gray-600">
                        Searching driver for {order.restaurant}
                      </p>
                    </div>
                    <StatusBadge status={order.status} type="order" />
                  </div>
                ))}
              {mockOrders.filter((o) => o.status === "SearchingDriver")
                .length === 0 && (
                <p className="text-gray-500 text-center py-4">
                  All orders have drivers assigned
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
              {mockActivities.map((activity) => (
                <div key={activity.id} className="flex gap-3">
                  <div className="w-2 h-2 rounded-full bg-[#800020] mt-2"></div>
                  <div className="flex-1">
                    <p className="text-sm">{activity.message}</p>
                    <p className="text-xs text-gray-500">
                      {format(activity.timestamp, "HH:mm")}
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