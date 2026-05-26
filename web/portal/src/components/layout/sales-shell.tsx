"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

type SalesShellProps = {
  userLabel: string;
  onLogout: () => Promise<void>;
  children: React.ReactNode;
};

const menu = [
  { href: "/sales/create-order", label: "Create Order" },
  { href: "/sales/catalog", label: "Restaurants & Menus" },
  { href: "/sales/assign-driver", label: "Assign Driver" },
  { href: "/sales/monitor-orders", label: "Monitor Orders" },
];

export function SalesShell({ userLabel, onLogout, children }: SalesShellProps) {
  const pathname = usePathname();

  return (
    <div className="flex min-h-screen bg-gray-50">
      <aside className="w-64 border-r border-gray-200 bg-white p-4">
        <div className="mb-6 px-2">
          <h1 className="text-xl font-semibold text-[#7D1F3E]">Kech Sales</h1>
          <p className="text-xs text-gray-500">{userLabel}</p>
        </div>
        <nav className="space-y-1">
          {menu.map((item) => {
            const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`block rounded-md px-3 py-2 text-sm ${isActive ? "bg-[#7D1F3E] text-white" : "text-gray-700 hover:bg-gray-100"}`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
        <button
          type="button"
          onClick={() => void onLogout()}
          className="mt-6 w-full rounded-md border border-gray-300 px-3 py-2 text-sm"
        >
          Logout
        </button>
      </aside>
      <main className="flex-1 overflow-auto p-6">{children}</main>
    </div>
  );
}
