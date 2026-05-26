"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { AdminShell } from "@/components/layout/admin-shell";
import { useAuthGuard } from "@/hooks/use-auth-guard";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const { loading, error, user, logout } = useAuthGuard("admin");

  useEffect(() => {
    if (!loading && (error || !user)) {
      router.replace("/login");
    }
  }, [error, loading, router, user]);

  if (!loading && (error || !user)) {
    return null;
  }

  if (loading) {
    return <div className="p-8 text-sm text-gray-600">Loading...</div>;
  }

  return (
    <AdminShell
      userLabel={user!.phone}
      onLogout={async () => {
        await logout();
        router.replace("/login");
      }}
    >
      {children}
    </AdminShell>
  );
}
