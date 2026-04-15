"use client";

import { useState } from "react";
import { Card } from "../components/ui/card";
import { Button } from "../components/ui/button";
import { Input } from "../components/ui/input";
import { Label } from "../components/ui/label";
import { Textarea } from "../components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../components/ui/select";
import { Badge } from "../components/ui/badge";
import { Separator } from "../components/ui/separator";
import {
  Search,
  MapPin,
  Plus,
  Minus,
  ChevronRight,
  ChevronLeft,
  Check,
  AlertCircle,
  User,
  Store,
  ShoppingBag,
  Banknote,
  CreditCard,
} from "lucide-react";
import { toast } from "sonner";

// Mock data
const mockRestaurants = [
  {
    id: "1",
    name: "Yod Abyssinia",
    address: "Bole Road, Addis Ababa",
    isOpen: true,
  },
  {
    id: "2",
    name: "Kategna Restaurant",
    address: "Kazanchis, Addis Ababa",
    isOpen: true,
  },
  {
    id: "3",
    name: "Habesha 2000",
    address: "Meskel Square, Addis Ababa",
    isOpen: false,
  },
];

const mockMenuItems = [
  {
    id: "1",
    name: "Doro Wot",
    price: 350,
    available: true,
    category: "Main Dishes",
  },
  {
    id: "2",
    name: "Kitfo",
    price: 400,
    available: true,
    category: "Main Dishes",
  },
  {
    id: "3",
    name: "Tibs",
    price: 320,
    available: true,
    category: "Main Dishes",
  },
  {
    id: "4",
    name: "Injera",
    price: 50,
    available: true,
    category: "Sides",
  },
  {
    id: "5",
    name: "Shiro",
    price: 180,
    available: false,
    category: "Main Dishes",
  },
];

type Step = 1 | 2 | 3 | 4 | 5;

type Customer = {
  phone: string;
  name: string;
  id?: string;
};

type OrderItem = {
  id: string;
  name: string;
  price: number;
  quantity: number;
  notes: string;
};

type PaymentStatus = "pending" | "confirmed" | "failed";

