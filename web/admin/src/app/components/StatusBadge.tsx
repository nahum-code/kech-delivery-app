import { Badge } from "./ui/badge";

export type OrderStatus =
  | "Draft"
  | "PaymentPending"
  | "PaymentFailed"
  | "PaymentConfirmed"
  | "SearchingDriver"
  | "Assigned"
  | "Accepted"
  | "PickedUp"
  | "Delivered"
  | "Completed"
  | "Cancelled";

export type DriverStatus =
  | "Registered"
  | "DocsSubmitted"
  | "UnderReview"
  | "Approved"
  | "Rejected"
  | "Suspended";

const orderStatusConfig: Record<
  OrderStatus,
  { label: string; className: string }
> = {
  Draft: { label: "Draft", className: "bg-gray-100 text-gray-700" },
  PaymentPending: {
    label: "Payment Pending",
    className: "bg-yellow-100 text-yellow-700",
  },
  PaymentFailed: {
    label: "Payment Failed",
    className: "bg-red-100 text-red-700",
  },
  PaymentConfirmed: {
    label: "Payment Confirmed",
    className: "bg-green-100 text-green-700",
  },
  SearchingDriver: {
    label: "Searching Driver",
    className: "bg-orange-100 text-orange-700",
  },
  Assigned: { label: "Assigned", className: "bg-blue-100 text-blue-700" },
  Accepted: { label: "Accepted", className: "bg-blue-100 text-blue-700" },
  PickedUp: { label: "Picked Up", className: "bg-purple-100 text-purple-700" },
  Delivered: { label: "Delivered", className: "bg-teal-100 text-teal-700" },
  Completed: { label: "Completed", className: "bg-green-100 text-green-700" },
  Cancelled: { label: "Cancelled", className: "bg-gray-100 text-gray-700" },
};

const driverStatusConfig: Record<
  DriverStatus,
  { label: string; className: string }
> = {
  Registered: { label: "Registered", className: "bg-gray-100 text-gray-700" },
  DocsSubmitted: {
    label: "Docs Submitted",
    className: "bg-blue-100 text-blue-700",
  },
  UnderReview: {
    label: "Under Review",
    className: "bg-yellow-100 text-yellow-700",
  },
  Approved: { label: "Approved", className: "bg-green-100 text-green-700" },
  Rejected: { label: "Rejected", className: "bg-red-100 text-red-700" },
  Suspended: { label: "Suspended", className: "bg-orange-100 text-orange-700" },
};

interface StatusBadgeProps {
  status: OrderStatus | DriverStatus;
  type: "order" | "driver";
}

export function StatusBadge({ status, type }: StatusBadgeProps) {
  const config =
    type === "order"
      ? orderStatusConfig[status as OrderStatus]
      : driverStatusConfig[status as DriverStatus];

  return (
    <Badge variant="outline" className={config.className}>
      {config.label}
    </Badge>
  );
}
