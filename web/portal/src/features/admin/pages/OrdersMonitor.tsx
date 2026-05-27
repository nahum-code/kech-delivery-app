"use client";

import { useCallback, useEffect, useState } from "react";
import { format } from "date-fns";
import { Eye, Pencil, RefreshCw, Search, ShieldAlert } from "lucide-react";
import { toast } from "sonner";

import {
  assignDriver,
  fetchApprovedDrivers,
  fetchOrder,
  fetchOrders,
  updateOrderStatus,
  type OrderDetail,
  type OrderRecord,
  type PaginatedOrders,
} from "@/services/orders";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
import { OrderModifyDialog } from "../components/OrderModifyDialog";

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
  "declined",
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
    case "declined":
      return "bg-orange-100 text-orange-900 border-orange-200";
    case "pending":
      return "bg-gray-100 text-gray-800 border-gray-200";
    default:
      return "bg-amber-100 text-amber-800 border-amber-200";
  }
}

function paymentLabel(s: string) {
  return s.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

const ADMIN_MODIFY_STATUSES = [
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

function OrderChannelBadge({ order }: { order: OrderRecord }) {
  if (order.order_channel === "sales") {
    return (
      <div className="flex flex-col gap-1">
        <Badge className="w-fit bg-[#800020] hover:bg-[#800020] text-white">Sales</Badge>
        {order.sales_agent_name ? (
          <span className="text-xs text-gray-600">{order.sales_agent_name}</span>
        ) : null}
      </div>
    );
  }
  return <Badge variant="outline">Customer app</Badge>;
}

export function OrdersMonitor() {
  const PAGE_SIZE = 20;
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
  const [drivers, setDrivers] = useState<
    Array<{ id: number; full_name: string; operational_status?: string }>
  >([]);
  const [assignDriverId, setAssignDriverId] = useState("");
  const [assigning, setAssigning] = useState(false);
  const [pendingStatus, setPendingStatus] = useState("");
  const [statusUpdating, setStatusUpdating] = useState(false);
  const [cancelDialogOpen, setCancelDialogOpen] = useState(false);
  const [modifyDialogOpen, setModifyDialogOpen] = useState(false);

  const totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));

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
      const msg = e instanceof Error ? e.message : "Failed to load orders";
      setError(msg);
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  }, [search, statusFilter, dateFrom, dateTo, page]);

  useEffect(() => {
    const t = setTimeout(() => void load(), 300);
    return () => clearTimeout(t);
  }, [load]);

  useEffect(() => {
    const id = setInterval(() => void load(), 30_000);
    return () => clearInterval(id);
  }, [load]);

  useEffect(() => {
    void fetchApprovedDrivers({ includeBusy: true })
      .then(setDrivers)
      .catch(() => setDrivers([]));
  }, []);

  useEffect(() => {
    if (selectedId == null) return;
    void fetchOrder(selectedId)
      .then((order) => {
        setDetail(order);
        setPendingStatus(order.status);
        setAssignDriverId("");
        if (order.status === "declined") {
          void fetchApprovedDrivers({ includeBusy: true })
            .then(setDrivers)
            .catch(() => setDrivers([]));
        }
      })
      .catch((e) =>
        toast.error(e instanceof Error ? e.message : "Failed to load order"),
      );
  }, [selectedId]);

  const assignableDrivers =
    detail?.status === "declined" && detail.assigned_driver != null
      ? drivers.filter((d) => d.id !== detail.assigned_driver)
      : drivers;

  const handleAssign = async () => {
    if (selectedId == null || !assignDriverId) return;
    setAssigning(true);
    try {
      await assignDriver(selectedId, Number(assignDriverId));
      toast.success(
        detail?.status === "declined" ? "Driver reassigned" : "Driver assigned",
      );
      await load();
      const refreshed = await fetchOrder(selectedId);
      setDetail(refreshed);
      setAssignDriverId("");
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Assignment failed");
    } finally {
      setAssigning(false);
    }
  };

  const applyStatus = async (status: string) => {
    if (selectedId == null) return;
    setStatusUpdating(true);
    try {
      await updateOrderStatus(selectedId, status);
      toast.success(`Order marked as ${statusLabel(status)}`);
      await load();
      const refreshed = await fetchOrder(selectedId);
      setDetail(refreshed);
      setPendingStatus(refreshed.status);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Update failed");
    } finally {
      setStatusUpdating(false);
      setCancelDialogOpen(false);
    }
  };

  const canCancel =
    detail != null && detail.status !== "cancelled" && detail.status !== "delivered";
  const canModify =
    detail != null && detail.status !== "cancelled" && detail.status !== "delivered";

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold sm:text-3xl">Orders Monitor</h1>
          <p className="mt-1 text-gray-600">Live operations view</p>
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={() => void load()}
          disabled={loading}
        >
          <RefreshCw
            className={`mr-2 h-4 w-4 ${loading ? "animate-spin" : ""}`}
          />
          Refresh
        </Button>
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
              {STATUS_OPTIONS.map((s) => (
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
                <TableHead>Source</TableHead>
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
                  <TableCell colSpan={10}>Loading...</TableCell>
                </TableRow>
              ) : error ? (
                <TableRow>
                  <TableCell colSpan={10} className="text-center py-8">
                    <p className="text-destructive mb-2">{error}</p>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => void load()}
                    >
                      Retry
                    </Button>
                  </TableCell>
                </TableRow>
              ) : orders.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={10}>No orders</TableCell>
                </TableRow>
              ) : (
                orders.map((o) => (
                  <TableRow key={o.id}>
                    <TableCell className="font-medium">{o.reference}</TableCell>
                    <TableCell>
                      <OrderChannelBadge order={o} />
                    </TableCell>
                    <TableCell>
                      <p className="text-sm">{o.customer_name}</p>
                      <p className="text-xs text-gray-500">
                        {o.customer_phone}
                      </p>
                    </TableCell>
                    <TableCell>{o.restaurant_name}</TableCell>
                    <TableCell className="text-sm">
                      {o.assigned_driver_name ?? "—"}
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant="outline"
                        className={statusBadgeClass(o.status)}
                      >
                        {statusLabel(o.status)}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary">
                        {paymentLabel(o.payment_status)}
                      </Badge>
                    </TableCell>
                    <TableCell>{o.total_amount} ETB</TableCell>
                    <TableCell className="whitespace-nowrap text-xs">
                      {format(new Date(o.placed_at), "MMM d, yyyy HH:mm")}
                    </TableCell>
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setSelectedId(o.id)}
                      >
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

      <Sheet
        open={selectedId != null}
        onOpenChange={(open) => {
          if (!open) {
            setSelectedId(null);
            setDetail(null);
            setPendingStatus("");
          }
        }}
      >
        <SheetContent className="w-full overflow-y-auto sm:max-w-lg">
          <SheetHeader>
            <SheetTitle>
              {detail?.reference ?? (selectedId != null ? `Order #${selectedId}` : "Order details")}
            </SheetTitle>
            {detail ? (
              <div className="mt-2">
                <OrderChannelBadge order={detail} />
              </div>
            ) : null}
          </SheetHeader>
          {detail ? (
            <div className="space-y-4 px-4 pb-6 text-sm">
                <p>
                  <span className="text-gray-500">Status:</span>{" "}
                  <Badge variant="outline" className={statusBadgeClass(detail.status)}>
                    {statusLabel(detail.status)}
                  </Badge>
                </p>
                <p>
                  <span className="text-gray-500">Customer:</span>{" "}
                  {detail.customer_phone}
                </p>
                <p>
                  <span className="text-gray-500">Restaurant:</span>{" "}
                  {detail.restaurant_name}
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
                <Card className="border-[#800020]/20 bg-[#fdf8f9]">
                  <CardHeader className="pb-2">
                    <CardTitle className="flex items-center gap-2 text-base text-[#800020]">
                      <ShieldAlert className="h-4 w-4" />
                      Admin operations
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="space-y-2">
                      <p className="text-xs font-medium text-gray-600">Update order status</p>
                      <div className="flex gap-2">
                        <Select value={pendingStatus} onValueChange={setPendingStatus}>
                          <SelectTrigger className="flex-1 bg-white">
                            <SelectValue placeholder="Select status" />
                          </SelectTrigger>
                          <SelectContent>
                            {ADMIN_MODIFY_STATUSES.map((s) => (
                              <SelectItem key={s} value={s}>
                                {statusLabel(s)}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                        <Button
                          className="bg-[#800020] hover:bg-[#600018]"
                          disabled={
                            statusUpdating ||
                            !pendingStatus ||
                            pendingStatus === detail.status
                          }
                          onClick={() => void applyStatus(pendingStatus)}
                        >
                          {statusUpdating ? "Saving…" : "Apply"}
                        </Button>
                      </div>
                    </div>
                    <div className="flex flex-col gap-2 sm:flex-row">
                      {canModify && (
                        <Button
                          variant="outline"
                          className="flex-1 border-[#800020]/40 text-[#800020] hover:bg-[#fdf8f9]"
                          onClick={() => setModifyDialogOpen(true)}
                        >
                          <Pencil className="h-4 w-4 mr-2" />
                          Modify order
                        </Button>
                      )}
                      {canCancel && (
                        <Button
                          variant="outline"
                          className="flex-1 border-red-300 text-red-700 hover:bg-red-50"
                          onClick={() => setCancelDialogOpen(true)}
                        >
                          Cancel order
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
                <div className="space-y-3 border-t pt-4">
                  {detail.status === "declined" && (
                    <p className="text-sm text-orange-800 bg-orange-50 border border-orange-200 rounded-md px-3 py-2">
                      Driver declined this delivery. Select another online or
                      busy driver to reassign.
                      {detail.assigned_driver_name
                        ? ` (declined by ${detail.assigned_driver_name})`
                        : null}
                    </p>
                  )}
                  <div className="flex gap-2">
                    <Select
                      value={assignDriverId}
                      onValueChange={setAssignDriverId}
                    >
                      <SelectTrigger className="flex-1">
                        <SelectValue
                          placeholder={
                            detail.status === "declined"
                              ? "Reassign driver"
                              : "Assign driver"
                          }
                        />
                      </SelectTrigger>
                      <SelectContent>
                        {assignableDrivers.length === 0 ? (
                          <SelectItem value="__none" disabled>
                            No available drivers
                          </SelectItem>
                        ) : (
                          assignableDrivers.map((d) => (
                            <SelectItem key={d.id} value={String(d.id)}>
                              {d.full_name}
                              {d.operational_status
                                ? ` (${d.operational_status})`
                                : ""}
                            </SelectItem>
                          ))
                        )}
                      </SelectContent>
                    </Select>
                    <Button
                      className="bg-[#800020] hover:bg-[#600018]"
                      disabled={assigning || !assignDriverId}
                      onClick={() => void handleAssign()}
                    >
                      {detail.status === "declined" ? "Reassign" : "Assign"}
                    </Button>
                  </div>
                </div>
              </div>
          ) : (
            <p className="px-4 text-sm text-gray-500">Loading order details…</p>
          )}
        </SheetContent>
      </Sheet>

      <OrderModifyDialog
        order={detail}
        open={modifyDialogOpen}
        onOpenChange={setModifyDialogOpen}
        onSaved={(updated) => {
          setDetail(updated);
          setPendingStatus(updated.status);
          void load();
        }}
      />

      <AlertDialog open={cancelDialogOpen} onOpenChange={setCancelDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Cancel this order?</AlertDialogTitle>
            <AlertDialogDescription>
              This will mark order {detail?.reference} as cancelled.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={statusUpdating}>Keep order</AlertDialogCancel>
            <AlertDialogAction
              className="bg-red-600 hover:bg-red-700"
              disabled={statusUpdating}
              onClick={(e) => {
                e.preventDefault();
                void applyStatus("cancelled");
              }}
            >
              {statusUpdating ? "Cancelling…" : "Confirm cancel"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
