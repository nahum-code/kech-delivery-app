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
  fetchAllOrders,
  updateOrderStatus,
  type OrderDetail,
  type OrderRecord,
  type PaginatedOrders,
} from "@/services/orders";
import {
  ORDER_STATUS_OPTIONS,
  parseApiError,
  paymentBadgeClass,
  paymentLabel,
  statusBadgeClass,
  statusLabel,
} from "@/lib/order-utils";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

const POLL_MS = 30_000;
const TERMINAL = new Set(["delivered", "cancelled"]);

const PAGE_SIZE = 20;

export function MonitorOrdersPage() {
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [detail, setDetail] = useState<OrderDetail | null>(null);
  const [drivers, setDrivers] = useState<Array<{ id: number; full_name: string }>>([]);
  const [assignDriverId, setAssignDriverId] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [allOrders, setAllOrders] = useState<OrderRecord[]>([]);

  const totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));

  const loadStats = useCallback(async () => {
    try {
      const all = await fetchAllOrders();
      setAllOrders(all);
    } catch {
      // stats are best-effort
    }
  }, []);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data: PaginatedOrders = await fetchOrders({
        status: statusFilter === "all" ? undefined : statusFilter,
        search: search || undefined,
        date_from: dateFrom || undefined,
        date_to: dateTo || undefined,
        page,
        page_size: PAGE_SIZE,
      });
      setOrders(data.results);
      setTotalCount(data.count);
    } catch (e) {
      const msg = parseApiError(e, "Failed to load orders");
      setError(msg);
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  }, [search, statusFilter, dateFrom, dateTo, page]);

  useEffect(() => {
    const t = setTimeout(() => { void load(); void loadStats(); }, 300);
    return () => clearTimeout(t);
  }, [load, loadStats]);

  useEffect(() => {
    const id = setInterval(() => { void load(); void loadStats(); }, POLL_MS);
    return () => clearInterval(id);
  }, [load, loadStats]);

  useEffect(() => {
    void fetchApprovedDrivers({ includeBusy: true })
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
    const active = allOrders.filter((o) => !TERMINAL.has(o.status)).length;
    const unassigned = allOrders.filter(
      (o) => !o.assigned_driver && !TERMINAL.has(o.status),
    ).length;
    const delivered = allOrders.filter((o) => o.status === "delivered").length;
    return { active, unassigned, delivered };
  }, [allOrders]);

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
              <p className="text-sm text-muted-foreground">Active</p>
              <p className="text-2xl font-semibold">{stats.active}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <Users className="h-8 w-8 text-amber-600" />
            <div>
              <p className="text-sm text-muted-foreground">Unassigned</p>
              <p className="text-2xl font-semibold">{stats.unassigned}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-3 p-4">
            <PackageCheck className="h-8 w-8 text-green-600" />
            <div>
              <p className="text-sm text-muted-foreground">Delivered</p>
              <p className="text-2xl font-semibold">{stats.delivered}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardContent className="flex flex-col gap-4 p-4 sm:flex-row sm:flex-wrap">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <Input
              className="pl-10"
              placeholder="Search reference, phone, restaurant..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            />
          </div>
          <Select value={statusFilter} onValueChange={(v) => { setStatusFilter(v); setPage(1); }}>
            <SelectTrigger className="w-full sm:w-[180px]">
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
          <div className="flex items-center gap-2">
            <Input
              type="date"
              className="w-[150px]"
              value={dateFrom}
              onChange={(e) => { setDateFrom(e.target.value); setPage(1); }}
            />
            <span className="text-sm text-gray-400">to</span>
            <Input
              type="date"
              className="w-[150px]"
              value={dateTo}
              onChange={(e) => { setDateTo(e.target.value); setPage(1); }}
            />
            {(dateFrom || dateTo) && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => { setDateFrom(""); setDateTo(""); setPage(1); }}
              >
                Clear
              </Button>
            )}
          </div>
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
                <TableHead>Created At</TableHead>
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
                    <TableCell className="whitespace-nowrap text-xs">
                      {format(new Date(o.placed_at), "MMM d, yyyy HH:mm")}
                    </TableCell>
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

      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-gray-500">
            {totalCount} order{totalCount !== 1 ? "s" : ""} total
          </p>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              disabled={page <= 1}
              onClick={() => setPage((p) => p - 1)}
            >
              Previous
            </Button>
            <span className="text-sm text-gray-600">
              Page {page} of {totalPages}
            </span>
            <Button
              variant="outline"
              size="sm"
              disabled={page >= totalPages}
              onClick={() => setPage((p) => p + 1)}
            >
              Next
            </Button>
          </div>
        </div>
      )}

      <Sheet open={selectedId != null} onOpenChange={() => setSelectedId(null)}>
        <SheetContent className="w-full overflow-y-auto sm:max-w-lg">
          {/* SheetTitle / Description are required by Radix for screen
              readers; render them unconditionally so the warning doesn't
              fire on the brief loading flash before `detail` resolves. */}
          <SheetHeader className={detail ? undefined : "sr-only"}>
            <SheetTitle>{detail?.reference ?? "Order details"}</SheetTitle>
            <SheetDescription className="sr-only">
              Order details, items, and admin operations.
            </SheetDescription>
          </SheetHeader>
          {detail && (
            <>
              <div className="space-y-4 px-4 pb-6 text-sm">
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
                <div className="space-y-1 border-t pt-3">
                  <div className="flex justify-between text-gray-500">
                    <span>Subtotal</span>
                    <span>{detail.subtotal} ETB</span>
                  </div>
                  <div className="flex justify-between text-gray-500">
                    <span>Delivery fee</span>
                    <span>{detail.delivery_fee} ETB</span>
                  </div>
                  <div className="flex justify-between font-semibold">
                    <span>Total</span>
                    <span>{detail.total_amount} ETB</span>
                  </div>
                </div>
                {detail.customer_note && detail.customer_note.trim().length > 0 && (
                  <div className="rounded-md border border-amber-200 bg-amber-50 p-3">
                    <p className="text-[11px] font-bold uppercase tracking-wider text-amber-700">
                      Special instructions
                    </p>
                    <p className="mt-1 whitespace-pre-line text-sm text-amber-900">
                      {detail.customer_note}
                    </p>
                  </div>
                )}
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
