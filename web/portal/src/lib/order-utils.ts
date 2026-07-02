export const ORDER_STATUS_OPTIONS = [
  "all",
  "pending",
  "awaiting_confirmation",
  "confirmed",
  "preparing",
  "ready_for_pickup",
  "assigned",
  "picked_up",
  "delivering",
  "delivered",
  "cancelled",
  "declined",
] as const;

export function statusLabel(status: string): string {
  return status.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

export function paymentLabel(status: string): string {
  return status.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

export function paymentBadgeClass(status: string): string {
  switch (status) {
    case "paid":
      return "bg-green-100 text-green-800 border-green-200";
    case "failed":
      return "bg-red-100 text-red-800 border-red-200";
    case "pending":
    default:
      return "bg-amber-100 text-amber-800 border-amber-200";
  }
}

export function statusBadgeClass(status: string): string {
  switch (status) {
    case "delivered":
      return "bg-green-100 text-green-800 border-green-200";
    case "cancelled":
      return "bg-red-100 text-red-800 border-red-200";
    case "declined":
      return "bg-orange-100 text-orange-900 border-orange-200";
    case "pending":
      return "bg-gray-100 text-gray-800 border-gray-200";
    case "awaiting_confirmation":
      return "bg-purple-100 text-purple-800 border-purple-200";
    case "assigned":
    case "picked_up":
    case "delivering":
      return "bg-blue-100 text-blue-800 border-blue-200";
    default:
      return "bg-amber-100 text-amber-800 border-amber-200";
  }
}

export function parseApiError(err: unknown, fallback: string): string {
  if (!(err instanceof Error)) return fallback;
  const raw = err.message;
  try {
    const data = JSON.parse(raw) as { detail?: string };
    if (typeof data.detail === "string") return data.detail;
  } catch {
    /* plain text */
  }
  return raw || fallback;
}
