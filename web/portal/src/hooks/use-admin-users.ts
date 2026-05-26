"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { fetchAdminUsers, type AdminUser } from "@/services/users";

export function useAdminUsers(role?: string) {
  const router = useRouter();
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);

  const loadUsers = useCallback(async () => {
    try {
      const data = await fetchAdminUsers();
      setUsers(role ? data.filter((user) => user.role === role) : data);
    } catch (error) {
      const message = error instanceof Error ? error.message : "Something went wrong. Please try again.";
      if (message === "Session expired") {
        router.replace("/login");
        return;
      }
      toast.error(message);
    } finally {
      setLoading(false);
    }
  }, [role, router]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void loadUsers();
  }, [loadUsers]);

  return { users, setUsers, loading, reload: loadUsers };
}
