"use client";

import { useState } from "react";
import { Search, UserPlus } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { UsersSalesAgents } from "@/features/admin/pages/users/UsersSalesAgents";
import { CreateSalesAgentDialog } from "@/features/admin/components/CreateSalesAgentDialog";
import { useAdminUsers } from "@/hooks/use-admin-users";
import type { AdminUser } from "@/services/users";

export const dynamic = "force-dynamic";

export default function SalesAgentsRoute() {
  const [searchQuery, setSearchQuery] = useState("");
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const { users, setUsers, loading } = useAdminUsers("sales");

  const handleCreated = (created: {
    user_id: number;
    phone: string;
    name: string;
    role: string;
  }) => {
    setUsers((prev) => [
      {
        user_id: created.user_id,
        phone: created.phone,
        name: created.name || null,
        role: created.role,
        status: "active",
        created_at: new Date().toISOString(),
      },
      ...prev,
    ]);
  };

  const handleUpdated = (updated: AdminUser) => {
    setUsers((prev) =>
      prev.map((user) => (user.user_id === updated.user_id ? updated : user)),
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-semibold text-gray-900">Sales Agents</h1>
          <p className="mt-1 text-gray-600">Create and manage sales agent accounts.</p>
        </div>
        <Button onClick={() => setCreateDialogOpen(true)} className="bg-[#800020] hover:bg-[#600018]">
          <UserPlus className="mr-2 h-4 w-4" />
          Create Sales Agent
        </Button>
      </div>

      <div className="relative max-w-xl">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
        <Input
          placeholder="Search sales agents by name or phone..."
          value={searchQuery}
          onChange={(event) => setSearchQuery(event.target.value)}
          className="pl-10"
        />
      </div>

      {loading ? (
        <p className="text-sm text-gray-600">Loading users...</p>
      ) : (
        <UsersSalesAgents
          searchQuery={searchQuery}
          users={users}
          onUserUpdated={handleUpdated}
        />
      )}
      <CreateSalesAgentDialog
        open={createDialogOpen}
        onOpenChange={setCreateDialogOpen}
        onCreated={handleCreated}
        existingPhones={users.map((user) => user.phone)}
      />
    </div>
  );
}
