"use client";

import { useState } from "react";
import { Card } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import { Badge } from "../components/ui/badge";
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
import {
  Package,
  Search,
  MoreVertical,
  Eye,
  UserX,
  X,
  Phone,
  AlertCircle,
  TrendingUp,
  PackageCheck,
  Users,
  AlertTriangle,
} from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "../components/ui/dropdown-menu";
import { Separator } from "../components/ui/separator";
import { toast } from "sonner";

// Order statuses
const orderStatuses = [
  "Draft",
  "PaymentPending",
  "PaymentFailed",
  "PaymentConfirmed",
  "SearchingDriver",
  "Assigned",
  "Accepted",
  "PickedUp",
  "Delivered",
  "Completed",
  "Cancelled",
];

// Mock data
const mockOrders = [
  {
    id: "ORD-1001",
    customer: { name: "Abebe Kebede", phone: "0911234567" },
    restaurant: "Yod Abyssinia",
    driver: { name: "Mohammed Ali", phone: "0912345678" },
    status: "PickedUp",
    paymentState: "PaymentConfirmed",
    createdAt: "2026-03-19T10:30:00",
    eta: "15 mins",
    total: 430,
    events: [
      {
        status: "PaymentConfirmed",
        timestamp: "2026-03-19T10:30:00",
        note: "Payment confirmed",
      },
      {
        status: "SearchingDriver",
        timestamp: "2026-03-19T10:31:00",
        note: "Searching for available driver",
      },
      {
        status: "Assigned",
        timestamp: "2026-03-19T10:32:00",
        note: "Driver Mohammed Ali assigned",
      },
      {
        status: "Accepted",
        timestamp: "2026-03-19T10:33:00",
        note: "Driver accepted the order",
      },
      {
        status: "PickedUp",
        timestamp: "2026-03-19T10:45:00",
        note: "Order picked up from restaurant",
      },
    ],
  },
  {
    id: "ORD-1002",
    customer: { name: "Tigist Alemu", phone: "0913456789" },
    restaurant: "Kategna Restaurant",
    driver: { name: "Birtukan Desta", phone: "0914567890" },
    status: "Delivered",
    paymentState: "PaymentConfirmed",
    createdAt: "2026-03-19T09:15:00",
    eta: "Delivered",
    total: 520,
    events: [
      {
        status: "PaymentConfirmed",
        timestamp: "2026-03-19T09:15:00",
        note: "Payment confirmed",
      },
      {
        status: "Assigned",
        timestamp: "2026-03-19T09:17:00",
        note: "Driver Birtukan Desta assigned",
      },
      {
        status: "Accepted",
        timestamp: "2026-03-19T09:18:00",
        note: "Driver accepted the order",
      },
      {
        status: "PickedUp",
        timestamp: "2026-03-19T09:30:00",
        note: "Order picked up from restaurant",
      },
      {
        status: "Delivered",
        timestamp: "2026-03-19T09:50:00",
        note: "Order delivered successfully",
      },
    ],
  },
  {
    id: "ORD-1003",
    customer: { name: "Daniel Haile", phone: "0915678901" },
    restaurant: "Habesha Kitchen",
    driver: null,
    status: "SearchingDriver",
    paymentState: "PaymentConfirmed",
    createdAt: "2026-03-19T10:50:00",
    eta: "-",
    total: 350,
    events: [
      {
        status: "PaymentConfirmed",
        timestamp: "2026-03-19T10:50:00",
        note: "Payment confirmed",
      },
      {
        status: "SearchingDriver",
        timestamp: "2026-03-19T10:51:00",
        note: "Searching for available driver - 5 mins elapsed",
      },
    ],
  },
  {
    id: "ORD-1004",
    customer: { name: "Sara Tesfaye", phone: "0916789012" },
    restaurant: "Lucy Restaurant",
    driver: null,
    status: "PaymentFailed",
    paymentState: "PaymentFailed",
    createdAt: "2026-03-19T10:40:00",
    eta: "-",
    total: 280,
    events: [
      {
        status: "PaymentPending",
        timestamp: "2026-03-19T10:40:00",
        note: "Payment initiated",
      },
      {
        status: "PaymentFailed",
        timestamp: "2026-03-19T10:42:00",
        note: "Payment failed - Insufficient funds",
      },
    ],
  },
  {
    id: "ORD-1005",
    customer: { name: "Kedir Ahmed", phone: "0917890123" },
    restaurant: "Top View Restaurant",
    driver: { name: "Yohannes Tesfaye", phone: "0918901234" },
    status: "Accepted",
    paymentState: "PaymentConfirmed",
    createdAt: "2026-03-19T10:35:00",
    eta: "20 mins",
    total: 615,
    events: [
      {
        status: "PaymentConfirmed",
        timestamp: "2026-03-19T10:35:00",
        note: "Payment confirmed",
      },
      {
        status: "Assigned",
        timestamp: "2026-03-19T10:36:00",
        note: "Driver Yohannes Tesfaye assigned",
      },
      {
        status: "Accepted",
        timestamp: "2026-03-19T10:37:00",
        note: "Driver accepted and en route to restaurant",
      },
    ],
  },
];

