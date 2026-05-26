"use client";

import { useCallback, useEffect, useState } from "react";
import { format } from "date-fns";
import { AlertCircle, Bike, CheckCircle2, Search } from "lucide-react";
import { toast } from "sonner";

import { parseApiError, statusBadgeClass, statusLabel } from "@/lib/order-utils";
import {
  assignDriver,
  fetchApprovedDrivers,
  fetchOrders,
  type OrderRecord,
} from "@/services/orders";
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

type ApprovedDriver = { id: number; full_name: string; phone: string };

export function AssignDriverPage() {
  const [orders, setOrders] = useState<OrderRecord[]>([]);
  const [drivers, setDrivers] = useState<ApprovedDriver[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [selectedOrderId, setSelectedOrderId] = useState<number | null>(null);
  const [selectedDriverId, setSelectedDriverId] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [orderData, driverRows] = await Promise.all([
        fetchOrders({ assigned: "false", search: search || undefined }),
        fetchApprovedDrivers({ includeBusy: true }),
      ]);
      setOrders(
        orderData.results.filter(
          (o) => o.status !== "delivered" && o.status !== "cancelled",
        ),
      );
      setDrivers(driverRows);
    } catch (e) {
      const msg = parseApiError(e, "Failed to load data");
      setError(msg);
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  }, [search]);

  useEffect(() => {
    const t = setTimeout(() => void load(), 300);
    return () => clearTimeout(t);
  }, [load]);

  const selectedOrder = orders.find((o) => o.id === selectedOrderId) ?? null;

  const handleAssign = async () => {
    if (selectedOrderId == null || !selectedDriverId) {
      toast.error("Select an order and a driver");
      return;
    }
    setSubmitting(true);
    try {
      await assignDriver(selectedOrderId, Number(selectedDriverId));
      toast.success("Driver assigned successfully");
      setSelectedOrderId(null);
      setSelectedDriverId("");
      await load();
    } catch (e) {
      toast.error(parseApiError(e, "Assignment failed"));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold sm:text-3xl">Assign Driver</h1>
        <p className="mt-1 text-muted-foreground">
          Match unassigned orders with approved drivers
        </p>
      </div>

      <Card>
        <CardContent className="p-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <Input
              className="pl-10"
              placeholder="Search orders..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardContent className="p-4">
            <h2 className="mb-4 font-semibold">Unassigned orders</h2>
            {loading ? (
              <p className="text-sm text-muted-foreground">Loading...</p>
            ) : error ? (
              <div className="space-y-2 text-center py-6">
                <AlertCircle className="mx-auto h-8 w-8 text-destructive" />
                <p className="text-sm text-destructive">{error}</p>
                <Button variant="outline" size="sm" onClick={() => void load()}>
                  Retry
                </Button>
              </div>
            ) : orders.length === 0 ? (
              <p className="text-sm text-muted-foreground py-6 text-center">
                No unassigned orders right now
              </p>
            ) : (
              <ul className="space-y-2 max-h-[480px] overflow-y-auto">
                {orders.map((order) => (
                  <li key={order.id}>
                    <button
                      type="button"
                      onClick={() => setSelectedOrderId(order.id)}
                      className={`w-full rounded-lg border p-3 text-left transition ${
                        selectedOrderId === order.id
                          ? "border-[#800020] bg-[#800020]/5"
                          : "border-border hover:bg-muted/50"
                      }`}
                    >
                      <div className="flex items-start justify-between gap-2">
                        <div>
                          <p className="font-medium">{order.reference}</p>
                          <p className="text-sm text-muted-foreground">
                            {order.customer_name} · {order.restaurant_name}
                          </p>
                          <p className="text-xs text-muted-foreground mt-1">
                            {format(new Date(order.placed_at), "MMM d, HH:mm")} ·{" "}
                            {order.total_amount} ETB
                          </p>
                        </div>
                        <Badge variant="outline" className={statusBadgeClass(order.status)}>
                          {statusLabel(order.status)}
                        </Badge>
                      </div>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4 space-y-4">
            <h2 className="font-semibold">Select driver</h2>
            {selectedOrder ? (
              <div className="rounded-lg border p-3 text-sm bg-muted/30">
                <p className="font-medium">{selectedOrder.reference}</p>
                <p className="text-muted-foreground">{selectedOrder.restaurant_name}</p>
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">Select an order from the list</p>
            )}

            <Select
              value={selectedDriverId}
              onValueChange={setSelectedDriverId}
              disabled={!selectedOrder || submitting}
            >
              <SelectTrigger>
                <SelectValue placeholder="Approved driver" />
              </SelectTrigger>
              <SelectContent>
                {drivers.map((d) => (
                  <SelectItem key={d.id} value={String(d.id)}>
                    <span className="flex items-center gap-2">
                      <Bike className="h-4 w-4" />
                      {d.full_name} ({d.phone})
                    </span>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {drivers.length === 0 && !loading && (
              <p className="text-sm text-amber-700 flex items-center gap-1">
                <AlertCircle className="h-4 w-4" />
                No approved drivers available
              </p>
            )}

            <Button
              className="w-full bg-[#800020] hover:bg-[#600018]"
              disabled={!selectedOrder || !selectedDriverId || submitting}
              onClick={() => void handleAssign()}
            >
              <CheckCircle2 className="mr-2 h-4 w-4" />
              {submitting ? "Assigning..." : "Assign driver"}
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
