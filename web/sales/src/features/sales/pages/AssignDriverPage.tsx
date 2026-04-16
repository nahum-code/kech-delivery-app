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
import { Avatar, AvatarFallback } from "../components/ui/avatar";
import {
  Package,
  MapPin,
  Clock,
  Star,
  Navigation,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Search,
  Bike,
  Car,
} from "lucide-react";
import { toast } from "sonner";

// Mock data
const mockUnassignedOrders = [
  {
    id: "ORD-1001",
    customer: "Abebe Kebede",
    restaurant: "Yod Abyssinia",
    restaurantAddress: "Bole Road, Addis Ababa",
    dropoffAddress: "Kazanchis, Next to Atlas Hotel",
    createdAt: "10 mins ago",
    urgency: "high",
    total: 430,
  },
  {
    id: "ORD-1002",
    customer: "Tigist Alemu",
    restaurant: "Kategna Restaurant",
    restaurantAddress: "Kazanchis, Addis Ababa",
    dropoffAddress: "Bole, Behind Shell Station",
    createdAt: "15 mins ago",
    urgency: "medium",
    total: 520,
  },
  {
    id: "ORD-1003",
    customer: "Daniel Haile",
    restaurant: "Habesha Kitchen",
    restaurantAddress: "Piassa, Addis Ababa",
    dropoffAddress: "CMC, Near Total Gas Station",
    createdAt: "5 mins ago",
    urgency: "high",
    total: 350,
  },
];

const mockDrivers = [
  {
    id: "DRV-101",
    name: "Mohammed Ali",
    vehicle: "Motorcycle",
    distance: 1.2,
    rating: 4.8,
    completedToday: 12,
    status: "online",
    eligible: true,
    eligibilityReasons: ["Approved", "Online", "Not Busy", "Within Radius"],
  },
  {
    id: "DRV-102",
    name: "Birtukan Desta",
    vehicle: "Car",
    distance: 0.8,
    rating: 4.9,
    completedToday: 15,
    status: "online",
    eligible: true,
    eligibilityReasons: ["Approved", "Online", "Not Busy", "Within Radius"],
  },
  {
    id: "DRV-103",
    name: "Yohannes Tesfaye",
    vehicle: "Motorcycle",
    distance: 2.5,
    rating: 4.7,
    completedToday: 8,
    status: "busy",
    eligible: false,
    eligibilityReasons: ["Approved", "Online", "Busy"],
  },
  {
    id: "DRV-104",
    name: "Sara Getachew",
    vehicle: "Car",
    distance: 5.2,
    rating: 4.6,
    completedToday: 10,
    status: "online",
    eligible: false,
    eligibilityReasons: ["Approved", "Online", "Not Busy", "Out of Radius"],
  },
  {
    id: "DRV-105",
    name: "Kedir Ahmed",
    vehicle: "Motorcycle",
    distance: 1.5,
    rating: 4.5,
    completedToday: 7,
    status: "offline",
    eligible: false,
    eligibilityReasons: ["Approved", "Offline"],
  },
];