export function MonitorOrdersPage() {
  const [searchTerm, setSearchTerm] = useState("");
  const [filterStatus, setFilterStatus] = useState<string>("all");
  const [filterPayment, setFilterPayment] = useState<string>("all");
  const [selectedOrder, setSelectedOrder] = useState<typeof mockOrders[0] | null>(null);
  const [detailsOpen, setDetailsOpen] = useState(false);

  const handleViewDetails = (order: typeof mockOrders[0]) => {
    setSelectedOrder(order);
    setDetailsOpen(true);
  };

  const handleCancelOrder = (orderId: string) => {
    toast.success(`Order ${orderId} has been cancelled`);
    setDetailsOpen(false);
  };

  const filteredOrders = mockOrders.filter((order) => {
    const matchesSearch =
      order.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.restaurant.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      filterStatus === "all" || order.status === filterStatus;

    const matchesPayment =
      filterPayment === "all" || order.paymentState === filterPayment;

    return matchesSearch && matchesStatus && matchesPayment;
  });

  const getStatusBadge = (status: string) => {
    const statusConfig: Record<
      string,
      {
        variant: "default" | "secondary" | "destructive" | "outline";
        className: string;
      }
    > = {
      Draft: { variant: "outline", className: "bg-gray-100 text-gray-700 border-gray-300" },
      PaymentPending: { variant: "outline", className: "bg-yellow-50 text-yellow-700 border-yellow-300" },
      PaymentFailed: { variant: "destructive", className: "" },
      PaymentConfirmed: { variant: "outline", className: "bg-green-50 text-green-700 border-green-300" },
      SearchingDriver: { variant: "outline", className: "bg-orange-50 text-orange-700 border-orange-300" },
      Assigned: { variant: "outline", className: "bg-blue-50 text-blue-700 border-blue-300" },
      Accepted: { variant: "outline", className: "bg-indigo-50 text-indigo-700 border-indigo-300" },
      PickedUp: { variant: "outline", className: "bg-purple-50 text-purple-700 border-purple-300" },
      Delivered: { variant: "outline", className: "bg-teal-50 text-teal-700 border-teal-300" },
      Completed: { variant: "outline", className: "bg-green-50 text-green-700 border-green-300" },
      Cancelled: { variant: "outline", className: "bg-red-50 text-red-700 border-red-300" },
    };

    const config = statusConfig[status] || statusConfig.Draft;

    return (
      <Badge variant={config.variant} className={config.className}>
        {status}
      </Badge>
    );
  };

  const activeOrders = mockOrders.filter((o) =>
    ["Assigned", "Accepted", "PickedUp"].includes(o.status)
  ).length;

  const searchingDriverCount = mockOrders.filter(
    (o) => o.status === "SearchingDriver"
  ).length;

  const delayedOrders = mockOrders.filter(
    (o) => o.status === "SearchingDriver"
  ).length;

  const completedToday = mockOrders.filter((o) => o.status === "Delivered")
    .length;

  return (
    <div className="p-6 space-y-6">
      {/* Summary Cards */}
      <div className="grid grid-cols-4 gap-4">
        <Card className="p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">Active Orders</p>
              <p className="text-2xl font-bold mt-1">{activeOrders}</p>
            </div>
            <div className="h-12 w-12 rounded-full bg-blue-100 flex items-center justify-center">
              <TrendingUp className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">Searching Driver</p>
              <p className="text-2xl font-bold mt-1">{searchingDriverCount}</p>
            </div>
            <div className="h-12 w-12 rounded-full bg-orange-100 flex items-center justify-center">
              <Users className="h-6 w-6 text-orange-600" />
            </div>
          </div>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">Delayed Orders</p>
              <p className="text-2xl font-bold mt-1">{delayedOrders}</p>
            </div>
            <div className="h-12 w-12 rounded-full bg-red-100 flex items-center justify-center">
              <AlertTriangle className="h-6 w-6 text-red-600" />
            </div>
          </div>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">Completed Today</p>
              <p className="text-2xl font-bold mt-1">{completedToday}</p>
            </div>
            <div className="h-12 w-12 rounded-full bg-green-100 flex items-center justify-center">
              <PackageCheck className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card className="p-4">
        <div className="grid grid-cols-4 gap-4">
          <div className="relative col-span-2">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search by order ID, customer, or restaurant..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-9"
            />
          </div>

          <Select value={filterStatus} onValueChange={setFilterStatus}>
            <SelectTrigger>
              <SelectValue placeholder="Filter by status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Statuses</SelectItem>
              {orderStatuses.map((status) => (
                <SelectItem key={status} value={status}>
                  {status}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <Select value={filterPayment} onValueChange={setFilterPayment}>
            <SelectTrigger>
              <SelectValue placeholder="Filter by payment" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Payment States</SelectItem>
              <SelectItem value="PaymentPending">Payment Pending</SelectItem>
              <SelectItem value="PaymentConfirmed">Payment Confirmed</SelectItem>
              <SelectItem value="PaymentFailed">Payment Failed</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </Card>

      {/* Orders Table */}
      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Order Number</TableHead>
              <TableHead>Customer</TableHead>
              <TableHead>Restaurant</TableHead>
              <TableHead>Driver</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Payment</TableHead>
              <TableHead>Created At</TableHead>
              <TableHead>ETA</TableHead>
              <TableHead>Total</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredOrders.map((order) => (
              <TableRow key={order.id}>
                <TableCell className="font-medium">{order.id}</TableCell>
                <TableCell>
                  <div>
                    <p className="font-medium">{order.customer.name}</p>
                    <p className="text-xs text-muted-foreground">
                      {order.customer.phone}
                    </p>
                  </div>
                </TableCell>
                <TableCell>{order.restaurant}</TableCell>
                <TableCell>
                  {order.driver ? (
                    <div>
                      <p className="font-medium">{order.driver.name}</p>
                      <p className="text-xs text-muted-foreground">
                        {order.driver.phone}
                      </p>
                    </div>
                  ) : (
                    <span className="text-muted-foreground text-sm">
                      Unassigned
                    </span>
                  )}
                </TableCell>
                <TableCell>{getStatusBadge(order.status)}</TableCell>
                <TableCell>{getStatusBadge(order.paymentState)}</TableCell>
                <TableCell className="text-sm">
                  {new Date(order.createdAt).toLocaleTimeString("en-US", {
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                </TableCell>
                <TableCell>
                  <span
                    className={
                      order.status === "SearchingDriver"
                        ? "text-orange-600 font-medium"
                        : ""
                    }
                  >
                    {order.eta}
                  </span>
                </TableCell>
                <TableCell className="font-medium">
                  {order.total} ETB
                </TableCell>
                <TableCell>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="sm">
                        <MoreVertical className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem
                        onClick={() => handleViewDetails(order)}
                      >
                        <Eye className="h-4 w-4 mr-2" />
                        View Details
                      </DropdownMenuItem>
                      {!order.driver && (
                        <DropdownMenuItem>
                          <Users className="h-4 w-4 mr-2" />
                          Assign Driver
                        </DropdownMenuItem>
                      )}
                      {order.driver &&
                        !["PickedUp", "Delivered", "Completed"].includes(
                          order.status
                        ) && (
                          <DropdownMenuItem>
                            <UserX className="h-4 w-4 mr-2" />
                            Reassign Driver
                          </DropdownMenuItem>
                        )}
                      {!["Delivered", "Completed", "Cancelled"].includes(
                        order.status
                      ) && (
                        <DropdownMenuItem
                          onClick={() => handleCancelOrder(order.id)}
                          className="text-destructive"
                        >
                          <X className="h-4 w-4 mr-2" />
                          Cancel Order
                        </DropdownMenuItem>
                      )}
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        {filteredOrders.length === 0 && (
          <div className="p-12 text-center">
            <Package className="h-12 w-12 text-gray-400 mx-auto mb-3" />
            <p className="text-muted-foreground">No orders found</p>
            <p className="text-sm text-muted-foreground mt-1">
              Try adjusting your filters
            </p>
          </div>
        )}
      </Card>

      {/* Order Details Drawer */}
      <Sheet open={detailsOpen} onOpenChange={setDetailsOpen}>
        <SheetContent className="w-[600px] sm:w-[600px] overflow-y-auto">
          {selectedOrder && (
            <>
              <SheetHeader>
                <SheetTitle className="flex items-center justify-between">
                  <span>Order Details</span>
                  <Badge className="bg-primary">{selectedOrder.id}</Badge>
                </SheetTitle>
              </SheetHeader>

              <div className="space-y-6 mt-6">
                {/* Status Timeline */}
                <div>
                  <h3 className="font-semibold mb-3">Status Timeline</h3>
                  <div className="space-y-3">
                    {selectedOrder.events.map((event, index) => (
                      <div key={index} className="flex gap-3">
                        <div className="flex flex-col items-center">
                          <div
                            className={`w-3 h-3 rounded-full ${
                              index === selectedOrder.events.length - 1
                                ? "bg-primary"
                                : "bg-gray-300"
                            }`}
                          />
                          {index < selectedOrder.events.length - 1 && (
                            <div className="w-0.5 h-full bg-gray-200 my-1" />
                          )}
                        </div>
                        <div className="flex-1 pb-4">
                          <div className="flex items-center justify-between mb-1">
                            {getStatusBadge(event.status)}
                            <span className="text-xs text-muted-foreground">
                              {new Date(event.timestamp).toLocaleTimeString(
                                "en-US",
                                {
                                  hour: "2-digit",
                                  minute: "2-digit",
                                }
                              )}
                            </span>
                          </div>
                          <p className="text-sm text-muted-foreground">
                            {event.note}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <Separator />

                {/* Customer Info */}
                <div>
                  <h3 className="font-semibold mb-3">Customer Information</h3>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-muted-foreground">
                        Name
                      </span>
                      <span className="font-medium">
                        {selectedOrder.customer.name}
                      </span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-muted-foreground">
                        Phone
                      </span>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() =>
                          toast.info(`Calling ${selectedOrder.customer.phone}`)
                        }
                      >
                        <Phone className="h-3 w-3 mr-2" />
                        {selectedOrder.customer.phone}
                      </Button>
                    </div>
                  </div>
                </div>

                <Separator />

                {/* Restaurant Info */}
                <div>
                  <h3 className="font-semibold mb-3">Restaurant</h3>
                  <p className="font-medium">{selectedOrder.restaurant}</p>
                </div>

                <Separator />

                {/* Driver Info */}
                <div>
                  <h3 className="font-semibold mb-3">Driver</h3>
                  {selectedOrder.driver ? (
                    <div className="space-y-2">
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">
                          Name
                        </span>
                        <span className="font-medium">
                          {selectedOrder.driver.name}
                        </span>
                      </div>
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">
                          Phone
                        </span>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() =>
                            toast.info(
                              `Calling ${selectedOrder.driver?.phone}`
                            )
                          }
                        >
                          <Phone className="h-3 w-3 mr-2" />
                          {selectedOrder.driver.phone}
                        </Button>
                      </div>
                    </div>
                  ) : (
                    <div className="p-4 bg-orange-50 border border-orange-200 rounded-lg">
                      <p className="text-sm text-orange-900 flex items-center gap-2">
                        <AlertCircle className="h-4 w-4" />
                        No driver assigned yet
                      </p>
                    </div>
                  )}
                </div>

                <Separator />

                {/* Fee Summary */}
                <div>
                  <h3 className="font-semibold mb-3">Fee Breakdown</h3>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">Subtotal</span>
                      <span>{selectedOrder.total - 80} ETB</span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">
                        Delivery Fee
                      </span>
                      <span>80 ETB</span>
                    </div>
                    <Separator />
                    <div className="flex items-center justify-between">
                      <span className="font-semibold">Total</span>
                      <span className="font-semibold text-primary">
                        {selectedOrder.total} ETB
                      </span>
                    </div>
                  </div>

                  <div className="mt-4 p-3 bg-gray-50 rounded-lg text-sm space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="text-muted-foreground">
                        Driver Payout
                      </span>
                      <span>60 ETB</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-muted-foreground">
                        Platform Fee
                      </span>
                      <span>20 ETB</span>
                    </div>
                  </div>
                </div>

                {/* Actions */}
                {!["Delivered", "Completed", "Cancelled"].includes(
                  selectedOrder.status
                ) && (
                  <div className="flex gap-2 pt-4">
                    {!selectedOrder.driver && (
                      <Button className="flex-1 bg-primary hover:bg-primary/90">
                        <Users className="h-4 w-4 mr-2" />
                        Assign Driver
                      </Button>
                    )}
                    <Button
                      variant="destructive"
                      className="flex-1"
                      onClick={() => handleCancelOrder(selectedOrder.id)}
                    >
                      <X className="h-4 w-4 mr-2" />
                      Cancel Order
                    </Button>
                  </div>
                )}
              </div>
            </>
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
}
