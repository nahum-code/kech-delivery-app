"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { Menu, X } from "lucide-react";

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
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const nav = (
    <>
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
              onClick={() => setSidebarOpen(false)}
              className={`block rounded-md px-3 py-2 text-sm ${isActive ? "bg-[#7D1F3E] text-white" : "text-gray-700 hover:bg-gray-100"}`}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>
      <button
        type="button"
        onClick={() => { void onLogout(); setSidebarOpen(false); }}
        className="mt-6 w-full rounded-md border border-gray-300 px-3 py-2 text-sm"
      >
        Logout
      </button>
    </>
  );

  return (
    <div className="flex min-h-screen bg-gray-50">
      {/* Desktop sidebar */}
      <aside className="hidden w-64 shrink-0 border-r border-gray-200 bg-white p-4 lg:block">
        {nav}
      </aside>

      {/* Mobile overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Mobile sidebar drawer */}
      <aside
        className={`fixed inset-y-0 left-0 z-50 w-64 transform border-r border-gray-200 bg-white p-4 transition-transform duration-200 lg:hidden ${sidebarOpen ? "translate-x-0" : "-translate-x-full"}`}
      >
        <button
          type="button"
          onClick={() => setSidebarOpen(false)}
          className="mb-4 rounded-md p-1 text-gray-500 hover:bg-gray-100"
          aria-label="Close menu"
        >
          <X className="h-5 w-5" />
        </button>
        {nav}
      </aside>

      {/* Main content */}
      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Mobile header */}
        <header className="flex items-center border-b border-gray-200 bg-white px-4 py-3 lg:hidden">
          <button
            type="button"
            onClick={() => setSidebarOpen(true)}
            className="rounded-md p-1 text-gray-600 hover:bg-gray-100"
            aria-label="Open menu"
          >
            <Menu className="h-6 w-6" />
          </button>
          <h1 className="ml-3 text-lg font-semibold text-[#7D1F3E]">Kech Sales</h1>
        </header>
        <main className="flex-1 overflow-auto p-4 sm:p-6">{children}</main>
      </div>
    </div>
  );
}
