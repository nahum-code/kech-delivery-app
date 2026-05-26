"use client";

import { useEffect, useMemo, useState } from "react";
import dynamic from "next/dynamic";
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
  UserPlus,
  Store,
  ShoppingBag,
  Banknote,
  CreditCard,
  Sparkles,
} from "lucide-react";
import { toast } from "sonner";

import {
  fetchRestaurantMenu,
  fetchRestaurants,
  type PublicMenuItem,
  type RestaurantRecord,
} from "@/services/catalog";
import {
  createCustomer,
  searchCustomers,
  type CustomerSearchResult,
} from "@/services/customers";

import { createSalesOrder, quoteDeliveryFee, type DeliveryFeeQuote } from "@/services/orders";
import { parseApiError } from "@/lib/order-utils";
import { reverseGeocode } from "../components/DropoffMapPicker";

const DropoffMapPicker = dynamic(
  () => import("../components/DropoffMapPicker").then((m) => m.DropoffMapPicker),
  {
    ssr: false,
    loading: () => (
      <div className="bg-gray-100 rounded-lg h-[280px] flex items-center justify-center">
        <p className="text-sm text-muted-foreground">Loading map…</p>
      </div>
    ),
  },
);

type CatalogMenuRow = PublicMenuItem & { category: string };

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

function generateTempPassword(): string {
  // Cryptographically random, 12 chars from [A-Za-z0-9],
  // guaranteed to contain at least one letter and one digit so it
  // passes Django's default NumericPasswordValidator + min length 8.
  const letters = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz"; // no I/O/l/0/1 lookalikes
  const digits = "23456789";
  const alphabet = letters + digits;
  const length = 12;
  const buf = new Uint32Array(length);
  crypto.getRandomValues(buf);
  const chars: string[] = [];
  for (let i = 0; i < length; i += 1) {
    chars.push(alphabet[buf[i] % alphabet.length]);
  }
  // Force at least one letter + one digit
  const letterPick = new Uint32Array(1);
  const digitPick = new Uint32Array(1);
  crypto.getRandomValues(letterPick);
  crypto.getRandomValues(digitPick);
  chars[0] = letters[letterPick[0] % letters.length];
  chars[length - 1] = digits[digitPick[0] % digits.length];
  return chars.join("");
}

