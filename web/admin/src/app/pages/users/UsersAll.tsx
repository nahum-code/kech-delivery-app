import { Card } from "../../components/ui/card";
import { Badge } from "../../components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../../components/ui/table";
import { EmptyState } from "../../components/EmptyState";
import { Users } from "lucide-react";
import type { AdminUser } from "@/services/users";

interface UsersAllProps {
  searchQuery: string;
  users?: AdminUser[];
}

const getRoleBadgeColor = (role: string) => {
  switch (role) {
    case "customer":
      return "bg-blue-100 text-blue-700";
    case "driver":
      return "bg-purple-100 text-purple-700";
    case "sales":
      return "bg-green-100 text-green-700";
    case "admin":
      return "bg-[#800020] text-white";
    default:
      return "bg-gray-100 text-gray-700";
  }
};

const getRoleLabel = (role: string) => {
  switch (role) {
    case "customer":
      return "Customer";
    case "driver":
      return "Driver";
    case "sales":
      return "Sales Agent";
    case "admin":
      return "Admin";
    default:
      return role;
  }
};

const getStatusBadgeColor = (status: string) => {
  return status === "active"
    ? "bg-green-100 text-green-700"
    : "bg-gray-100 text-gray-700";
};

export function UsersAll({ searchQuery, users = [] }: UsersAllProps) {
  const filteredUsers = users.filter((user) =>
    user.phone.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (filteredUsers.length === 0) {
    return (
      <EmptyState
        icon={Users}
        title="No users found"
        description={
          searchQuery
            ? "No users match your search criteria. Try a different search term."
            : "No users have been registered yet."
        }
      />
    );
  }

  return (
    <Card>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>User ID</TableHead>
              <TableHead>Phone Number</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Created At</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.map((user) => (
              <TableRow key={user.user_id}>
                <TableCell className="font-medium">{user.user_id}</TableCell>
                <TableCell>{user.phone}</TableCell>
                <TableCell>
                  <Badge
                    variant="outline"
                    className={getRoleBadgeColor(user.role)}
                  >
                    {getRoleLabel(user.role)}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge
                    variant="outline"
                    className={getStatusBadgeColor(user.status)}
                  >
                    {user.status === "active" ? "Active" : "Inactive"}
                  </Badge>
                </TableCell>
                <TableCell>
                  {new Date(user.created_at).toLocaleDateString("en-GB", {
                    day: "2-digit",
                    month: "short",
                    year: "numeric",
                  })}
                </TableCell>
                <TableCell className="text-right text-sm text-gray-500">
                  --
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
