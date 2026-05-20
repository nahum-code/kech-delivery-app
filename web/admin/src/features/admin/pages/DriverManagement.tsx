"use client";

import { useCallback, useEffect, useState } from "react";
import { format } from "date-fns";
import { toast } from "sonner";

import {
  approveDriver,
  fetchApprovedDriversAdmin,
  fetchPendingDrivers,
  rejectDriver,
  suspendDriver,
  type ApprovedDriver,
  type PendingDriver,
} from "@/services/drivers";
import { Badge } from "../components/ui/badge";
import { Button } from "../components/ui/button";
import { Card, CardContent } from "../components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "../components/ui/dialog";
import { Label } from "../components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import { Textarea } from "../components/ui/textarea";

export function DriverManagement() {
  const [pending, setPending] = useState<PendingDriver[]>([]);
  const [approved, setApproved] = useState<ApprovedDriver[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialog, setDialog] = useState<{
    open: boolean;
    userId: number | null;
    action: "reject" | "suspend" | null;
    reason: string;
  }>({ open: false, userId: null, action: null, reason: "" });

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [p, a] = await Promise.all([fetchPendingDrivers(), fetchApprovedDriversAdmin()]);
      setPending(p);
      setApproved(a);
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

  const confirmReasonAction = async () => {
    if (dialog.userId == null || !dialog.action || !dialog.reason.trim()) return;
    try {
      if (dialog.action === "reject") {
        await rejectDriver(dialog.userId, dialog.reason.trim());
        toast.success("Driver rejected");
      } else {
        await suspendDriver(dialog.userId, dialog.reason.trim());
        toast.success("Driver suspended");
      }
      setDialog({ open: false, userId: null, action: null, reason: "" });
      await load();
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Action failed");
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-gray-900">Driver Management</h1>
        <p className="mt-1 text-gray-600">Approve onboarding and monitor operational drivers.</p>
      </div>

      <Tabs defaultValue="pending">
        <TabsList>
          <TabsTrigger value="pending">Pending ({pending.length})</TabsTrigger>
          <TabsTrigger value="approved">Approved ({approved.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="pending">
          <Card>
            <CardContent className="p-0 overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Phone</TableHead>
                    <TableHead>Registered</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={4}>Loading...</TableCell>
                    </TableRow>
                  ) : pending.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={4}>No pending drivers</TableCell>
                    </TableRow>
                  ) : (
                    pending.map((d) => (
                      <TableRow key={d.user_id}>
                        <TableCell className="font-medium">{d.full_name || "—"}</TableCell>
                        <TableCell>{d.phone}</TableCell>
                        <TableCell>
                          {d.created_at ? format(new Date(d.created_at), "MMM d, yyyy") : "—"}
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
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={5}>Loading...</TableCell>
                    </TableRow>
                  ) : approved.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5}>No approved drivers</TableCell>
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

      <Dialog
        open={dialog.open}
        onOpenChange={(open) => !open && setDialog({ open: false, userId: null, action: null, reason: "" })}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {dialog.action === "reject" ? "Reject driver" : "Suspend driver"}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-2">
            <Label htmlFor="reason">Reason</Label>
            <Textarea
              id="reason"
              value={dialog.reason}
              onChange={(e) => setDialog((d) => ({ ...d, reason: e.target.value }))}
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialog({ open: false, userId: null, action: null, reason: "" })}>
              Cancel
            </Button>
            <Button onClick={() => void confirmReasonAction()}>Confirm</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
