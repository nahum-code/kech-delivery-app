import { OrderStatus, DriverStatus } from "@/components/shared/StatusBadge";

export interface Order {
  id: string;
  orderNumber: string;
  customer: string;
  restaurant: string;
  driver: string | null;
  status: OrderStatus;
  paymentState: "Pending" | "Confirmed" | "Failed";
  createdAt: Date;
  distance: string;
  deliveryFee: number;
  driverPayout: number;
  platformFee: number;
  pickupAddress: string;
  dropoffAddress: string;
  timeline: {
    status: string;
    timestamp: Date;
  }[];
}

export interface Driver {
  id: string;
  fullName: string;
  phone: string;
  vehicleType: string;
  submittedDate: Date;
  status: DriverStatus;
  isOnline: boolean;
  documents: {
    license: string;
    id: string;
    vehicle: string;
  };
  notes: string;
}

export interface Restaurant {
  id: string;
  name: string;
  phone: string;
  location: string;
  openingHours: string;
  status: "Active" | "Inactive";
  menuCount: number;
  lastUpdated: Date;
}

export interface MenuItem {
  id: string;
  name: string;
  category: string;
  price: number;
  available: boolean;
  image: string;
  description: string;
}

export interface Category {
  id: string;
  name: string;
  order: number;
  active: boolean;
}