export function AssignDriverPage() {
  const [selectedOrder, setSelectedOrder] = useState<string | null>(
    mockUnassignedOrders[0]?.id || null
  );
  const [searchDriver, setSearchDriver] = useState("");
  const [filterVehicle, setFilterVehicle] = useState<string>("all");
  const [filterStatus, setFilterStatus] = useState<string>("all");

  const handleAssignDriver = (driverId: string, orderId: string) => {
    const driver = mockDrivers.find((d) => d.id === driverId);
    const order = mockUnassignedOrders.find((o) => o.id === orderId);
    
    if (driver && order) {
      toast.success(`Driver ${driver.name} assigned to order ${order.id}`);
    }
  };

  const handleReleaseToPool = (orderId: string) => {
    toast.info(`Order ${orderId} released to self-accept pool`);
  };

  const filteredDrivers = mockDrivers.filter((driver) => {
    const matchesSearch =
      driver.name.toLowerCase().includes(searchDriver.toLowerCase()) ||
      driver.id.toLowerCase().includes(searchDriver.toLowerCase());
    const matchesVehicle =
      filterVehicle === "all" ||
      driver.vehicle.toLowerCase() === filterVehicle.toLowerCase();
    const matchesStatus =
      filterStatus === "all" || driver.status === filterStatus;

    return matchesSearch && matchesVehicle && matchesStatus;
  });

  const selectedOrderData = mockUnassignedOrders.find(
    (o) => o.id === selectedOrder
  );

  return (
    <div className="p-6 h-full">
      <div className="grid grid-cols-3 gap-6 h-full">
        {/* Left Panel - Unassigned Orders */}
        <div className="col-span-1 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold">Unassigned Orders</h2>
            <Badge variant="destructive">{mockUnassignedOrders.length}</Badge>
          </div>

          <div className="space-y-3 overflow-y-auto max-h-[calc(100vh-200px)]">
            {mockUnassignedOrders.map((order) => (
              <Card
                key={order.id}
                className={`p-4 cursor-pointer transition-all ${
                  selectedOrder === order.id
                    ? "border-primary border-2 bg-primary/5"
                    : "hover:bg-accent"
                }`}
                onClick={() => setSelectedOrder(order.id)}
              >
                <div className="space-y-3">
                  {/* Order Header */}
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Package className="h-4 w-4 text-primary" />
                      <span className="font-semibold">{order.id}</span>
                    </div>
                    <Badge
                      variant={
                        order.urgency === "high" ? "destructive" : "secondary"
                      }
                    >
                      {order.urgency === "high" ? (
                        <AlertCircle className="h-3 w-3 mr-1" />
                      ) : (
                        <Clock className="h-3 w-3 mr-1" />
                      )}
                      {order.urgency}
                    </Badge>
                  </div>

                  {/* Customer */}
                  <div>
                    <p className="text-sm font-medium">{order.customer}</p>
                    <p className="text-xs text-muted-foreground">
                      {order.total} ETB
                    </p>
                  </div>

                  {/* Restaurant */}
                  <div className="flex items-start gap-2 text-xs">
                    <MapPin className="h-3 w-3 text-green-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <p className="font-medium">{order.restaurant}</p>
                      <p className="text-muted-foreground">
                        {order.restaurantAddress}
                      </p>
                    </div>
                  </div>

                  {/* Dropoff */}
                  <div className="flex items-start gap-2 text-xs">
                    <MapPin className="h-3 w-3 text-red-600 mt-0.5 flex-shrink-0" />
                    <p className="text-muted-foreground">
                      {order.dropoffAddress}
                    </p>
                  </div>

                  {/* Time */}
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <Clock className="h-3 w-3" />
                    {order.createdAt}
                  </div>
                </div>
              </Card>
            ))}
          </div>

          {selectedOrderData && (
            <Button
              variant="outline"
              className="w-full"
              onClick={() => handleReleaseToPool(selectedOrderData.id)}
            >
              Release to Self-Accept Pool
            </Button>
          )}
        </div>

        {/* Right Panel - Available Drivers */}
        <div className="col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold">Available Drivers</h2>
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-300">
                {mockDrivers.filter((d) => d.eligible).length} Eligible
              </Badge>
            </div>
          </div>

          {/* Filters */}
          <Card className="p-4">
            <div className="grid grid-cols-3 gap-4">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search driver..."
                  value={searchDriver}
                  onChange={(e) => setSearchDriver(e.target.value)}
                  className="pl-9"
                />
              </div>

              <Select value={filterVehicle} onValueChange={setFilterVehicle}>
                <SelectTrigger>
                  <SelectValue placeholder="Vehicle type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Vehicles</SelectItem>
                  <SelectItem value="motorcycle">
                    <div className="flex items-center gap-2">
                      <Bike className="h-4 w-4" />
                      <span>Motorcycle</span>
                    </div>
                  </SelectItem>
                  <SelectItem value="car">
                    <div className="flex items-center gap-2">
                      <Car className="h-4 w-4" />
                      <span>Car</span>
                    </div>
                  </SelectItem>
                </SelectContent>
              </Select>

              <Select value={filterStatus} onValueChange={setFilterStatus}>
                <SelectTrigger>
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="online">Online</SelectItem>
                  <SelectItem value="offline">Offline</SelectItem>
                  <SelectItem value="busy">Busy</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </Card>

          {/* Drivers List */}
          <div className="space-y-3 overflow-y-auto max-h-[calc(100vh-300px)]">
            {filteredDrivers.map((driver) => (
              <Card
                key={driver.id}
                className={`p-4 ${
                  driver.eligible ? "" : "opacity-60 bg-gray-50"
                }`}
              >
                <div className="flex items-center justify-between">
                  {/* Driver Info */}
                  <div className="flex items-center gap-4 flex-1">
                    <Avatar className="h-12 w-12">
                      <AvatarFallback className="bg-primary text-primary-foreground">
                        {driver.name
                          .split(" ")
                          .map((n) => n[0])
                          .join("")}
                      </AvatarFallback>
                    </Avatar>

                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <p className="font-semibold">{driver.name}</p>
                        <Badge
                          variant="outline"
                          className={`text-xs ${
                            driver.status === "online"
                              ? "bg-green-50 text-green-700 border-green-300"
                              : driver.status === "busy"
                              ? "bg-yellow-50 text-yellow-700 border-yellow-300"
                              : "bg-gray-100 text-gray-700 border-gray-300"
                          }`}
                        >
                          {driver.status}
                        </Badge>
                      </div>

                      <div className="flex items-center gap-4 text-sm text-muted-foreground">
                        <span className="flex items-center gap-1">
                          {driver.vehicle === "Motorcycle" ? (
                            <Bike className="h-3 w-3" />
                          ) : (
                            <Car className="h-3 w-3" />
                          )}
                          {driver.vehicle}
                        </span>
                        <span className="flex items-center gap-1">
                          <Navigation className="h-3 w-3" />
                          {driver.distance} km
                        </span>
                        <span className="flex items-center gap-1">
                          <Star className="h-3 w-3 fill-yellow-400 text-yellow-400" />
                          {driver.rating}
                        </span>
                        <span className="flex items-center gap-1">
                          <CheckCircle2 className="h-3 w-3" />
                          {driver.completedToday} today
                        </span>
                      </div>

                      {/* Eligibility Status */}
                      <div className="flex items-center gap-1 mt-2 flex-wrap">
                        {driver.eligibilityReasons.map((reason, index) => {
                          const isNegative =
                            reason === "Busy" ||
                            reason === "Offline" ||
                            reason === "Out of Radius" ||
                            reason === "Suspended";

                          return (
                            <Badge
                              key={index}
                              variant="outline"
                              className={`text-xs ${
                                isNegative
                                  ? "bg-red-50 text-red-700 border-red-300"
                                  : "bg-blue-50 text-blue-700 border-blue-300"
                              }`}
                            >
                              {isNegative ? (
                                <XCircle className="h-3 w-3 mr-1" />
                              ) : (
                                <CheckCircle2 className="h-3 w-3 mr-1" />
                              )}
                              {reason}
                            </Badge>
                          );
                        })}
                      </div>
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-2">
                    <Button
                      size="sm"
                      disabled={!driver.eligible || !selectedOrder}
                      onClick={() =>
                        selectedOrder &&
                        handleAssignDriver(driver.id, selectedOrder)
                      }
                      className="bg-primary hover:bg-primary/90"
                    >
                      Assign
                    </Button>
                  </div>
                </div>
              </Card>
            ))}

            {filteredDrivers.length === 0 && (
              <Card className="p-12 text-center">
                <Search className="h-12 w-12 text-gray-400 mx-auto mb-3" />
                <p className="text-muted-foreground">No drivers found</p>
                <p className="text-sm text-muted-foreground mt-1">
                  Try adjusting your filters
                </p>
              </Card>
            )}
          </div>

          {/* Info Box */}
          {selectedOrderData && (
            <Card className="p-4 bg-blue-50 border-blue-200">
              <div className="flex items-start gap-3">
                <AlertCircle className="h-5 w-5 text-blue-700 mt-0.5" />
                <div className="text-sm text-blue-900">
                  <p className="font-medium mb-1">
                    Selected: {selectedOrderData.id}
                  </p>
                  <p className="text-xs text-blue-700">
                    You can only reassign drivers before pickup. After pickup,
                    reassignment requires admin approval.
                  </p>
                </div>
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}
