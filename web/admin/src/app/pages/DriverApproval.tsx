import { useState } from "react";
import { Card, CardContent } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../components/ui/tabs";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "../components/ui/dialog";
import { Textarea } from "../components/ui/textarea";
import { Label } from "../components/ui/label";
import { StatusBadge, DriverStatus } from "../components/StatusBadge";
import { mockDrivers, Driver } from "../data/mockData";
import { format } from "date-fns";
import { CheckCircle, XCircle, Ban, RotateCcw, Eye } from "lucide-react";

export function DriverApproval() {
  const [selectedDriver, setSelectedDriver] = useState<Driver | null>(null);
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    action: "approve" | "reject" | "suspend" | "reactivate" | null;
    reason: string;
  }>({ open: false, action: null, reason: "" });

  const getDriversByStatus = (status: DriverStatus) => {
    return mockDrivers.filter((d) => d.status === status);
  };

  const handleAction = (action: "approve" | "reject" | "suspend" | "reactivate") => {
    setActionDialog({ open: true, action, reason: "" });
  };

  const confirmAction = () => {
    // Handle the action here
    console.log(`${actionDialog.action} driver:`, selectedDriver?.id);
    setActionDialog({ open: false, action: null, reason: "" });
    setSelectedDriver(null);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-gray-900">Driver Approval</h1>
        <p className="text-gray-600 mt-1">
          Review and manage driver onboarding applications
        </p>
      </div>

      <Tabs defaultValue="submitted" className="space-y-6">
        <TabsList>
          <TabsTrigger value="submitted">
            Docs Submitted ({getDriversByStatus("DocsSubmitted").length})
          </TabsTrigger>
          <TabsTrigger value="review">
            Under Review ({getDriversByStatus("UnderReview").length})
          </TabsTrigger>
          <TabsTrigger value="approved">
            Approved ({getDriversByStatus("Approved").length})
          </TabsTrigger>
          <TabsTrigger value="rejected">
            Rejected ({getDriversByStatus("Rejected").length})
          </TabsTrigger>
          <TabsTrigger value="suspended">
            Suspended ({getDriversByStatus("Suspended").length})
          </TabsTrigger>
        </TabsList>

        <TabsContent value="submitted">
          <DriverTable
            drivers={getDriversByStatus("DocsSubmitted")}
            onSelect={setSelectedDriver}
          />
        </TabsContent>
        <TabsContent value="review">
          <DriverTable
            drivers={getDriversByStatus("UnderReview")}
            onSelect={setSelectedDriver}
          />
        </TabsContent>
        <TabsContent value="approved">
          <DriverTable
            drivers={getDriversByStatus("Approved")}
            onSelect={setSelectedDriver}
          />
        </TabsContent>
        <TabsContent value="rejected">
          <DriverTable
            drivers={getDriversByStatus("Rejected")}
            onSelect={setSelectedDriver}
          />
        </TabsContent>
        <TabsContent value="suspended">
          <DriverTable
            drivers={getDriversByStatus("Suspended")}
            onSelect={setSelectedDriver}
          />
        </TabsContent>
      </Tabs>

      {/* Driver Details Dialog */}
      <Dialog open={!!selectedDriver} onOpenChange={() => setSelectedDriver(null)}>
        <DialogContent className="max-w-2xl">
          {selectedDriver && (
            <>
              <DialogHeader>
                <DialogTitle>{selectedDriver.fullName}</DialogTitle>
                <DialogDescription>
                  Review driver application details and documents
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-6">
                {/* Driver Info */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label className="text-gray-600">Phone</Label>
                    <p className="font-medium">{selectedDriver.phone}</p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Vehicle Type</Label>
                    <p className="font-medium">{selectedDriver.vehicleType}</p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Submitted Date</Label>
                    <p className="font-medium">
                      {format(selectedDriver.submittedDate, "MMM dd, yyyy")}
                    </p>
                  </div>
                  <div>
                    <Label className="text-gray-600">Status</Label>
                    <div className="mt-1">
                      <StatusBadge status={selectedDriver.status} type="driver" />
                    </div>
                  </div>
                  <div>
                    <Label className="text-gray-600">Online Status</Label>
                    <p className="font-medium">
                      {selectedDriver.isOnline ? (
                        <span className="text-green-600">Online</span>
                      ) : (
                        <span className="text-gray-500">Offline</span>
                      )}
                    </p>
                  </div>
                </div>

                {/* Documents */}
                <div>
                  <Label>Documents</Label>
                  <div className="grid grid-cols-3 gap-3 mt-2">
                    <div className="border border-gray-200 rounded-lg p-4 text-center">
                      <div className="w-full h-32 bg-gray-100 rounded mb-2 flex items-center justify-center">
                        <Eye className="w-8 h-8 text-gray-400" />
                      </div>
                      <p className="text-sm font-medium">Driver License</p>
                      <p className="text-xs text-gray-500">
                        {selectedDriver.documents.license}
                      </p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4 text-center">
                      <div className="w-full h-32 bg-gray-100 rounded mb-2 flex items-center justify-center">
                        <Eye className="w-8 h-8 text-gray-400" />
                      </div>
                      <p className="text-sm font-medium">ID Card</p>
                      <p className="text-xs text-gray-500">
                        {selectedDriver.documents.id}
                      </p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4 text-center">
                      <div className="w-full h-32 bg-gray-100 rounded mb-2 flex items-center justify-center">
                        <Eye className="w-8 h-8 text-gray-400" />
                      </div>
                      <p className="text-sm font-medium">Vehicle Registration</p>
                      <p className="text-xs text-gray-500">
                        {selectedDriver.documents.vehicle}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Notes */}
                <div>
                  <Label>Internal Notes</Label>
                  <Textarea
                    value={selectedDriver.notes}
                    readOnly
                    className="mt-2"
                    rows={3}
                  />
                </div>
              </div>
              <DialogFooter className="flex gap-2">
                {selectedDriver.status === "DocsSubmitted" ||
                selectedDriver.status === "UnderReview" ? (
                  <>
                    <Button
                      variant="outline"
                      className="text-red-600 border-red-600 hover:bg-red-50"
                      onClick={() => handleAction("reject")}
                    >
                      <XCircle className="w-4 h-4 mr-2" />
                      Reject
                    </Button>
                    <Button
                      className="bg-green-600 hover:bg-green-700"
                      onClick={() => handleAction("approve")}
                    >
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Approve
                    </Button>
                  </>
                ) : selectedDriver.status === "Approved" ? (
                  <Button
                    variant="outline"
                    className="text-orange-600 border-orange-600 hover:bg-orange-50"
                    onClick={() => handleAction("suspend")}
                  >
                    <Ban className="w-4 h-4 mr-2" />
                    Suspend
                  </Button>
                ) : selectedDriver.status === "Suspended" ? (
                  <Button
                    className="bg-[#800020] hover:bg-[#600018]"
                    onClick={() => handleAction("reactivate")}
                  >
                    <RotateCcw className="w-4 h-4 mr-2" />
                    Reactivate
                  </Button>
                ) : null}
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* Action Confirmation Dialog */}
      <Dialog
        open={actionDialog.open}
        onOpenChange={(open) =>
          setActionDialog({ ...actionDialog, open })
        }
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {actionDialog.action === "approve" && "Approve Driver"}
              {actionDialog.action === "reject" && "Reject Driver"}
              {actionDialog.action === "suspend" && "Suspend Driver"}
              {actionDialog.action === "reactivate" && "Reactivate Driver"}
            </DialogTitle>
            <DialogDescription>
              {actionDialog.action === "approve" &&
                "Are you sure you want to approve this driver?"}
              {actionDialog.action === "reject" &&
                "Are you sure you want to reject this driver?"}
              {actionDialog.action === "suspend" &&
                "Are you sure you want to suspend this driver?"}
              {actionDialog.action === "reactivate" &&
                "Are you sure you want to reactivate this driver?"}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <p>
              Are you sure you want to {actionDialog.action}{" "}
              <strong>{selectedDriver?.fullName}</strong>?
            </p>
            {(actionDialog.action === "reject" ||
              actionDialog.action === "suspend") && (
              <div>
                <Label>Reason (Required)</Label>
                <Textarea
                  value={actionDialog.reason}
                  onChange={(e) =>
                    setActionDialog({ ...actionDialog, reason: e.target.value })
                  }
                  placeholder="Enter reason for this action..."
                  rows={4}
                  className="mt-2"
                />
              </div>
            )}
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() =>
                setActionDialog({ open: false, action: null, reason: "" })
              }
            >
              Cancel
            </Button>
            <Button
              className={
                actionDialog.action === "approve"
                  ? "bg-green-600 hover:bg-green-700"
                  : actionDialog.action === "reject"
                  ? "bg-red-600 hover:bg-red-700"
                  : "bg-[#800020] hover:bg-[#600018]"
              }
              onClick={confirmAction}
              disabled={
                (actionDialog.action === "reject" ||
                  actionDialog.action === "suspend") &&
                !actionDialog.reason
              }
            >
              Confirm
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function DriverTable({
  drivers,
  onSelect,
}: {
  drivers: Driver[];
  onSelect: (driver: Driver) => void;
}) {
  if (drivers.length === 0) {
    return (
      <Card>
        <CardContent className="p-12 text-center">
          <p className="text-gray-500">No drivers in this category</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardContent className="p-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Full Name</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Vehicle Type</TableHead>
              <TableHead>Submitted Date</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Online</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {drivers.map((driver) => (
              <TableRow key={driver.id}>
                <TableCell className="font-medium">{driver.fullName}</TableCell>
                <TableCell>{driver.phone}</TableCell>
                <TableCell>{driver.vehicleType}</TableCell>
                <TableCell>
                  {format(driver.submittedDate, "MMM dd, yyyy")}
                </TableCell>
                <TableCell>
                  <StatusBadge status={driver.status} type="driver" />
                </TableCell>
                <TableCell>
                  {driver.isOnline ? (
                    <span className="text-green-600 text-sm">Online</span>
                  ) : (
                    <span className="text-gray-400 text-sm">Offline</span>
                  )}
                </TableCell>
                <TableCell>
                  <Button variant="ghost" size="sm" onClick={() => onSelect(driver)}>
                    <Eye className="w-4 h-4" />
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}