// Mock Orders Data
export const mockOrders: Order[] = [
  {
    id: "1",
    orderNumber: "ORD-2024-0456",
    customer: "Mohammed Ali",
    restaurant: "Café Arabe",
    driver: "Hassan Ahmed",
    status: "PickedUp",
    paymentState: "Confirmed",
    createdAt: new Date("2026-03-19T10:30:00"),
    distance: "3.2 km",
    deliveryFee: 15,
    driverPayout: 12,
    platformFee: 3,
    pickupAddress: "123 Rue de la Kasbah, Marrakech",
    dropoffAddress: "456 Avenue Mohammed V, Marrakech",
    timeline: [
      { status: "PaymentConfirmed", timestamp: new Date("2026-03-19T10:30:00") },
      { status: "SearchingDriver", timestamp: new Date("2026-03-19T10:31:00") },
      { status: "Assigned", timestamp: new Date("2026-03-19T10:35:00") },
      { status: "Accepted", timestamp: new Date("2026-03-19T10:36:00") },
      { status: "PickedUp", timestamp: new Date("2026-03-19T10:50:00") },
    ],
  },
  {
    id: "2",
    orderNumber: "ORD-2024-0457",
    customer: "Fatima Zahra",
    restaurant: "Le Jardin",
    driver: null,
    status: "SearchingDriver",
    paymentState: "Confirmed",
    createdAt: new Date("2026-03-19T11:15:00"),
    distance: "5.8 km",
    deliveryFee: 20,
    driverPayout: 16,
    platformFee: 4,
    pickupAddress: "32 Rue Souk Semmarine, Marrakech",
    dropoffAddress: "78 Boulevard Zerktouni, Marrakech",
    timeline: [
      { status: "PaymentConfirmed", timestamp: new Date("2026-03-19T11:15:00") },
      { status: "SearchingDriver", timestamp: new Date("2026-03-19T11:16:00") },
    ],
  },
  {
    id: "3",
    orderNumber: "ORD-2024-0458",
    customer: "Youssef Ben",
    restaurant: "Nomad",
    driver: "Rachid Moha",
    status: "Delivered",
    paymentState: "Confirmed",
    createdAt: new Date("2026-03-19T09:45:00"),
    distance: "2.1 km",
    deliveryFee: 12,
    driverPayout: 10,
    platformFee: 2,
    pickupAddress: "1 Rue Amsefah, Marrakech",
    dropoffAddress: "90 Rue Riad Zitoun, Marrakech",
    timeline: [
      { status: "PaymentConfirmed", timestamp: new Date("2026-03-19T09:45:00") },
      { status: "SearchingDriver", timestamp: new Date("2026-03-19T09:46:00") },
      { status: "Assigned", timestamp: new Date("2026-03-19T09:48:00") },
      { status: "Accepted", timestamp: new Date("2026-03-19T09:49:00") },
      { status: "PickedUp", timestamp: new Date("2026-03-19T10:00:00") },
      { status: "Delivered", timestamp: new Date("2026-03-19T10:15:00") },
    ],
  },
  {
    id: "4",
    orderNumber: "ORD-2024-0459",
    customer: "Sara Idrissi",
    restaurant: "Dar Moha",
    driver: "Omar Khalil",
    status: "Accepted",
    paymentState: "Confirmed",
    createdAt: new Date("2026-03-19T11:30:00"),
    distance: "4.5 km",
    deliveryFee: 18,
    driverPayout: 14,
    platformFee: 4,
    pickupAddress: "81 Rue Dar El Bacha, Marrakech",
    dropoffAddress: "45 Avenue Hassan II, Marrakech",
    timeline: [
      { status: "PaymentConfirmed", timestamp: new Date("2026-03-19T11:30:00") },
      { status: "SearchingDriver", timestamp: new Date("2026-03-19T11:31:00") },
      { status: "Assigned", timestamp: new Date("2026-03-19T11:33:00") },
      { status: "Accepted", timestamp: new Date("2026-03-19T11:34:00") },
    ],
  },
  {
    id: "5",
    orderNumber: "ORD-2024-0460",
    customer: "Karim Hassan",
    restaurant: "Café Arabe",
    driver: null,
    status: "PaymentPending",
    paymentState: "Pending",
    createdAt: new Date("2026-03-19T11:45:00"),
    distance: "6.2 km",
    deliveryFee: 22,
    driverPayout: 18,
    platformFee: 4,
    pickupAddress: "123 Rue de la Kasbah, Marrakech",
    dropoffAddress: "120 Avenue Yaacoub El Mansour, Marrakech",
    timeline: [
      { status: "PaymentPending", timestamp: new Date("2026-03-19T11:45:00") },
    ],
  },
  {
    id: "6",
    orderNumber: "ORD-2024-0461",
    customer: "Nadia El Amrani",
    restaurant: "Le Jardin",
    driver: null,
    status: "SearchingDriver",
    paymentState: "Confirmed",
    createdAt: new Date("2026-03-19T12:00:00"),
    distance: "4.1 km",
    deliveryFee: 17,
    driverPayout: 13,
    platformFee: 4,
    pickupAddress: "32 Rue Souk Semmarine, Marrakech",
    dropoffAddress: "55 Rue de la Liberté, Marrakech",
    timeline: [
      { status: "PaymentConfirmed", timestamp: new Date("2026-03-19T12:00:00") },
      { status: "SearchingDriver", timestamp: new Date("2026-03-19T12:01:00") },
    ],
  },
  {
    id: "7",
    orderNumber: "ORD-2024-0462",
    customer: "Ahmed Bennani",
    restaurant: "Nomad",
    driver: "Hassan Ahmed",
    status: "Completed",
    paymentState: "Confirmed",
    createdAt: new Date("2026-03-19T09:00:00"),
    distance: "2.8 km",
    deliveryFee: 14,
    driverPayout: 11,
    platformFee: 3,
    pickupAddress: "1 Rue Amsefah, Marrakech",
    dropoffAddress: "23 Boulevard Mohammed VI, Marrakech",
    timeline: [
      { status: "PaymentConfirmed", timestamp: new Date("2026-03-19T09:00:00") },
      { status: "SearchingDriver", timestamp: new Date("2026-03-19T09:01:00") },
      { status: "Assigned", timestamp: new Date("2026-03-19T09:03:00") },
      { status: "Accepted", timestamp: new Date("2026-03-19T09:04:00") },
      { status: "PickedUp", timestamp: new Date("2026-03-19T09:15:00") },
      { status: "Delivered", timestamp: new Date("2026-03-19T09:28:00") },
      { status: "Completed", timestamp: new Date("2026-03-19T09:28:00") },
    ],
  },
  {
    id: "8",
    orderNumber: "ORD-2024-0463",
    customer: "Laila Mahdi",
    restaurant: "Al Fassia",
    driver: null,
    status: "SearchingDriver",
    paymentState: "Confirmed",
    createdAt: new Date("2026-03-19T12:10:00"),
    distance: "7.5 km",
    deliveryFee: 25,
    driverPayout: 20,
    platformFee: 5,
    pickupAddress: "55 Boulevard Zerktouni, Marrakech",
    dropoffAddress: "88 Avenue Prince Moulay Abdellah, Marrakech",
    timeline: [
      { status: "PaymentConfirmed", timestamp: new Date("2026-03-19T12:10:00") },
      { status: "SearchingDriver", timestamp: new Date("2026-03-19T12:11:00") },
    ],
  },
];

