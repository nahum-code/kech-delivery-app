"use client";

import { useCallback, useEffect, useState } from "react";
import { format } from "date-fns";
import { Eye, RefreshCw, Search } from "lucide-react";
import { toast } from "sonner";

import {
  assignDriver,
  fetchApprovedDrivers,
  fetchOrder,
  fetchOrders,
  updateOrderStatus,
  type OrderDetail,
  type OrderRecord,
} from "@/services/orders";
import { Badge } from "../components/ui/badge";
import { Button } from "../components/ui/button";
import { Card, CardContent } from "../components/ui/card";
import { Input } from "../components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "../components/ui/sheet";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../components/ui/table";

const STATUS_OPTIONS = [
  "all",
  "pending",
  "confirmed",
  "preparing",
  "ready_for_pickup",
  "assigned",
  "picked_up",
  "delivering",
  "delivered",
  "cancelled",
];

function statusLabel(s: string) {
  return s.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

function statusBadgeClass(status: string): string {
  switch (status) {
    case "delivered":
      return "bg-green-100 text-green-800 border-green-200";
    case "cancelled":
      return "bg-red-100 text-red-800 border-red-200";
    case "pending":
      return "bg-gray-100 text-gray-800 border-gray-200";
    default:
      return "bg-amber-100 text-amber-800 border-amber-200";
  }
}

function paymentLabel(s: string) {
  return s.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

export function OrdersMonitor() {
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [detail, setDetail] = useState<OrderDetail | null>(null);
  const [drivers, setDrivers] = useState<Array<{ id: number; full_name: string }>>([]);
  const [assignDriverId, setAssignDriverId] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchOrders({
        status: statusFilter === "all" ? undefined : statusFilter,
        search: search || undefined,
      });
      setOrders(data.results);
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Failed to load orders";
      setError(msg);
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  }, [search, statusFilter]);

  useEffect(() => {
    const t = setTimeout(() => void load(), 300);
    return () => clearTimeout(t);
  }, [load]);

  useEffect(() => {
    const id = setInterval(() => void load(), 30_000);
    return () => clearInterval(id);
  }, [load]);

  useEffect(() => {
    void fetchApprovedDrivers().then(setDrivers).catch(() => setDrivers([]));
  }, []);

  useEffect(() => {
    if (selectedId == null) {
      setDetail(null);
      return;
    }
    void fetchOrder(selectedId)
      .then(setDetail)
      .catch((e) => toast.error(e instanceof Error ? e.message : "Failed to load order"));
  }, [selectedId]);

  const handleAssign = async () => {
    if (selectedId == null || !assignDriverId) return;
    try {
      await assignDriver(selectedId, Number(assignDriverId));
      toast.success("Driver assigned");
      await load();
      const refreshed = await fetchOrder(selectedId);
      setDetail(refreshed);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Assignment failed");
    }
  };

  const handleStatus = async (status: string) => {
    if (selectedId == null) return;
    try {
      await updateOrderStatus(selectedId, status);
      toast.success("Status updated");
      await load();
      setDetail(await fetchOrder(selectedId));
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Update failed");
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold sm:text-3xl">Orders Monitor</h1>
          <p className="mt-1 text-gray-600">Live operations view</p>
        </div>
        <Button variant="outline" size="sm" onClick={() => void load()} disabled={loading}>
          <RefreshCw className={`mr-2 h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          Refresh
        </Button>
      </div>

      <Card>
        <CardContent className="flex flex-col gap-4 p-4 sm:flex-row">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <Input
              className="pl-10"
              placeholder="Search reference, phone, restaurant..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-full sm:w-[200px]">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              {STATUS_OPTIONS.map((s) => (
                <SelectItem key={s} value={s}>
                  {s === "all" ? "All statuses" : statusLabel(s)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="overflow-x-auto p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Reference</TableHead>
                <TableHead>Customer</TableHead>
                <TableHead>Restaurant</TableHead>
                <TableHead>Driver</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Payment</TableHead>
                <TableHead>Total</TableHead>
                <TableHead>Placed</TableHead>
                <TableHead />
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={9}>Loading...</TableCell>
                </TableRow>
              ) : error ? (
                <TableRow>
                  <TableCell colSpan={9} className="text-center py-8">
                    <p className="text-destructive mb-2">{error}</p>
                    <Button variant="outline" size="sm" onClick={() => void load()}>
                      Retry
                    </Button>
                  </TableCell>
                </TableRow>
              ) : orders.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={9}>No orders</TableCell>
                </TableRow>
              ) : (
                orders.map((o) => (
                  <TableRow key={o.id}>
                    <TableCell className="font-medium">{o.reference}</TableCell>
                    <TableCell>
                      <p className="text-sm">{o.customer_name}</p>
                      <p className="text-xs text-gray-500">{o.customer_phone}</p>
                    </TableCell>
                    <TableCell>{o.restaurant_name}</TableCell>
                    <TableCell className="text-sm">{o.assigned_driver_name ?? "—"}</TableCell>
                    <TableCell>
                      <Badge variant="outline" className={statusBadgeClass(o.status)}>
                        {statusLabel(o.status)}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary">{paymentLabel(o.payment_status)}</Badge>
                    </TableCell>
                    <TableCell>
                      {o.total_amount} MAD
                    </TableCell>
                    <TableCell>{format(new Date(o.placed_at), "MMM d, HH:mm")}</TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" onClick={() => setSelectedId(o.id)}>
                        <Eye className="h-4 w-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Sheet open={selectedId != null} onOpenChange={() => setSelectedId(null)}>
        <SheetContent className="w-full overflow-y-auto sm:max-w-lg">
          {detail && (
            <>
              <SheetHeader>
                <SheetTitle>{detail.reference}</SheetTitle>
              </SheetHeader>
              <div className="mt-6 space-y-4 text-sm">
                <p>
                  <span className="text-gray-500">Status:</span> {statusLabel(detail.status)}
                </p>
                <p>
                  <span className="text-gray-500">Customer:</span> {detail.customer_phone}
                </p>
                <p>
                  <span className="text-gray-500">Restaurant:</span> {detail.restaurant_name}
                </p>
                <ul className="space-y-2 border-t pt-4">
                  {detail.items.map((item) => (
                    <li key={item.id} className="flex justify-between">
                      <span>
                        {item.item_name} ×{item.quantity}
                      </span>
                      <span>{item.total_price} MAD</span>
                    </li>
                  ))}
                </ul>
                <div className="flex gap-2 flex-wrap border-t pt-4">
                  {["confirmed", "preparing", "ready_for_pickup", "delivered", "cancelled"].map(
                    (s) => (
                      <Button key={s} size="sm" variant="outline" onClick={() => void handleStatus(s)}>
                        {statusLabel(s)}
                      </Button>
                    ),
                  )}
                </div>
                <div className="flex gap-2 border-t pt-4">
                  <Select value={assignDriverId} onValueChange={setAssignDriverId}>
                    <SelectTrigger className="flex-1">
                      <SelectValue placeholder="Assign driver" />
                    </SelectTrigger>
                    <SelectContent>
                      {drivers.map((d) => (
                        <SelectItem key={d.id} value={String(d.id)}>
                          {d.full_name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <Button className="bg-[#800020]" onClick={() => void handleAssign()}>
                    Assign
                  </Button>
                </div>
              </div>
            </>
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
}
