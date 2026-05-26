import { useMemo, useState } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Search, UserPlus, Filter } from "lucide-react";
import { UsersAll } from "./users/UsersAll";
import { UsersCustomers } from "./users/UsersCustomers";
import { UsersDrivers } from "./users/UsersDrivers";
import { UsersSalesAgents } from "./users/UsersSalesAgents";
import { CreateSalesAgentDialog } from "@/features/admin/components/CreateSalesAgentDialog";
import { useAdminUsers } from "@/hooks/use-admin-users";

export function Users() {
  const [searchQuery, setSearchQuery] = useState("");
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const { users, setUsers, loading } = useAdminUsers();

  const customerUsers = useMemo(
    () => users.filter((user) => user.role === "customer"),
    [users],
  );
  const driverUsers = useMemo(
    () => users.filter((user) => user.role === "driver"),
    [users],
  );
  const salesUsers = useMemo(
    () => users.filter((user) => user.role === "sales"),
    [users],
  );

  const handleCreated = (created: { user_id: number; phone: string; role: string }) => {
    setUsers((prev) => [
      {
        user_id: created.user_id,
        phone: created.phone,
        name: null,
        role: created.role,
        status: "active",
        created_at: new Date().toISOString(),
      },
      ...prev,
    ]);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-gray-900">Users</h1>
          <p className="text-gray-600 mt-1">
            Manage customers, drivers, and sales agents
          </p>
        </div>
        <Button
          onClick={() => setCreateDialogOpen(true)}
          className="bg-[#800020] hover:bg-[#600018]"
        >
          <UserPlus className="w-4 h-4 mr-2" />
          Create Sales Agent
        </Button>
      </div>

      {/* Search and Filters */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <Input
            placeholder="Search by name or phone..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
        <Button variant="outline">
          <Filter className="w-4 h-4 mr-2" />
          Filters
        </Button>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="all" className="space-y-6">
        <TabsList>
          <TabsTrigger value="all">All Users</TabsTrigger>
          <TabsTrigger value="customers">Customers</TabsTrigger>
          <TabsTrigger value="drivers">Drivers</TabsTrigger>
          <TabsTrigger value="sales">Sales Agents</TabsTrigger>
        </TabsList>

        <TabsContent value="all">
          {loading ? <p className="text-sm text-gray-600">Loading users...</p> : <UsersAll searchQuery={searchQuery} users={users} />}
        </TabsContent>

        <TabsContent value="customers">
          {loading ? <p className="text-sm text-gray-600">Loading users...</p> : <UsersCustomers searchQuery={searchQuery} users={customerUsers} />}
        </TabsContent>

        <TabsContent value="drivers">
          {loading ? <p className="text-sm text-gray-600">Loading users...</p> : <UsersDrivers searchQuery={searchQuery} users={driverUsers} />}
        </TabsContent>

        <TabsContent value="sales">
          {loading ? <p className="text-sm text-gray-600">Loading users...</p> : <UsersSalesAgents searchQuery={searchQuery} users={salesUsers} />}
        </TabsContent>
      </Tabs>

      <CreateSalesAgentDialog
        open={createDialogOpen}
        onOpenChange={setCreateDialogOpen}
        onCreated={handleCreated}
        existingPhones={users.map((user) => user.phone)}
      />
    </div>
  );
}
