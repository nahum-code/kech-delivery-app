"use client";

import { useState } from "react";
import { Search } from "lucide-react";
import { Input } from "@/app/components/ui/input";
import { UsersCustomers } from "@/app/pages/users/UsersCustomers";
import { useAdminUsers } from "@/hooks/use-admin-users";

export const dynamic = "force-dynamic";

export default function CustomersRoute() {
  const [searchQuery, setSearchQuery] = useState("");
  const { users, loading } = useAdminUsers("customer");

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-gray-900">Customers</h1>
        <p className="mt-1 text-gray-600">Manage customer accounts and account status.</p>
      </div>
      <div className="relative max-w-xl">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
        <Input
          placeholder="Search customers by phone number..."
          value={searchQuery}
          onChange={(event) => setSearchQuery(event.target.value)}
          className="pl-10"
        />
      </div>
      {loading ? (
        <p className="text-sm text-gray-600">Loading users...</p>
      ) : (
        <UsersCustomers searchQuery={searchQuery} users={users} />
      )}
    </div>
  );
}
