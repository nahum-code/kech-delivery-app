import { Card } from "../../components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../../components/ui/table";
import { EmptyState } from "../../components/EmptyState";
import { Car } from "lucide-react";
import { AdminUserStatusBadge } from "../../components/AdminUserStatusBadge";
import { adminUserDisplayName, filterAdminUsers } from "@/lib/admin-user-utils";
import type { AdminUser } from "@/services/users";

interface UsersDriversProps {
  searchQuery: string;
  users?: AdminUser[];
}

export function UsersDrivers({ searchQuery, users = [] }: UsersDriversProps) {
  const filteredUsers = filterAdminUsers(users, searchQuery);

  if (filteredUsers.length === 0) {
    return (
      <EmptyState
        icon={Car}
        title="No drivers found"
        description={
          searchQuery
            ? "No drivers match your search criteria."
            : "No drivers have been registered yet."
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
              <TableHead>Name</TableHead>
              <TableHead>Phone Number</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Created At</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.map((user) => (
              <TableRow key={user.user_id}>
                <TableCell className="font-medium">{user.user_id}</TableCell>
                <TableCell className="font-medium text-gray-900">
                  {adminUserDisplayName(user)}
                </TableCell>
                <TableCell>{user.phone}</TableCell>
                <TableCell>
                  <AdminUserStatusBadge status={user.status} />
                </TableCell>
                <TableCell>
                  {new Date(user.created_at).toLocaleDateString("en-GB", {
                    day: "2-digit",
                    month: "short",
                    year: "numeric",
                  })}
                </TableCell>
                <TableCell className="text-right text-sm text-gray-500">--</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