export function CreateOrderPage() {
  const [currentStep, setCurrentStep] = useState<Step>(1);
  const [customer, setCustomer] = useState<Customer>({ phone: "", name: "" });
  const [customerExists, setCustomerExists] = useState(false);
  const [selectedRestaurant, setSelectedRestaurant] = useState("");
  const [dropoffAddress, setDropoffAddress] = useState("");
  const [orderItems, setOrderItems] = useState<OrderItem[]>([]);
  const [paymentStatus, setPaymentStatus] = useState<PaymentStatus>("pending");
  // Form validation errors
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validateStep = (step: Step): boolean => {
    const newErrors: Record<string, string> = {};

    if (step === 1) {
      if (!customer.phone || customer.phone.length < 10) {
        newErrors.phone = "Valid phone number is required (10+ digits)";
      }
      if (!customer.name.trim()) {
        newErrors.name = "Customer name is required";
      }
    }

    if (step === 2) {
      if (!selectedRestaurant) {
        newErrors.restaurant = "Please select a restaurant";
      }
      if (!dropoffAddress.trim()) {
        newErrors.dropoffAddress = "Dropoff address is required";
      }
      const restaurant = mockRestaurants.find(
        (r) => r.id === selectedRestaurant
      );
      if (restaurant && !restaurant.isOpen) {
        newErrors.restaurant = "Selected restaurant is currently closed";
      }
    }

    if (step === 3) {
      if (orderItems.length === 0) {
        newErrors.items = "Please add at least one item";
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (validateStep(currentStep)) {
      setCurrentStep((prev) => Math.min(5, prev + 1) as Step);
    }
  };

  const handleBack = () => {
    setCurrentStep((prev) => Math.max(1, prev - 1) as Step);
  };

  const handleLookupCustomer = () => {
    // Mock lookup - in real app this would be an API call
    if (customer.phone.length >= 10) {
      setCustomerExists(true);
      setCustomer({
        ...customer,
        name: "Abebe Kebede",
        id: "customer-123",
      });
      toast.success("Customer found!");
    } else {
      setErrors({ phone: "Please enter a valid phone number" });
    }
  };

  const handleAddItem = (item: (typeof mockMenuItems)[0]) => {
    const existing = orderItems.find((oi) => oi.id === item.id);
    if (existing) {
      setOrderItems(
        orderItems.map((oi) =>
          oi.id === item.id ? { ...oi, quantity: oi.quantity + 1 } : oi
        )
      );
    } else {
      setOrderItems([
        ...orderItems,
        { ...item, quantity: 1, notes: "" },
      ]);
    }
  };

  const handleUpdateQuantity = (itemId: string, delta: number) => {
    setOrderItems(
      orderItems
        .map((item) =>
          item.id === itemId
            ? { ...item, quantity: Math.max(0, item.quantity + delta) }
            : item
        )
        .filter((item) => item.quantity > 0)
    );
  };

  const calculateTotals = () => {
    const subtotal = orderItems.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0
    );
    const deliveryFee = 80;
    const driverPayout = 60;
    const platformFee = 20;
    const total = subtotal + deliveryFee;

    return { subtotal, deliveryFee, driverPayout, platformFee, total };
  };

  const handleSubmitOrder = () => {
    if (paymentStatus === "confirmed") {
      toast.success("Order created successfully!");
      // Reset form
      setCurrentStep(1);
      setCustomer({ phone: "", name: "" });
      setCustomerExists(false);
      setSelectedRestaurant("");
      setDropoffAddress("");
      setOrderItems([]);
      setPaymentStatus("pending");
    } else {
      toast.error("Please confirm payment before submitting");
    }
  };

  const steps = [
    { number: 1, label: "Customer", icon: User },
    { number: 2, label: "Location", icon: MapPin },
    { number: 3, label: "Items", icon: ShoppingBag },
    { number: 4, label: "Pricing", icon: Banknote },
    { number: 5, label: "Payment", icon: CreditCard },
  ];

  const totals = calculateTotals();

  return (
    <div className="p-6 max-w-6xl mx-auto">
      {/* Progress Steps */}
      <Card className="p-6 mb-6">
        <div className="flex items-center justify-between">
          {steps.map((step, index) => {
            const Icon = step.icon;
            const isActive = currentStep === step.number;
            const isCompleted = currentStep > step.number;

            return (
              <div key={step.number} className="flex items-center flex-1">
                <div className="flex flex-col items-center flex-1">
                  <div
                    className={`w-12 h-12 rounded-full flex items-center justify-center mb-2 ${
                      isCompleted
                        ? "bg-primary text-primary-foreground"
                        : isActive
                        ? "bg-primary text-primary-foreground"
                        : "bg-gray-200 text-gray-500"
                    }`}
                  >
                    {isCompleted ? (
                      <Check className="h-6 w-6" />
                    ) : (
                      <Icon className="h-6 w-6" />
                    )}
                  </div>
                  <span
                    className={`text-sm ${
                      isActive || isCompleted
                        ? "font-medium text-foreground"
                        : "text-muted-foreground"
                    }`}
                  >
                    {step.label}
                  </span>
                </div>
                {index < steps.length - 1 && (
                  <div
                    className={`h-1 flex-1 mx-2 ${
                      isCompleted ? "bg-primary" : "bg-gray-200"
                    }`}
                  />
                )}
              </div>
            );
          })}
        </div>
      </Card>

      {/* Step Content */}
      <Card className="p-6">
        {/* Step 1: Customer Lookup */}
        {currentStep === 1 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold mb-1">Customer Information</h2>
              <p className="text-sm text-muted-foreground">
                Search by phone or create a new customer
              </p>
            </div>

            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="phone">
                  Phone Number <span className="text-destructive">*</span>
                </Label>
                <div className="flex gap-2">
                  <div className="flex-1">
                    <Input
                      id="phone"
                      type="tel"
                      placeholder="0911234567"
                      value={customer.phone}
                      onChange={(e) =>
                        setCustomer({ ...customer, phone: e.target.value })
                      }
                      className={errors.phone ? "border-destructive" : ""}
                    />
                    {errors.phone && (
                      <p className="text-sm text-destructive mt-1 flex items-center gap-1">
                        <AlertCircle className="h-4 w-4" />
                        {errors.phone}
                      </p>
                    )}
                  </div>
                  <Button onClick={handleLookupCustomer} variant="outline">
                    <Search className="h-4 w-4 mr-2" />
                    Lookup
                  </Button>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="name">
                  Customer Name <span className="text-destructive">*</span>
                </Label>
                <Input
                  id="name"
                  type="text"
                  placeholder="Full name"
                  value={customer.name}
                  onChange={(e) =>
                    setCustomer({ ...customer, name: e.target.value })
                  }
                  disabled={customerExists}
                  className={errors.name ? "border-destructive" : ""}
                />
                {errors.name && (
                  <p className="text-sm text-destructive flex items-center gap-1">
                    <AlertCircle className="h-4 w-4" />
                    {errors.name}
                  </p>
                )}
              </div>

              {customerExists && (
                <div className="p-4 bg-green-50 border border-green-200 rounded-lg flex items-center gap-2">
                  <Check className="h-5 w-5 text-green-600" />
                  <div>
                    <p className="font-medium text-green-900">
                      Existing customer found
                    </p>
                    <p className="text-sm text-green-700">
                      Customer ID: {customer.id}
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Step 2: Location */}
        {currentStep === 2 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold mb-1">Pickup & Dropoff</h2>
              <p className="text-sm text-muted-foreground">
                Select restaurant and delivery address
              </p>
            </div>

            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="restaurant">
                  Restaurant <span className="text-destructive">*</span>
                </Label>
                <Select
                  value={selectedRestaurant}
                  onValueChange={setSelectedRestaurant}
                >
                  <SelectTrigger
                    className={errors.restaurant ? "border-destructive" : ""}
                  >
                    <SelectValue placeholder="Select restaurant" />
                  </SelectTrigger>
                  <SelectContent>
                    {mockRestaurants.map((restaurant) => (
                      <SelectItem
                        key={restaurant.id}
                        value={restaurant.id}
                        disabled={!restaurant.isOpen}
                      >
                        <div className="flex items-center justify-between w-full">
                          <div>
                            <div className="flex items-center gap-2">
                              <Store className="h-4 w-4" />
                              <span>{restaurant.name}</span>
                            </div>
                            <div className="text-xs text-muted-foreground">
                              {restaurant.address}
                            </div>
                          </div>
                          {restaurant.isOpen ? (
                            <Badge variant="outline" className="ml-2 bg-green-50 text-green-700 border-green-300">
                              Open
                            </Badge>
                          ) : (
                            <Badge variant="outline" className="ml-2 bg-red-50 text-red-700 border-red-300">
                              Closed
                            </Badge>
                          )}
                        </div>
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {errors.restaurant && (
                  <p className="text-sm text-destructive flex items-center gap-1">
                    <AlertCircle className="h-4 w-4" />
                    {errors.restaurant}
                  </p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="dropoff">
                  Dropoff Address <span className="text-destructive">*</span>
                </Label>
                <Textarea
                  id="dropoff"
                  placeholder="Enter full delivery address (e.g., Bole, Next to Atlas Hotel, Gate 2)"
                  value={dropoffAddress}
                  onChange={(e) => setDropoffAddress(e.target.value)}
                  rows={3}
                  className={errors.dropoffAddress ? "border-destructive" : ""}
                />
                {errors.dropoffAddress && (
                  <p className="text-sm text-destructive flex items-center gap-1">
                    <AlertCircle className="h-4 w-4" />
                    {errors.dropoffAddress}
                  </p>
                )}
              </div>

              {/* Map Placeholder */}
              <div className="bg-gray-100 rounded-lg h-48 flex items-center justify-center border-2 border-dashed border-gray-300">
                <div className="text-center">
                  <MapPin className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                  <p className="text-sm text-muted-foreground">Map Preview</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Step 3: Items */}
        {currentStep === 3 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold mb-1">Order Items</h2>
              <p className="text-sm text-muted-foreground">
                Select items from menu
              </p>
            </div>

            <div className="grid grid-cols-2 gap-6">
              {/* Menu Items */}
              <div className="space-y-4">
                <h3 className="font-medium">Menu</h3>
                <div className="space-y-2 max-h-96 overflow-y-auto">
                  {mockMenuItems.map((item) => (
                    <Card
                      key={item.id}
                      className={`p-4 cursor-pointer transition-colors ${
                        item.available
                          ? "hover:bg-accent"
                          : "opacity-50 cursor-not-allowed"
                      }`}
                      onClick={() => item.available && handleAddItem(item)}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                          <div className="flex items-center gap-2">
                            <p className="font-medium">{item.name}</p>
                            {!item.available && (
                              <Badge variant="destructive" className="text-xs">
                                Unavailable
                              </Badge>
                            )}
                          </div>
                          <p className="text-sm text-muted-foreground">
                            {item.category}
                          </p>
                        </div>
                        <div className="text-right">
                          <p className="font-medium">{item.price} ETB</p>
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>
              </div>

              {/* Selected Items */}
              <div className="space-y-4">
                <h3 className="font-medium">Selected Items</h3>
                {orderItems.length === 0 ? (
                  <div className="border-2 border-dashed rounded-lg p-8 text-center">
                    <ShoppingBag className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                    <p className="text-sm text-muted-foreground">
                      No items selected yet
                    </p>
                  </div>
                ) : (
                  <div className="space-y-2">
                    {orderItems.map((item) => (
                      <Card key={item.id} className="p-4">
                        <div className="space-y-3">
                          <div className="flex items-center justify-between">
                            <p className="font-medium">{item.name}</p>
                            <p className="font-medium">
                              {item.price * item.quantity} ETB
                            </p>
                          </div>
                          <div className="flex items-center gap-2">
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => handleUpdateQuantity(item.id, -1)}
                            >
                              <Minus className="h-4 w-4" />
                            </Button>
                            <span className="w-12 text-center">
                              {item.quantity}
                            </span>
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => handleUpdateQuantity(item.id, 1)}
                            >
                              <Plus className="h-4 w-4" />
                            </Button>
                          </div>
                          <Input
                            placeholder="Special instructions..."
                            value={item.notes}
                            onChange={(e) =>
                              setOrderItems(
                                orderItems.map((oi) =>
                                  oi.id === item.id
                                    ? { ...oi, notes: e.target.value }
                                    : oi
                                )
                              )
                            }
                            className="text-sm"
                          />
                        </div>
                      </Card>
                    ))}
                  </div>
                )}
                {errors.items && (
                  <p className="text-sm text-destructive flex items-center gap-1">
                    <AlertCircle className="h-4 w-4" />
                    {errors.items}
                  </p>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Step 4: Pricing */}
        {currentStep === 4 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold mb-1">Order Summary</h2>
              <p className="text-sm text-muted-foreground">
                Review pricing and fees
              </p>
            </div>

            <div className="grid grid-cols-2 gap-6">
              {/* Order Details */}
              <div className="space-y-4">
                <h3 className="font-medium">Order Details</h3>
                <Card className="p-4 space-y-3">
                  <div className="flex items-center gap-3">
                    <User className="h-5 w-5 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">Customer</p>
                      <p className="font-medium">{customer.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {customer.phone}
                      </p>
                    </div>
                  </div>
                  <Separator />
                  <div className="flex items-center gap-3">
                    <Store className="h-5 w-5 text-muted-foreground" />
                    <div>
                      <p className="text-sm text-muted-foreground">Restaurant</p>
                      <p className="font-medium">
                        {
                          mockRestaurants.find((r) => r.id === selectedRestaurant)
                            ?.name
                        }
                      </p>
                    </div>
                  </div>
                  <Separator />
                  <div className="flex items-start gap-3">
                    <MapPin className="h-5 w-5 text-muted-foreground mt-1" />
                    <div>
                      <p className="text-sm text-muted-foreground">Dropoff</p>
                      <p className="font-medium">{dropoffAddress}</p>
                    </div>
                  </div>
                </Card>

                <h3 className="font-medium pt-4">Items</h3>
                <div className="space-y-2">
                  {orderItems.map((item) => (
                    <div
                      key={item.id}
                      className="flex items-center justify-between text-sm"
                    >
                      <span>
                        {item.quantity}x {item.name}
                      </span>
                      <span>{item.price * item.quantity} ETB</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Pricing Breakdown */}
              <div className="space-y-4">
                <h3 className="font-medium">Fee Breakdown</h3>
                <Card className="p-4 space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground">Subtotal</span>
                    <span className="font-medium">{totals.subtotal} ETB</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground">Delivery Fee</span>
                    <span className="font-medium">{totals.deliveryFee} ETB</span>
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between text-lg">
                    <span className="font-semibold">Total</span>
                    <span className="font-semibold text-primary">
                      {totals.total} ETB
                    </span>
                  </div>
                </Card>

                <Card className="p-4 space-y-3 bg-gray-50">
                  <p className="text-sm font-medium">Platform Breakdown</p>
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-muted-foreground">Driver Payout</span>
                    <span>{totals.driverPayout} ETB</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-muted-foreground">Platform Fee</span>
                    <span>{totals.platformFee} ETB</span>
                  </div>
                </Card>

                <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                  <p className="text-sm text-blue-900">
                    <strong>Channel:</strong> Sales-created order
                  </p>
                  <p className="text-xs text-blue-700 mt-1">
                    This order was created by a sales agent via phone support
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Step 5: Payment */}
        {currentStep === 5 && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold mb-1">Payment Confirmation</h2>
              <p className="text-sm text-muted-foreground">
                Verify payment status before submitting
              </p>
            </div>

            <div className="max-w-md mx-auto space-y-6">
              <Card className="p-6 text-center">
                <div className="text-3xl font-bold text-primary mb-2">
                  {totals.total} ETB
                </div>
                <p className="text-muted-foreground">Total Amount</p>
              </Card>

              <div className="space-y-2">
                <Label>Payment Status</Label>
                <Select
                  value={paymentStatus}
                  onValueChange={(value) => setPaymentStatus(value as PaymentStatus)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="pending">
                      <div className="flex items-center gap-2">
                        <div className="h-2 w-2 rounded-full bg-yellow-500" />
                        <span>Payment Pending</span>
                      </div>
                    </SelectItem>
                    <SelectItem value="confirmed">
                      <div className="flex items-center gap-2">
                        <div className="h-2 w-2 rounded-full bg-green-500" />
                        <span>Payment Confirmed</span>
                      </div>
                    </SelectItem>
                    <SelectItem value="failed">
                      <div className="flex items-center gap-2">
                        <div className="h-2 w-2 rounded-full bg-red-500" />
                        <span>Payment Failed</span>
                      </div>
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {paymentStatus === "pending" && (
                <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                  <p className="text-sm text-yellow-900 flex items-center gap-2">
                    <AlertCircle className="h-4 w-4" />
                    Awaiting payment confirmation from customer
                  </p>
                </div>
              )}

              {paymentStatus === "confirmed" && (
                <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                  <p className="text-sm text-green-900 flex items-center gap-2">
                    <Check className="h-4 w-4" />
                    Payment confirmed - Ready to submit order
                  </p>
                </div>
              )}

              {paymentStatus === "failed" && (
                <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
                  <p className="text-sm text-red-900 flex items-center gap-2">
                    <AlertCircle className="h-4 w-4" />
                    Payment failed - Please retry or use alternative method
                  </p>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Navigation Buttons */}
        <div className="flex items-center justify-between mt-8 pt-6 border-t">
          <Button
            variant="outline"
            onClick={handleBack}
            disabled={currentStep === 1}
          >
            <ChevronLeft className="h-4 w-4 mr-2" />
            Back
          </Button>

          <div className="text-sm text-muted-foreground">
            Step {currentStep} of 5
          </div>

          {currentStep < 5 ? (
            <Button onClick={handleNext}>
              Next
              <ChevronRight className="h-4 w-4 ml-2" />
            </Button>
          ) : (
            <Button
              onClick={handleSubmitOrder}
              disabled={paymentStatus !== "confirmed"}
              className="bg-primary hover:bg-primary/90"
            >
              <Check className="h-4 w-4 mr-2" />
              Submit Order
            </Button>
          )}
        </div>
      </Card>
    </div>
  );
}