// Mock Drivers Data
export const mockDrivers: Driver[] = [
  {
    id: "1",
    fullName: "Hassan Ahmed",
    phone: "+212 6 12 34 56 78",
    vehicleType: "Motorcycle",
    submittedDate: new Date("2026-03-10"),
    status: "Approved",
    isOnline: true,
    documents: {
      license: "DL-2024-001.jpg",
      id: "ID-2024-001.jpg",
      vehicle: "VR-2024-001.jpg",
    },
    notes: "Active driver, excellent rating",
  },
  {
    id: "2",
    fullName: "Rachid Moha",
    phone: "+212 6 23 45 67 89",
    vehicleType: "Scooter",
    submittedDate: new Date("2026-03-12"),
    status: "Approved",
    isOnline: true,
    documents: {
      license: "DL-2024-002.jpg",
      id: "ID-2024-002.jpg",
      vehicle: "VR-2024-002.jpg",
    },
    notes: "Approved on 2026-03-15",
  },
  {
    id: "3",
    fullName: "Omar Khalil",
    phone: "+212 6 34 56 78 90",
    vehicleType: "Motorcycle",
    submittedDate: new Date("2026-03-15"),
    status: "UnderReview",
    isOnline: false,
    documents: {
      license: "DL-2024-003.jpg",
      id: "ID-2024-003.jpg",
      vehicle: "VR-2024-003.jpg",
    },
    notes: "Documents under review",
  },
  {
    id: "4",
    fullName: "Amine Benali",
    phone: "+212 6 45 67 89 01",
    vehicleType: "Scooter",
    submittedDate: new Date("2026-03-17"),
    status: "DocsSubmitted",
    isOnline: false,
    documents: {
      license: "DL-2024-004.jpg",
      id: "ID-2024-004.jpg",
      vehicle: "VR-2024-004.jpg",
    },
    notes: "Awaiting initial review",
  },
  {
    id: "5",
    fullName: "Said El Fassi",
    phone: "+212 6 56 78 90 12",
    vehicleType: "Motorcycle",
    submittedDate: new Date("2026-03-18"),
    status: "Rejected",
    isOnline: false,
    documents: {
      license: "DL-2024-005.jpg",
      id: "ID-2024-005.jpg",
      vehicle: "VR-2024-005.jpg",
    },
    notes: "Rejected: License expired",
  },
];

// Mock Restaurants Data
export const mockRestaurants: Restaurant[] = [
  {
    id: "1",
    name: "Café Arabe",
    phone: "+212 5 24 42 97 28",
    location: "123 Rue de la Kasbah, Marrakech",
    openingHours: "09:00 - 23:00",
    status: "Active",
    menuCount: 45,
    lastUpdated: new Date("2026-03-18"),
  },
  {
    id: "2",
    name: "Le Jardin",
    phone: "+212 5 24 37 82 95",
    location: "32 Rue Souk Semmarine, Marrakech",
    openingHours: "12:00 - 22:00",
    status: "Active",
    menuCount: 38,
    lastUpdated: new Date("2026-03-17"),
  },
  {
    id: "3",
    name: "Nomad",
    phone: "+212 5 24 38 16 09",
    location: "1 Rue Amsefah, Marrakech",
    openingHours: "10:00 - 23:00",
    status: "Active",
    menuCount: 52,
    lastUpdated: new Date("2026-03-19"),
  },
  {
    id: "4",
    name: "Dar Moha",
    phone: "+212 5 24 38 64 00",
    location: "81 Rue Dar El Bacha, Marrakech",
    openingHours: "12:00 - 23:00",
    status: "Inactive",
    menuCount: 41,
    lastUpdated: new Date("2026-03-10"),
  },
  {
    id: "5",
    name: "Al Fassia",
    phone: "+212 5 24 43 40 60",
    location: "55 Boulevard Zerktouni, Marrakech",
    openingHours: "12:00 - 22:30",
    status: "Active",
    menuCount: 36,
    lastUpdated: new Date("2026-03-16"),
  },
];