export function CreateOrderPage() {
  const [currentStep, setCurrentStep] = useState<Step>(1);
  const [customer, setCustomer] = useState<Customer>({ phone: "", name: "" });
  const [customerExists, setCustomerExists] = useState(false);
  const [customerSearchLoading, setCustomerSearchLoading] = useState(false);
  const [customerResults, setCustomerResults] = useState<CustomerSearchResult[]>([]);
  const [customerSearchError, setCustomerSearchError] = useState<string | null>(null);
  const [showCreateCustomer, setShowCreateCustomer] = useState(false);
  const [createCustomerForm, setCreateCustomerForm] = useState({ phone: "", name: "", password: "" });
  const [createCustomerError, setCreateCustomerError] = useState<string | null>(null);
  const [createCustomerLoading, setCreateCustomerLoading] = useState(false);
  const [selectedRestaurant, setSelectedRestaurant] = useState("");
  const [dropoffAddress, setDropoffAddress] = useState("");
  const [dropoffCoords, setDropoffCoords] = useState<{ latitude: number; longitude: number } | null>(null);
  const [dropoffGeocoding, setDropoffGeocoding] = useState(false);
  const [feeQuote, setFeeQuote] = useState<DeliveryFeeQuote | null>(null);
  const [feeQuoteLoading, setFeeQuoteLoading] = useState(false);
  const [feeQuoteError, setFeeQuoteError] = useState<string | null>(null);
  const [orderItems, setOrderItems] = useState<OrderItem[]>([]);
  const [paymentStatus, setPaymentStatus] = useState<PaymentStatus>("pending");
  const [restaurants, setRestaurants] = useState<RestaurantRecord[]>([]);
  const [catalogMenu, setCatalogMenu] = useState<CatalogMenuRow[]>([]);
  const [catalogLoading, setCatalogLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    void fetchRestaurants()
      .then(setRestaurants)
      .catch((e) => toast.error(e instanceof Error ? e.message : "Failed to load restaurants"));
  }, []);

  useEffect(() => {
    if (!selectedRestaurant) return;
    const timer = setTimeout(() => setCatalogLoading(true), 0);
    void fetchRestaurantMenu(Number(selectedRestaurant))
      .then((payload) => {
        const rows: CatalogMenuRow[] = [];
        for (const category of payload.categories) {
          for (const item of category.items) {
            rows.push({ ...item, category: category.name });
          }
        }
        setCatalogMenu(rows);
      })
      .catch((e) => {
        setCatalogMenu([]);
        toast.error(e instanceof Error ? e.message : "Failed to load menu");
      })
      .finally(() => setCatalogLoading(false));
    return () => clearTimeout(timer);
  }, [selectedRestaurant]);

  const menuItems = useMemo(
    () => (selectedRestaurant ? catalogMenu : []),
    [catalogMenu, selectedRestaurant],
  );

  const validateStep = (step: Step): boolean => {
    const newErrors: Record<string, string> = {};

    if (step === 1) {
      if (!customer.id) {
        newErrors.phone = "Select a registered customer from search results";
      }
    }

    if (step === 2) {
      if (!selectedRestaurant) {
        newErrors.restaurant = "Please select a restaurant";
      }
      if (!dropoffAddress.trim()) {
        newErrors.dropoffAddress = "Dropoff address is required";
      }
      const restaurant = restaurants.find((r) => String(r.id) === selectedRestaurant);
      if (restaurant && !restaurant.is_active) {
        newErrors.restaurant = "Selected restaurant is currently inactive";
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

  useEffect(() => {
    const q = customer.phone.trim();
    if (q.length < 2) return;

    const timer = setTimeout(() => {
      setCustomerSearchLoading(true);
      setCustomerSearchError(null);
      void searchCustomers(q)
        .then((data) => {
          setCustomerResults(data.results);
          if (data.results.length === 0) {
            setCustomerSearchError("No customers found. Customer must register in the app first.");
          }
        })
        .catch((e) => {
          setCustomerResults([]);
          setCustomerSearchError(parseApiError(e, "Customer search failed"));
        })
        .finally(() => setCustomerSearchLoading(false));
    }, 400);
    return () => clearTimeout(timer);
  }, [customer.phone]);

  useEffect(() => {
    if (!selectedRestaurant || !dropoffCoords) {
      setFeeQuote(null);
      setFeeQuoteError(null);
      setFeeQuoteLoading(false);
      return;
    }
    const restaurantId = Number(selectedRestaurant);
    if (!Number.isFinite(restaurantId)) return;
    let cancelled = false;
    setFeeQuoteLoading(true);
    setFeeQuoteError(null);
    void quoteDeliveryFee({
      restaurant_id: restaurantId,
      latitude: dropoffCoords.latitude,
      longitude: dropoffCoords.longitude,
    })
      .then((data) => {
        if (!cancelled) setFeeQuote(data);
      })
      .catch((e) => {
        if (!cancelled) {
          setFeeQuote(null);
          setFeeQuoteError(parseApiError(e, "Could not fetch delivery fee"));
        }
      })
      .finally(() => {
        if (!cancelled) setFeeQuoteLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [selectedRestaurant, dropoffCoords]);

  const visibleCustomerResults =
    customer.phone.trim().length >= 2 && !customerExists && !showCreateCustomer
      ? customerResults
      : [];

  const handleSelectCustomer = (row: CustomerSearchResult) => {
    setCustomer({ id: String(row.id), phone: row.phone, name: row.name });
      setCustomerExists(true);
    setCustomerResults([]);
    setErrors({});
    toast.success("Customer selected");
  };

  const handleGenerateCustomerPassword = () => {
    setCreateCustomerForm((prev) => ({ ...prev, password: generateTempPassword() }));
  };

  const handleStartCreateCustomer = () => {
    setShowCreateCustomer(true);
    setCreateCustomerError(null);
    setCreateCustomerForm({
      phone: customer.phone.trim(),
      name: "",
      password: "",
    });
  };

  const handleCancelCreateCustomer = () => {
    setShowCreateCustomer(false);
    setCreateCustomerError(null);
    setCreateCustomerForm({ phone: "", name: "", password: "" });
  };

  const handleSubmitCreateCustomer = async () => {
    const phone = createCustomerForm.phone.trim();
    const name = createCustomerForm.name.trim();
    const password = createCustomerForm.password;
    if (!phone || !name || !password) {
      setCreateCustomerError("Phone, name, and temp password are all required.");
      return;
    }
    setCreateCustomerLoading(true);
    setCreateCustomerError(null);
    try {
      const created = await createCustomer({ phone, name, password });
      handleSelectCustomer(created);
      setShowCreateCustomer(false);
      setCreateCustomerForm({ phone: "", name: "", password: "" });
      setCustomerSearchError(null);
      toast.success("Customer created and selected");
    } catch (e) {
      setCreateCustomerError(e instanceof Error ? e.message : "Failed to create customer");
    } finally {
      setCreateCustomerLoading(false);
    }
  };

  const handleAddItem = (item: CatalogMenuRow) => {
    const itemId = String(item.id);
    const price = Number.parseFloat(item.price) || 0;
    const existing = orderItems.find((oi) => oi.id === itemId);
    if (existing) {
      setOrderItems(
        orderItems.map((oi) =>
          oi.id === itemId ? { ...oi, quantity: oi.quantity + 1 } : oi
        )
      );
    } else {
      setOrderItems([
        ...orderItems,
        { id: itemId, name: item.name, price, quantity: 1, notes: "" },
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
    // Use the live quote when we have one; otherwise fall back to the
    // 0–1 km tier (60 birr total) so the wizard renders sensibly before
    // a dropoff is pinned. Backend recomputes the authoritative pricing
    // when the order is submitted.
    const deliveryFee = feeQuote ? Number.parseFloat(feeQuote.delivery_fee) : 60;
    const driverPayout = feeQuote ? Number.parseFloat(feeQuote.driver_payout) : 50;
    const platformFee = feeQuote ? Number.parseFloat(feeQuote.platform_fee) : 10;
    const distanceKm =
      feeQuote && feeQuote.distance_km ? Number.parseFloat(feeQuote.distance_km) : null;
    const total = subtotal + deliveryFee;

    return { subtotal, deliveryFee, driverPayout, platformFee, distanceKm, total };
  };

  const handleSubmitOrder = async () => {
    if (paymentStatus !== "confirmed") {
      toast.error("Please confirm payment before submitting");
      return;
    }
    if (!customer.id) {
      toast.error("Customer must be registered (set customer ID after lookup)");
      return;
    }
    const backendPaymentStatus: "pending" | "paid" | "failed" =
      paymentStatus === "confirmed" ? "paid" : paymentStatus;
    // Flatten per-item special instructions into the order-level note —
    // same pattern the customer mobile uses at checkout. Drivers, admin,
    // and sales monitors all surface `customer_note`, so this is the
    // single channel that gets the per-item notes in front of everyone.
    const customerNote = orderItems
      .filter((item) => item.notes.trim().length > 0)
      .map((item) => `${item.name}: ${item.notes.trim()}`)
      .join("\n");

    try {
      const created = await createSalesOrder({
        customer_id: Number(customer.id),
        restaurant_id: Number(selectedRestaurant),
        items: orderItems.map((item) => ({
          menu_item_id: Number(item.id),
          quantity: item.quantity,
        })),
        delivery_address: {
          receiver_name: customer.name,
          phone: customer.phone,
          address_line: dropoffAddress,
          ...(dropoffCoords
            ? { latitude: dropoffCoords.latitude, longitude: dropoffCoords.longitude }
            : {}),
        },
        ...(customerNote.length > 0 ? { customer_note: customerNote } : {}),
        payment_status: backendPaymentStatus,
      });
      toast.success(`Order ${created.reference} created`, {
        description: `${customer.name} • ${created.total_amount} ETB • Payment ${created.payment_status}`,
        duration: 6000,
      });
      setCurrentStep(1);
      setCustomer({ phone: "", name: "" });
      setCustomerExists(false);
      setShowCreateCustomer(false);
      setCreateCustomerForm({ phone: "", name: "", password: "" });
      setCreateCustomerError(null);
      setSelectedRestaurant("");
      setDropoffAddress("");
      setDropoffCoords(null);
      setFeeQuote(null);
      setFeeQuoteError(null);
      setOrderItems([]);
      setPaymentStatus("pending");
    } catch (e) {
      toast.error(e instanceof Error ? e.message : "Order creation failed");
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
                Look up an existing customer, or register a new one.
              </p>
            </div>

            <div className="space-y-4">
              {!customerExists && (
                <div className="grid grid-cols-2 gap-2 rounded-lg border bg-muted/40 p-1">
                  <Button
                    type="button"
                    variant={showCreateCustomer ? "ghost" : "default"}
                    onClick={() => {
                      if (showCreateCustomer) handleCancelCreateCustomer();
                    }}
                    className="justify-center"
                  >
                    <Search className="h-4 w-4 mr-2" />
                    Find existing
                  </Button>
                  <Button
                    type="button"
                    variant={showCreateCustomer ? "default" : "ghost"}
                    onClick={() => {
                      if (!showCreateCustomer) handleStartCreateCustomer();
                    }}
                    className="justify-center"
                  >
                    <UserPlus className="h-4 w-4 mr-2" />
                    Register new
                  </Button>
                </div>
              )}

              <div className="space-y-2">
                {!showCreateCustomer && (
                  <>
                    <Label htmlFor="customer-search">Customer search</Label>
                    <div className="relative">
                      <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                    <Input
                        id="customer-search"
                        type="text"
                        placeholder="Phone or name (min 2 characters)"
                      value={customer.phone}
                        onChange={(e) => {
                          setCustomerExists(false);
                          setCustomer({ phone: e.target.value, name: "", id: undefined });
                        }}
                        disabled={customerExists}
                        className={`pl-10 ${errors.phone ? "border-destructive" : ""}`}
                      />
                    </div>
                    {customerSearchLoading && (
                      <p className="text-sm text-muted-foreground">Searching...</p>
                    )}
                    {customerSearchError && !customerExists && (
                      <p className="text-sm text-amber-900 flex items-center gap-1">
                        <AlertCircle className="h-4 w-4" />
                        {customerSearchError} You can switch to <strong>Register new</strong> above.
                      </p>
                    )}
                  </>
                )}

                {showCreateCustomer && !customerExists && (
                  <div className="space-y-3 rounded-lg border bg-muted/30 p-4">
                    <div className="flex items-center justify-between">
                      <p className="font-medium flex items-center gap-2">
                        <UserPlus className="h-4 w-4" />
                        Register new customer
                      </p>
                      <Button
                        type="button"
                        size="sm"
                        variant="ghost"
                        onClick={handleCancelCreateCustomer}
                        disabled={createCustomerLoading}
                      >
                        Cancel
                  </Button>
                </div>
                    <div className="grid gap-3 sm:grid-cols-2">
                      <div className="space-y-1">
                        <Label htmlFor="new-customer-phone">Phone</Label>
                        <Input
                          id="new-customer-phone"
                          type="tel"
                          placeholder="e.g. 0911223344"
                          value={createCustomerForm.phone}
                          onChange={(e) =>
                            setCreateCustomerForm((prev) => ({ ...prev, phone: e.target.value }))
                          }
                          disabled={createCustomerLoading}
                        />
              </div>
                      <div className="space-y-1">
                        <Label htmlFor="new-customer-name">Full name</Label>
                <Input
                          id="new-customer-name"
                  type="text"
                          placeholder="Customer name"
                          value={createCustomerForm.name}
                  onChange={(e) =>
                            setCreateCustomerForm((prev) => ({ ...prev, name: e.target.value }))
                          }
                          disabled={createCustomerLoading}
                        />
                      </div>
                      <div className="space-y-1 sm:col-span-2">
                        <Label htmlFor="new-customer-password">Temporary password</Label>
                        <div className="flex gap-2">
                          <Input
                            id="new-customer-password"
                            type="text"
                            placeholder="Tell the customer this password"
                            value={createCustomerForm.password}
                            onChange={(e) =>
                              setCreateCustomerForm((prev) => ({ ...prev, password: e.target.value }))
                            }
                            disabled={createCustomerLoading}
                            className="flex-1"
                          />
                          <Button
                            type="button"
                            variant="outline"
                            onClick={handleGenerateCustomerPassword}
                            disabled={createCustomerLoading}
                          >
                            <Sparkles className="h-4 w-4 mr-2" />
                            Generate
                          </Button>
                        </div>
                        <p className="text-xs text-muted-foreground">
                          Share this with the customer on the call so they can log in to the mobile app later.
                        </p>
                      </div>
                    </div>
                    {createCustomerError && (
                  <p className="text-sm text-destructive flex items-center gap-1">
                    <AlertCircle className="h-4 w-4" />
                        {createCustomerError}
                      </p>
                    )}
                    <div className="flex justify-end">
                      <Button
                        type="button"
                        onClick={handleSubmitCreateCustomer}
                        disabled={createCustomerLoading}
                      >
                        {createCustomerLoading ? "Creating..." : "Create & select"}
                      </Button>
                    </div>
                  </div>
                )}
                {errors.phone && (
                  <p className="text-sm text-destructive flex items-center gap-1">
                    <AlertCircle className="h-4 w-4" />
                    {errors.phone}
                  </p>
                )}
                {visibleCustomerResults.length > 0 && (
                  <ul className="border rounded-lg divide-y max-h-48 overflow-y-auto">
                    {visibleCustomerResults.map((row) => (
                      <li key={row.id}>
                        <button
                          type="button"
                          className="w-full px-4 py-3 text-left hover:bg-muted/50 flex items-center gap-3"
                          onClick={() => handleSelectCustomer(row)}
                        >
                          <User className="h-4 w-4 text-[#800020]" />
                          <div>
                            <p className="font-medium">{row.name}</p>
                            <p className="text-sm text-muted-foreground">{row.phone}</p>
                          </div>
                        </button>
                      </li>
                    ))}
                  </ul>
                )}
              </div>

              {customerExists && customer.id && (
                <div className="p-4 bg-green-50 border border-green-200 rounded-lg flex items-center gap-2">
                  <Check className="h-5 w-5 text-green-600" />
                  <div>
                    <p className="font-medium text-green-900">{customer.name}</p>
                    <p className="text-sm text-green-700">
                      {customer.phone} · ID {customer.id}
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
                    {restaurants.map((restaurant) => (
                      <SelectItem
                        key={restaurant.id}
                        value={String(restaurant.id)}
                        disabled={!restaurant.is_active}
                      >
                        <div className="flex items-center justify-between w-full">
                          <div>
                            <div className="flex items-center gap-2">
                              <Store className="h-4 w-4" />
                              <span>{restaurant.name}</span>
                            </div>
                            <div className="text-xs text-muted-foreground">
                              {restaurant.address_text}
                            </div>
                          </div>
                          {restaurant.is_active ? (
                            <Badge variant="outline" className="ml-2 bg-green-50 text-green-700 border-green-300">
                              Active
                            </Badge>
                          ) : (
                            <Badge variant="outline" className="ml-2 bg-red-50 text-red-700 border-red-300">
                              Inactive
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

              {(() => {
                const restaurant = restaurants.find(
                  (r) => String(r.id) === selectedRestaurant,
                );
                const rLat = restaurant ? Number.parseFloat(restaurant.latitude) : NaN;
                const rLng = restaurant ? Number.parseFloat(restaurant.longitude) : NaN;
                const hasCoords = Number.isFinite(rLat) && Number.isFinite(rLng);
                if (!restaurant) {
                  return (
                    <div className="bg-gray-100 rounded-lg h-[280px] flex items-center justify-center border-2 border-dashed border-gray-300">
                      <div className="text-center">
                        <MapPin className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                        <p className="text-sm text-muted-foreground">
                          Select a restaurant above to pick the dropoff
                        </p>
                      </div>
                    </div>
                  );
                }
                if (!hasCoords) {
                  return (
                    <div className="bg-amber-50 rounded-lg h-[280px] flex items-center justify-center border border-amber-200">
                      <div className="text-center px-4">
                        <MapPin className="h-10 w-10 text-amber-500 mx-auto mb-2" />
                        <p className="text-sm text-amber-900">
                          {restaurant.name} has no coordinates set yet.
                        </p>
                      </div>
                    </div>
                  );
                }
                return (
                  <div className="space-y-2">
                    <p className="text-xs text-muted-foreground">
                      Click on the map to pin the dropoff. The address below
                      will fill automatically — you can edit it if needed.
                    </p>
                    <DropoffMapPicker
                      restaurant={{ latitude: rLat, longitude: rLng, name: restaurant.name }}
                      dropoff={dropoffCoords}
                      onPick={async (pos) => {
                        setDropoffCoords(pos);
                        setDropoffGeocoding(true);
                        const address = await reverseGeocode(pos.latitude, pos.longitude);
                        setDropoffGeocoding(false);
                        if (address) setDropoffAddress(address);
                      }}
                    />
                    <div className="flex items-center justify-between text-xs text-muted-foreground">
                      <span>
                        <span className="inline-block h-2 w-2 rounded-full bg-[#3b82c4] mr-1" />
                        Restaurant
                        <span className="inline-block h-2 w-2 rounded-full bg-blue-600 ml-3 mr-1" />
                        Dropoff
                      </span>
                      {dropoffCoords && (
                        <span>
                          {dropoffCoords.latitude.toFixed(5)}, {dropoffCoords.longitude.toFixed(5)}
                        </span>
                      )}
                    </div>
                    {dropoffCoords && (
                      <div className="rounded-md border border-[#800020]/20 bg-[#800020]/5 px-3 py-2 text-sm">
                        {feeQuoteLoading && (
                          <span className="text-muted-foreground">Calculating delivery fee…</span>
                        )}
                        {!feeQuoteLoading && feeQuoteError && (
                          <span className="text-destructive">{feeQuoteError}</span>
                        )}
                        {!feeQuoteLoading && !feeQuoteError && feeQuote && (
                          <span>
                            Distance:{" "}
                            <strong>
                              {feeQuote.distance_km
                                ? `${Number.parseFloat(feeQuote.distance_km).toFixed(2)} km`
                                : "—"}
                            </strong>
                            <span className="mx-2 text-muted-foreground">•</span>
                            Delivery fee:{" "}
                            <strong className="text-[#800020]">{feeQuote.delivery_fee} ETB</strong>{" "}
                            <span className="text-muted-foreground">
                              ({feeQuote.driver_payout} driver + {feeQuote.platform_fee} platform)
                            </span>
                          </span>
                        )}
                      </div>
                    )}
                  </div>
                );
              })()}

              <div className="space-y-2">
                <Label htmlFor="dropoff">
                  Dropoff Address <span className="text-destructive">*</span>
                </Label>
                <Textarea
                  id="dropoff"
                  placeholder="Click on the map above, or type the address manually"
                  value={dropoffAddress}
                  onChange={(e) => setDropoffAddress(e.target.value)}
                  rows={3}
                  className={errors.dropoffAddress ? "border-destructive" : ""}
                />
                {dropoffGeocoding && (
                  <p className="text-xs text-muted-foreground">Looking up address…</p>
                )}
                {errors.dropoffAddress && (
                  <p className="text-sm text-destructive flex items-center gap-1">
                    <AlertCircle className="h-4 w-4" />
                    {errors.dropoffAddress}
                  </p>
                )}
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
                  {catalogLoading ? (
                    <p className="text-sm text-muted-foreground">Loading menu...</p>
                  ) : menuItems.length === 0 ? (
                    <p className="text-sm text-muted-foreground">Select a restaurant with menu items.</p>
                  ) : (
                    menuItems.map((item) => (
                    <Card
                      key={item.id}
                        className="p-4 cursor-pointer transition-colors hover:bg-accent"
                        onClick={() => handleAddItem(item)}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex-1">
                            <p className="font-medium">{item.name}</p>
                            <p className="text-sm text-muted-foreground">{item.category}</p>
                          </div>
                          <div className="text-right">
                            <p className="font-medium">
                              {item.price} {item.currency}
                          </p>
                        </div>
                      </div>
                    </Card>
                    ))
                  )}
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
                          restaurants.find((r) => String(r.id) === selectedRestaurant)
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
