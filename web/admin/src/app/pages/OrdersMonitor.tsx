import { useState } from "react";
import { Card, CardContent } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../components/ui/table";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "../components/ui/sheet";
import { StatusBadge } from "../components/StatusBadge";
import { mockOrders, Order } from "../data/mockData";
import { Search, Filter, Download, Eye, UserPlus, Phone, X } from "lucide-react";
import { format } from "date-fns";

export function OrdersMonitor() {
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [paymentFilter, setPaymentFilter] = useState<string>("all");

  const filteredOrders = mockOrders.filter((order) => {
    if (statusFilter !== "all" && order.status !== statusFilter) return false;
    if (paymentFilter !== "all" && order.paymentState !== paymentFilter)
      return false;
    return true;
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-gray-900">
            Orders Monitor
          </h1>
          <p className="text-gray-600 mt-1">
            Real-time control center for all delivery operations
          </p>
        </div>
        <Button className="bg-[#800020] hover:bg-[#600018]">
          <Download className="w-4 h-4 mr-2" />
          Export
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-wrap gap-4">
            <div className="flex-1 min-w-[200px]">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <Input
                  placeholder="Search by order number, customer, restaurant..."
                  className="pl-10"
                />
              </div>
            </div>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Statuses</SelectItem>
                <SelectItem value="PaymentPending">Payment Pending</SelectItem>
                <SelectItem value="SearchingDriver">Searching Driver</SelectItem>
                <SelectItem value="Assigned">Assigned</SelectItem>
                <SelectItem value="PickedUp">Picked Up</SelectItem>
                <SelectItem value="Delivered">Delivered</SelectItem>
              </SelectContent>
            </Select>
            <Select value={paymentFilter} onValueChange={setPaymentFilter}>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Payment" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Payments</SelectItem>
                <SelectItem value="Pending">Pending</SelectItem>
                <SelectItem value="Confirmed">Confirmed</SelectItem>
                <SelectItem value="Failed">Failed</SelectItem>
              </SelectContent>
            </Select>
            <Button variant="outline">
              <Filter className="w-4 h-4 mr-2" />
              More Filters
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Orders Table */}
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Order Number</TableHead>
                <TableHead>Customer</TableHead>
                <TableHead>Restaurant</TableHead>
                <TableHead>Driver</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Payment</TableHead>
                <TableHead>Created</TableHead>
                <TableHead>Distance</TableHead>
                <TableHead>Fees</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredOrders.map((order) => (
                <TableRow key={order.id}>
                  <TableCell className="font-medium">
                    {order.orderNumber}
                  </TableCell>
                  <TableCell>{order.customer}</TableCell>
                  <TableCell>{order.restaurant}</TableCell>
                  <TableCell>
                    {order.driver || (
                      <span className="text-gray-400">Unassigned</span>
                    )}
                  </TableCell>
                  <TableCell>
                    <StatusBadge status={order.status} type="order" />
                  </TableCell>
                  <TableCell>
                    <span
                      className={`text-sm ${
                        order.paymentState === "Confirmed"
                          ? "text-green-600"
                          : order.paymentState === "Failed"
                          ? "text-red-600"
                          : "text-yellow-600"
                      }`}
                    >
                      {order.paymentState}
                    </span>
                  </TableCell>
                  <TableCell>{format(order.createdAt, "HH:mm")}</TableCell>
                  <TableCell>{order.distance}</TableCell>
                  <TableCell>{order.deliveryFee} MAD</TableCell>
                  <TableCell>
                    <div className="flex gap-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setSelectedOrder(order)}
                      >
                        <Eye className="w-4 h-4" />
                      </Button>
                      {!order.driver && (
                        <Button variant="ghost" size="sm">
                          <UserPlus className="w-4 h-4" />
                        </Button>
                      )}
                      <Button variant="ghost" size="sm">
                        <Phone className="w-4 h-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Order Details Drawer */}
      <Sheet open={!!selectedOrder} onOpenChange={() => setSelectedOrder(null)}>
        <SheetContent className="w-[500px] overflow-y-auto">
          {selectedOrder && (
            <>
              <SheetHeader>
                <SheetTitle>{selectedOrder.orderNumber}</SheetTitle>
              </SheetHeader>
              <div className="mt-6 space-y-6">
                {/* Order Timeline */}
                <div>
                  <h3 className="font-medium mb-3">Order Timeline</h3>
                  <div className="space-y-3">
                    {selectedOrder.timeline.map((event, index) => (
                      <div key={index} className="flex gap-3">
                        <div className="flex flex-col items-center">
                          <div className="w-3 h-3 rounded-full bg-[#800020]"></div>
                          {index < selectedOrder.timeline.length - 1 && (
                            <div className="w-0.5 h-full bg-gray-200 my-1"></div>
                          )}
                        </div>
                        <div className="flex-1 pb-4">
                          <p className="font-medium">{event.status}</p>
                          <p className="text-sm text-gray-500">
                            {format(event.timestamp, "HH:mm:ss")}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Pricing Breakdown */}
                <div>
                  <h3 className="font-medium mb-3">Pricing Breakdown</h3>
                  <div className="space-y-2 bg-gray-50 p-4 rounded-lg">
                    <div className="flex justify-between">
                      <span>Delivery Fee</span>
                      <span className="font-medium">
                        {selectedOrder.deliveryFee} MAD
                      </span>
                    </div>
                    <div className="flex justify-between text-sm text-gray-600">
                      <span>Driver Payout</span>
                      <span>{selectedOrder.driverPayout} MAD</span>
                    </div>
                    <div className="flex justify-between text-sm text-gray-600">
                      <span>Platform Fee</span>
                      <span>{selectedOrder.platformFee} MAD</span>
                    </div>
                  </div>
                </div>

                {/* Pickup & Dropoff */}
                <div>
                  <h3 className="font-medium mb-3">Addresses</h3>
                  <div className="space-y-3">
                    <div>
                      <p className="text-sm text-gray-600">Pickup</p>
                      <p className="font-medium">{selectedOrder.restaurant}</p>
                      <p className="text-sm">{selectedOrder.pickupAddress}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Dropoff</p>
                      <p className="font-medium">{selectedOrder.customer}</p>
                      <p className="text-sm">{selectedOrder.dropoffAddress}</p>
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-2 pt-4 border-t">
                  <Button
                    variant="outline"
                    className="flex-1"
                    onClick={() => setSelectedOrder(null)}
                  >
                    Close
                  </Button>
                  {selectedOrder.status !== "Cancelled" &&
                    selectedOrder.status !== "Completed" && (
                      <Button variant="destructive" className="flex-1">
                        <X className="w-4 h-4 mr-2" />
                        Cancel Order
                      </Button>
                    )}
                </div>
              </div>
            </>
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
}