// Mock Menu Categories
export const mockCategories: Category[] = [
  { id: "1", name: "Appetizers", order: 1, active: true },
  { id: "2", name: "Main Courses", order: 2, active: true },
  { id: "3", name: "Desserts", order: 3, active: true },
  { id: "4", name: "Beverages", order: 4, active: true },
  { id: "5", name: "Salads", order: 5, active: true },
];

// Mock Menu Items
export const mockMenuItems: MenuItem[] = [
  {
    id: "1",
    name: "Moroccan Salad",
    category: "Appetizers",
    price: 35,
    available: true,
    image: "salad.jpg",
    description: "Fresh mixed vegetables with Moroccan spices",
  },
  {
    id: "2",
    name: "Chicken Tagine",
    category: "Main Courses",
    price: 85,
    available: true,
    image: "tagine.jpg",
    description: "Traditional chicken tagine with preserved lemons",
  },
  {
    id: "3",
    name: "Couscous Royal",
    category: "Main Courses",
    price: 95,
    available: true,
    image: "couscous.jpg",
    description: "Couscous with seven vegetables and meat",
  },
  {
    id: "4",
    name: "Pastilla",
    category: "Appetizers",
    price: 65,
    available: true,
    image: "pastilla.jpg",
    description: "Sweet and savory pastry with chicken",
  },
  {
    id: "5",
    name: "Mint Tea",
    category: "Beverages",
    price: 15,
    available: true,
    image: "tea.jpg",
    description: "Traditional Moroccan mint tea",
  },
  {
    id: "6",
    name: "Baklava",
    category: "Desserts",
    price: 40,
    available: false,
    image: "baklava.jpg",
    description: "Sweet pastry with nuts and honey",
  },
  {
    id: "7",
    name: "Harira Soup",
    category: "Appetizers",
    price: 30,
    available: true,
    image: "harira.jpg",
    description: "Traditional Moroccan tomato soup with lentils",
  },
  {
    id: "8",
    name: "Lamb Tagine",
    category: "Main Courses",
    price: 110,
    available: true,
    image: "lamb-tagine.jpg",
    description: "Slow-cooked lamb with prunes and almonds",
  },
  {
    id: "9",
    name: "Orange Juice",
    category: "Beverages",
    price: 20,
    available: true,
    image: "orange-juice.jpg",
    description: "Freshly squeezed orange juice",
  },
  {
    id: "10",
    name: "Chebakia",
    category: "Desserts",
    price: 35,
    available: true,
    image: "chebakia.jpg",
    description: "Traditional honey sesame cookies",
  },
  {
    id: "11",
    name: "Zaalouk",
    category: "Salads",
    price: 28,
    available: true,
    image: "zaalouk.jpg",
    description: "Eggplant and tomato salad with spices",
  },
  {
    id: "12",
    name: "Taktouka",
    category: "Salads",
    price: 28,
    available: true,
    image: "taktouka.jpg",
    description: "Grilled pepper and tomato salad",
  },
];

// Activity Feed Data
export const mockActivities = [
  {
    id: "1",
    type: "order",
    message: "New order ORD-2024-0460 created",
    timestamp: new Date("2026-03-19T11:45:00"),
  },
  {
    id: "2",
    type: "driver",
    message: "Driver Amine Benali submitted documents",
    timestamp: new Date("2026-03-19T11:40:00"),
  },
  {
    id: "3",
    type: "order",
    message: "Order ORD-2024-0459 accepted by driver",
    timestamp: new Date("2026-03-19T11:34:00"),
  },
  {
    id: "4",
    type: "restaurant",
    message: "Nomad updated menu items",
    timestamp: new Date("2026-03-19T11:20:00"),
  },
  {
    id: "5",
    type: "order",
    message: "Order ORD-2024-0458 delivered successfully",
    timestamp: new Date("2026-03-19T10:15:00"),
  },
];