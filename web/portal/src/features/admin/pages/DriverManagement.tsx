"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { format } from "date-fns";
import { toast } from "sonner";

import {
  approveDriver,
  fetchApprovedDriversAdmin,
  fetchDriverBalances,
  fetchPendingDrivers,
  fetchSuspendedDrivers,
  reactivateDriver,
  rejectDriver,
  suspendDriver,
  updateDriverPayoutPercentage,
  type ApprovedDriver,
  type PendingDriver,
  type SuspendedDriver,
} from "@/services/drivers";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { DriverDocumentsDialog } from "../components/DriverDocumentsDialog";

type DialogAction = "reject" | "suspend" | "reactivate" | null;

export function DriverManagement() {
  const [pending, setPending] = useState<PendingDriver[]>([]);
  const [suspended, setSuspended] = useState<SuspendedDriver[]>([]);
  const [approved, setApproved] = useState<ApprovedDriver[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialog, setDialog] = useState<{
    open: boolean;
    userId: number | null;
    action: DialogAction;
    reason: string;
  }>({ open: false, userId: null, action: null, reason: "" });
  const [documentsDialog, setDocumentsDialog] = useState<{
    open: boolean;
    userId: number | null;
    driverName: string;
  }>({ open: false, userId: null, driverName: "" });
  const [editingPayout, setEditingPayout] = useState<{ driverId: number; value: string } | null>(null);
  const [balances, setBalances] = useState<Record<string, string>>({});

  type AllDriver = { id: number; name: string; phone: string; status: string; vehicle_type: string };
  const allDrivers: AllDriver[] = useMemo(() => [
    ...approved.map((d) => ({ id: d.id, name: d.full_name, phone: d.phone, status: "approved", vehicle_type: d.vehicle_type })),
    ...pending.map((d) => ({ id: d.user_id, name: d.full_name, phone: d.phone, status: "pending", vehicle_type: "" })),
    ...suspended.map((d) => ({ id: d.user_id, name: d.full_name, phone: d.phone, status: "suspended", vehicle_type: d.vehicle_type })),
  ], [approved, pending, suspended]);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [p, s, a, b] = await Promise.all([
        fetchPendingDrivers(),
        fetchSuspendedDrivers(),
        fetchApprovedDriversAdmin(),
        fetchDriverBalances(),
      ]);
      setPending(p);
      setSuspended(s);
      setApproved(a);
      setBalances(b);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Failed to load drivers");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void load();
  }, [load]);

  const handleApprove = async (userId: number) => {
    try {
      await approveDriver(userId);
      toast.success("Driver approved");
      await load();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Approve failed");
    }
  };

  const handleReactivate = async (userId: number) => {
    try {
      await reactivateDriver(userId);
      toast.success("Driver reactivated and moved to approved");
      setDialog({ open: false, userId: null, action: null, reason: "" });
      await load();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Reactivate failed");
    }
  };

  const confirmReasonAction = async () => {
    if (dialog.userId == null || !dialog.action || !dialog.reason.trim()) return;
    try {
      if (dialog.action === "reject") {
        await rejectDriver(dialog.userId, dialog.reason.trim());
        toast.success("Driver rejected");
      } else if (dialog.action === "suspend") {
        await suspendDriver(dialog.userId, dialog.reason.trim());
        toast.success("Driver suspended");
      }
      setDialog({ open: false, userId: null, action: null, reason: "" });
      await load();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Action failed");
    }
  };

  const confirmDialogAction = async () => {
    if (dialog.userId == null || !dialog.action) return;
    if (dialog.action === "reactivate") {
      await handleReactivate(dialog.userId);
      return;
    }
    await confirmReasonAction();
  };

  const savePayout = async (driverId: number, value: string) => {
    const num = parseFloat(value);
    if (isNaN(num) || num < 0 || num > 100) {
      toast.error("Percentage must be between 0 and 100");
      return;
    }
    try {
      const res = await updateDriverPayoutPercentage(driverId, num);
      setApproved((prev) =>
        prev.map((d) => (d.id === driverId ? { ...d, payout_percentage: res.payout_percentage } : d)),
      );
      toast.success("Payout percentage updated");
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Update failed");
    }
    setEditingPayout(null);
  };

  const dialogTitle =
    dialog.action === "reject"
      ? "Reject driver"
      : dialog.action === "suspend"
        ? "Suspend driver"
        : dialog.action === "reactivate"
          ? "Reactivate driver"
          : "";

  const needsReason = dialog.action === "reject" || dialog.action === "suspend";

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-gray-900">Driver Management</h1>
        <p className="mt-1 text-gray-600">Approve onboarding and monitor operational drivers.</p>
      </div>

      <Tabs defaultValue="all">
        <TabsList>
          <TabsTrigger value="all">All ({allDrivers.length})</TabsTrigger>
          <TabsTrigger value="pending">Pending ({pending.length})</TabsTrigger>
          <TabsTrigger value="suspended">Suspended ({suspended.length})</TabsTrigger>
          <TabsTrigger value="approved">Approved ({approved.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="all">
          <Card>
            <CardContent className="p-0 overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Phone</TableHead>
                    <TableHead>Vehicle</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Balance</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={5}>Loading...</TableCell>
                    </TableRow>
                  ) : allDrivers.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5}>No drivers</TableCell>
                    </TableRow>
                  ) : (
                    allDrivers.map((d) => (
                      <TableRow key={`${d.status}-${d.id}`}>
                        <TableCell className="font-medium">{d.name || "—"}</TableCell>
                        <TableCell>{d.phone}</TableCell>
                        <TableCell>{d.vehicle_type || "—"}</TableCell>
                        <TableCell>
                          <Badge
                            variant="outline"
                            className={
                              d.status === "approved"
                                ? "bg-green-100 text-green-800 border-green-200"
                                : d.status === "suspended"
                                  ? "bg-red-100 text-red-800 border-red-200"
                                  : "bg-amber-100 text-amber-800 border-amber-200"
                            }
                          >
                            {d.status.charAt(0).toUpperCase() + d.status.slice(1)}
                          </Badge>
                        </TableCell>
                        <TableCell>{balances[String(d.id)] ?? "0.00"} ETB</TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="pending">
          <Card>
            <CardContent className="p-0 overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Phone</TableHead>
                    <TableHead>Registered</TableHead>
                    <TableHead>Files</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={5}>Loading...</TableCell>
                    </TableRow>
                  ) : pending.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5}>No pending drivers</TableCell>
                    </TableRow>
                  ) : (
                    pending.map((d) => (
                      <TableRow key={d.user_id}>
                        <TableCell className="font-medium">{d.full_name || "—"}</TableCell>
                        <TableCell>{d.phone}</TableCell>
                        <TableCell>
                          {d.created_at ? format(new Date(d.created_at), "MMM d, yyyy") : "—"}
                        </TableCell>
                        <TableCell>
                          <Button
                            size="sm"
                            variant="outline"
                            disabled={d.uploaded_document_count === 0}
                            onClick={() =>
                              setDocumentsDialog({
                                open: true,
                                userId: d.user_id,
                                driverName: d.full_name || d.phone,
                              })
                            }
                          >
                            Uploaded files ({d.uploaded_document_count})
                          </Button>
                        </TableCell>
                        <TableCell className="space-x-2">
                          <Button size="sm" onClick={() => void handleApprove(d.user_id)}>
                            Approve
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() =>
                              setDialog({
                                open: true,
                                userId: d.user_id,
                                action: "reject",
                                reason: "",
                              })
                            }
                          >
                            Reject
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="suspended">
          <Card>
            <CardContent className="p-0 overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Phone</TableHead>
                    <TableHead>Vehicle</TableHead>
                    <TableHead>Suspended</TableHead>
                    <TableHead>Reason</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={6}>Loading...</TableCell>
                    </TableRow>
                  ) : suspended.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6}>No suspended accounts</TableCell>
                    </TableRow>
                  ) : (
                    suspended.map((d) => (
                      <TableRow key={d.user_id}>
                        <TableCell className="font-medium">{d.full_name || "—"}</TableCell>
                        <TableCell>{d.phone}</TableCell>
                        <TableCell>{d.vehicle_type || "—"}</TableCell>
                        <TableCell>
                          {d.suspended_at
                            ? format(new Date(d.suspended_at), "MMM d, yyyy")
                            : "—"}
                        </TableCell>
                        <TableCell className="max-w-xs truncate" title={d.suspension_reason}>
                          {d.suspension_reason || "—"}
                        </TableCell>
                        <TableCell>
                          <Button
                            size="sm"
                            onClick={() =>
                              setDialog({
                                open: true,
                                userId: d.user_id,
                                action: "reactivate",
                                reason: "",
                              })
                            }
                          >
                            Reactivate
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="approved">
          <Card>
            <CardContent className="p-0 overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Phone</TableHead>
                    <TableHead>Vehicle</TableHead>
                    <TableHead>Availability</TableHead>
                    <TableHead>Payout %</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={6}>Loading...</TableCell>
                    </TableRow>
                  ) : approved.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6}>No approved drivers</TableCell>
                    </TableRow>
                  ) : (
                    approved.map((d) => (
                      <TableRow key={d.id}>
                        <TableCell className="font-medium">{d.full_name}</TableCell>
                        <TableCell>{d.phone}</TableCell>
                        <TableCell>{d.vehicle_type || "—"}</TableCell>
                        <TableCell>
                          <Badge variant="outline">{d.operational_status}</Badge>
                        </TableCell>
                        <TableCell>
                          {editingPayout?.driverId === d.id ? (
                            <Input
                              type="number"
                              min={0}
                              max={100}
                              step={1}
                              className="h-8 w-20"
                              autoFocus
                              value={editingPayout.value}
                              onChange={(e) =>
                                setEditingPayout({ driverId: d.id, value: e.target.value })
                              }
                              onBlur={() => void savePayout(d.id, editingPayout.value)}
                              onKeyDown={(e) => {
                                if (e.key === "Enter") void savePayout(d.id, editingPayout.value);
                                if (e.key === "Escape") setEditingPayout(null);
                              }}
                            />
                          ) : (
                            <button
                              type="button"
                              className="rounded px-2 py-1 text-sm hover:bg-gray-100"
                              onClick={() =>
                                setEditingPayout({ driverId: d.id, value: d.payout_percentage })
                              }
                            >
                              {parseFloat(d.payout_percentage)}%
                            </button>
                          )}
                        </TableCell>
                        <TableCell>
                          <Button
                            size="sm"
                            variant="destructive"
                            onClick={() =>
                              setDialog({
                                open: true,
                                userId: d.id,
                                action: "suspend",
                                reason: "",
                              })
                            }
                          >
                            Suspend
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
          <p className="text-sm text-muted-foreground mt-2">
            Only drivers currently <strong>online</strong> appear in the assignment dropdown on
            Orders Monitor.
          </p>
        </TabsContent>
      </Tabs>

      <DriverDocumentsDialog
        userId={documentsDialog.userId}
        driverName={documentsDialog.driverName}
        open={documentsDialog.open}
        onOpenChange={(open) =>
          setDocumentsDialog((prev) => ({
            ...prev,
            open,
            ...(open ? {} : { userId: null, driverName: "" }),
          }))
        }
      />

      <Dialog
        open={dialog.open}
        onOpenChange={(open) =>
          !open && setDialog({ open: false, userId: null, action: null, reason: "" })
        }
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{dialogTitle}</DialogTitle>
            {dialog.action === "reactivate" && (
              <DialogDescription>
                This will restore the driver to <strong>approved</strong> status so they can sign
                in and accept deliveries again.
              </DialogDescription>
            )}
          </DialogHeader>
          {needsReason && (
            <div className="space-y-2">
              <Label htmlFor="reason">Reason</Label>
              <Textarea
                id="reason"
                value={dialog.reason}
                onChange={(e) => setDialog((d) => ({ ...d, reason: e.target.value }))}
              />
            </div>
          )}
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDialog({ open: false, userId: null, action: null, reason: "" })}
            >
              Cancel
            </Button>
            <Button
              onClick={() => void confirmDialogAction()}
              disabled={needsReason && !dialog.reason.trim()}
            >
              Confirm
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
