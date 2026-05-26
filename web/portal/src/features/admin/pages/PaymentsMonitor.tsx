"use client";

import { useCallback, useEffect, useState } from "react";
import { format } from "date-fns";
import { Eye, RefreshCw, Search } from "lucide-react";
import { toast } from "sonner";

import {
  fetchPayment,
  fetchPayments,
  paymentStatusBadgeClass,
  paymentStatusLabel,
  type PaymentRecord,
} from "@/services/payments";
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

const STATUS_OPTIONS = [
  "all",
  "pending",
  "success",
  "failed",
  "cancelled",
  "refunded",
];

export function PaymentsMonitor() {
  const [payments, setPayments] = useState<PaymentRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [detail, setDetail] = useState<PaymentRecord | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchPayments({
        status: statusFilter === "all" ? undefined : statusFilter,
        search: search || undefined,
      });
      setPayments(data.results);
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Failed to load payments";
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
    if (selectedId == null) return;
    void fetchPayment(selectedId)
      .then(setDetail)
      .catch((e) =>
        toast.error(e instanceof Error ? e.message : "Failed to load payment"),
      );
  }, [selectedId]);

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold sm:text-3xl">Payments</h1>
          <p className="text-sm text-gray-500">
            Chapa transactions and verification status
          </p>
        </div>
        <Button
          variant="outline"
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
        <CardContent className="flex flex-col gap-3 p-4 sm:flex-row">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <Input
              className="pl-9"
              placeholder="Search tx ref, order ref, phone…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-full sm:w-48">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              {STATUS_OPTIONS.map((s) => (
                <SelectItem key={s} value={s}>
                  {s === "all" ? "All statuses" : paymentStatusLabel(s)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-0">
          {error ? (
            <p className="p-6 text-center text-red-600">{error}</p>
          ) : loading && payments.length === 0 ? (
            <p className="p-6 text-center text-gray-500">Loading payments…</p>
          ) : payments.length === 0 ? (
            <p className="p-6 text-center text-gray-500">No payments found</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Transaction ref</TableHead>
                  <TableHead>Order</TableHead>
                  <TableHead>Customer</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Method</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {payments.map((p) => (
                  <TableRow key={p.id}>
                    <TableCell className="font-mono text-xs">
                      {p.chapa_tx_ref}
                    </TableCell>
                    <TableCell>{p.order_reference}</TableCell>
                    <TableCell>{p.customer_phone}</TableCell>
                    <TableCell>
                      {p.amount} {p.currency}
                    </TableCell>
                    <TableCell>{p.payment_method || "—"}</TableCell>
                    <TableCell>
                      <Badge
                        className={paymentStatusBadgeClass(p.status)}
                        variant="outline"
                      >
                        {paymentStatusLabel(p.status)}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-sm text-gray-600">
                      {p.paid_at
                        ? format(new Date(p.paid_at), "MMM d, HH:mm")
                        : format(new Date(p.created_at), "MMM d, HH:mm")}
                    </TableCell>
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => setSelectedId(p.id)}
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <Sheet
        open={selectedId != null}
        onOpenChange={(open) => {
          if (!open) {
            setSelectedId(null);
            setDetail(null);
          }
        }}
      >
        <SheetContent className="overflow-y-auto sm:max-w-md">
          <SheetHeader>
            <SheetTitle>Payment details</SheetTitle>
          </SheetHeader>
          {detail && (
            <dl className="space-y-3 px-4 pb-6 text-sm">
              <div>
                <dt className="text-gray-500">Transaction ref</dt>
                <dd className="font-mono">{detail.chapa_tx_ref}</dd>
              </div>
              <div>
                <dt className="text-gray-500">Chapa reference</dt>
                <dd>{detail.chapa_reference || "—"}</dd>
              </div>
              <div>
                <dt className="text-gray-500">Order</dt>
                <dd>
                  {detail.order_reference} (#{detail.order})
                </dd>
              </div>
              <div>
                <dt className="text-gray-500">Customer</dt>
                <dd>{detail.customer_phone}</dd>
              </div>
              <div>
                <dt className="text-gray-500">Amount</dt>
                <dd>
                  {detail.amount} {detail.currency}
                </dd>
              </div>
              <div>
                <dt className="text-gray-500">Status</dt>
                <dd>
                  <Badge
                    className={paymentStatusBadgeClass(detail.status)}
                    variant="outline"
                  >
                    {paymentStatusLabel(detail.status)}
                  </Badge>
                </dd>
              </div>
              <div>
                <dt className="text-gray-500">Paid at</dt>
                <dd>
                  {detail.paid_at
                    ? format(new Date(detail.paid_at), "PPpp")
                    : "—"}
                </dd>
              </div>
              <div>
                <dt className="text-gray-500">Created</dt>
                <dd>{format(new Date(detail.created_at), "PPpp")}</dd>
              </div>
            </dl>
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
}
