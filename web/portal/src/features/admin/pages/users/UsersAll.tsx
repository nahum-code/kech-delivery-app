import { Card } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { EmptyState } from "@/components/shared/EmptyState";
import { Users } from "lucide-react";
import { AdminUserRoleBadge } from "@/features/admin/components/AdminUserRoleBadge";
import { AdminUserStatusBadge } from "@/features/admin/components/AdminUserStatusBadge";
import { adminUserDisplayName, filterAdminUsers } from "@/lib/admin-user-utils";
import type { AdminUser } from "@/services/users";

interface UsersAllProps {
  searchQuery: string;
  users?: AdminUser[];
}

export function UsersAll({ searchQuery, users = [] }: UsersAllProps) {
  const filteredUsers = filterAdminUsers(users, searchQuery);

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
              <TableHead>Name</TableHead>
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
                <TableCell className="font-medium text-gray-900">
                  {adminUserDisplayName(user)}
                </TableCell>
                <TableCell>{user.phone}</TableCell>
                <TableCell>
                  <AdminUserRoleBadge role={user.role} />
                </TableCell>
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
