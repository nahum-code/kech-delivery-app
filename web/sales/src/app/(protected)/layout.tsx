"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { SalesShell } from "@/components/layout/sales-shell";
import { useAuthGuard } from "@/hooks/use-auth-guard";

export default function ProtectedLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const { loading, error, user, logout } = useAuthGuard();

  useEffect(() => {
    if (!loading && error) {
      router.replace("/login");
    }
  }, [error, loading, router]);

  if (loading) {
    return <div className="p-8 text-sm text-gray-600">Loading dashboard...</div>;
  }

  if (error || !user) {
    return <div className="p-8 text-sm text-red-600">Redirecting to login...</div>;
  }

  return (
    <SalesShell
      userLabel={user.phone}
      onLogout={async () => {
        await logout();
        router.replace("/login");
      }}
    >
      {children}
    </SalesShell>
  );
}
