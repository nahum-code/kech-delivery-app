import type { AdminUser } from "@/services/users";

/** Label for tables when a role has no profile name (e.g. sales/admin). */
export function adminUserDisplayName(user: AdminUser): string {
  const trimmed = user.name?.trim();
  return trimmed ? trimmed : "—";
}

/** Match phone or profile name (case-insensitive, partial). */
export function matchesAdminUserSearch(user: AdminUser, searchQuery: string): boolean {
  const q = searchQuery.trim().toLowerCase();
  if (!q) {
    return true;
  }
  if (user.phone.toLowerCase().includes(q)) {
    return true;
  }
  const name = user.name?.trim().toLowerCase();
  return Boolean(name && name.includes(q));
}

export function filterAdminUsers(users: AdminUser[], searchQuery: string): AdminUser[] {
  return users.filter((user) => matchesAdminUserSearch(user, searchQuery));
}

export type AdminUserStatusKey = "active" | "inactive" | "suspended";

/** Normalize API/UI status strings for consistent badge styling. */
export function normalizeAdminUserStatus(status: string): AdminUserStatusKey | "unknown" {
  const key = status.trim().toLowerCase();
  if (key === "active") {
    return "active";
  }
  if (key === "inactive") {
    return "inactive";
  }
  if (key === "suspended") {
    return "suspended";
  }
  return "unknown";
}

export function adminUserStatusLabel(status: string): string {
  const key = normalizeAdminUserStatus(status);
  switch (key) {
    case "active":
      return "Active";
    case "inactive":
      return "Inactive";
    case "suspended":
      return "Suspended";
    default:
      return status.trim() || "Unknown";
  }
}

/**
 * Account status badges — unique hues, spaced for color-blind users (hue + contrast).
 * Not shared with role colors below.
 */
export function adminUserStatusBadgeClass(status: string): string {
  switch (normalizeAdminUserStatus(status)) {
    case "active":
      return "bg-emerald-100 text-emerald-950 border-emerald-400 font-medium";
    case "inactive":
      return "bg-zinc-200 text-zinc-800 border-zinc-400 font-medium";
    case "suspended":
      return "bg-fuchsia-100 text-fuchsia-950 border-fuchsia-400 font-medium";
    default:
      return "bg-yellow-100 text-yellow-950 border-yellow-500 font-medium";
  }
}

export type AdminUserRoleKey = "customer" | "driver" | "sales" | "admin";

export function normalizeAdminUserRole(role: string): AdminUserRoleKey | "unknown" {
  const key = role.trim().toLowerCase();
  if (key === "customer" || key === "driver" || key === "sales" || key === "admin") {
    return key;
  }
  return "unknown";
}

export function adminUserRoleLabel(role: string): string {
  switch (normalizeAdminUserRole(role)) {
    case "customer":
      return "Customer";
    case "driver":
      return "Driver";
    case "sales":
      return "Sales Agent";
    case "admin":
      return "Admin";
    default:
      return role.trim() || "Unknown";
  }
}

/**
 * Role badges — warm/cool alternation, far apart on the color wheel (CB-friendly).
 * Customer = blue, Driver = orange, Sales = cyan, Admin = maroon (filled).
 */
export function adminUserRoleBadgeClass(role: string): string {
  switch (normalizeAdminUserRole(role)) {
    case "customer":
      return "bg-blue-100 text-blue-950 border-blue-400 font-medium";
    case "driver":
      return "bg-orange-100 text-orange-950 border-orange-400 font-medium";
    case "sales":
      return "bg-cyan-100 text-cyan-950 border-cyan-400 font-medium";
    case "admin":
      return "bg-[#800020] text-white border-[#600018] font-medium";
    default:
      return "bg-stone-200 text-stone-800 border-stone-400 font-medium";
  }
}
