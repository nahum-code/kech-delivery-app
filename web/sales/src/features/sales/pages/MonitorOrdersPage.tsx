"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { format } from "date-fns";
import { Eye, Package, PackageCheck, RefreshCw, Search, Users } from "lucide-react";
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
import {
  ORDER_STATUS_OPTIONS,
  parseApiError,
  paymentBadgeClass,
  paymentLabel,
  statusBadgeClass,
  statusLabel,
} from "@/lib/order-utils";
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

const POLL_MS = 30_000;
const TERMINAL = new Set(["delivered", "cancelled"]);

export function MonitorOrdersPage() {
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [detail, setDetail] = useState<OrderDetail | null>(null);
  const [drivers, setDrivers] = useState<Array<{ id: number; full_name: string }>>([]);
  const [assignDriverId, setAssignDriverId] = useState("");
  const [submitting, setSubmitting] = useState(false);

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
      const msg = parseApiError(e, "Failed to load orders");
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
    const id = setInterval(() => void load(), POLL_MS);
    return () => clearInterval(id);
  }, [load]);

  useEffect(() => {
    void fetchApprovedDrivers()
      .then((rows) => setDrivers(rows.map((d) => ({ id: d.id, full_name: d.full_name }))))
      .catch(() => setDrivers([]));
  }, []);

  useEffect(() => {
    if (selectedId == null) {
      setDetail(null);
      return;
    }
    void fetchOrder(selectedId)
      .then(setDetail)
      .catch((e) => toast.error(parseApiError(e, "Failed to load order")));
  }, [selectedId]);

  const stats = useMemo(() => {
    const active = orders.filter((o) => !TERMINAL.has(o.status)).length;
    const unassigned = orders.filter(
      (o) => !o.assigned_driver && !TERMINAL.has(o.status),
    ).length;
    const delivered = orders.filter((o) => o.status === "delivered").length;
    return { active, unassigned, delivered };
  }, [orders]);

  const handleAssign = async () => {
    if (selectedId == null || !assignDriverId) return;
    setSubmitting(true);
    try {
      await assignDriver(selectedId, Number(assignDriverId));
      toast.success("Driver assigned");
      await load();
      setDetail(await fetchOrder(selectedId));
    } catch (e) {
      toast.error(parseApiError(e, "Assignment failed"));
    } finally {
      setSubmitting(false);
    }
  };

  const handleStatus = async (status: string) => {
    if (selectedId == null) return;
    setSubmitting(true);
    try {
      await updateOrderStatus(selectedId, status);
      toast.success("Status updated");
      await load();
      setDetail(await fetchOrder(selectedId));
    } catch (e) {
      toast.error(parseApiError(e, "Update failed"));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold sm:text-3xl">Monitor Orders</h1>
          <p className="mt-1 text-muted-foreground">Live order operations</p>
        </div>
        <Button variant="outline" size="sm" onClick={() => void load()} disabled={loading}>
          <RefreshCw className={`mr-2 h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          Refresh
        </Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <Package className="h-8 w-8 text-[#800020]" />
            <div>
              <p className="text-sm text-muted-foreground">Active (page)</p>
              <p className="text-2xl font-semibold">{stats.active}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <Users className="h-8 w-8 text-amber-600" />
            <div>
              <p className="text-sm text-muted-foreground">Unassigned (page)</p>
              <p className="text-2xl font-semibold">{stats.unassigned}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <PackageCheck className="h-8 w-8 text-green-600" />
            <div>
              <p className="text-sm text-muted-foreground">Delivered (page)</p>
              <p className="text-2xl font-semibold">{stats.delivered}</p>
            </div>
          </CardContent>
        </Card>
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
              {ORDER_STATUS_OPTIONS.map((s) => (
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
                  <TableCell colSpan={9} className="py-8 text-center text-muted-foreground">
                    Loading orders...
                  </TableCell>
                </TableRow>
              ) : error ? (
                <TableRow>
                  <TableCell colSpan={9} className="py-8 text-center">
                    <p className="text-destructive mb-2">{error}</p>
                    <Button variant="outline" size="sm" onClick={() => void load()}>
                      Retry
                    </Button>
                  </TableCell>
                </TableRow>
              ) : orders.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={9} className="py-8 text-center text-muted-foreground">
                    No orders match your filters
                  </TableCell>
                </TableRow>
              ) : (
                orders.map((o) => (
                  <TableRow key={o.id}>
                    <TableCell className="font-medium">{o.reference}</TableCell>
                    <TableCell>
                      <div className="text-sm">{o.customer_name}</div>
                      <div className="text-xs text-muted-foreground">{o.customer_phone}</div>
                    </TableCell>
                    <TableCell>{o.restaurant_name}</TableCell>
                    <TableCell className="text-sm">
                      {o.assigned_driver_name ?? "—"}
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className={statusBadgeClass(o.status)}>
                        {statusLabel(o.status)}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className={paymentBadgeClass(o.payment_status)}>
                        {paymentLabel(o.payment_status)}
                      </Badge>
                    </TableCell>
                    <TableCell>{o.total_amount} ETB</TableCell>
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
                  <span className="text-muted-foreground">Status:</span>{" "}
                  <Badge variant="outline" className={statusBadgeClass(detail.status)}>
                    {statusLabel(detail.status)}
                  </Badge>
                </p>
                <p className="flex items-center gap-2 flex-wrap">
                  <span className="text-muted-foreground">Payment:</span>
                  <Badge variant="outline" className={paymentBadgeClass(detail.payment_status)}>
                    {paymentLabel(detail.payment_status)}
                  </Badge>
                  {detail.payment_status === "paid" && (
                    <span className="text-xs text-green-700">Customer paid via Chapa</span>
                  )}
                </p>
                <p>
                  <span className="text-muted-foreground">Customer:</span> {detail.customer_phone}
                </p>
                <p>
                  <span className="text-muted-foreground">Restaurant:</span> {detail.restaurant_name}
                </p>
                <ul className="space-y-2 border-t pt-4">
                  {detail.items.map((item) => (
                    <li key={item.id} className="flex justify-between">
                      <span>
                        {item.item_name} ×{item.quantity}
                      </span>
                      <span>{item.total_price} ETB</span>
                    </li>
                  ))}
                </ul>
                <div className="flex flex-wrap gap-2 border-t pt-4">
                  {["confirmed", "preparing", "ready_for_pickup", "delivered", "cancelled"].map(
                    (s) => (
                      <Button
                        key={s}
                        size="sm"
                        variant="outline"
                        disabled={submitting}
                        onClick={() => void handleStatus(s)}
                      >
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
                  <Button
                    className="bg-[#800020] hover:bg-[#600018]"
                    disabled={submitting || !assignDriverId}
                    onClick={() => void handleAssign()}
                  >
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
