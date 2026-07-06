import { useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { EmptyState } from "@/components/shared/EmptyState";
import { Briefcase, Pencil } from "lucide-react";
import { AdminUserStatusBadge } from "@/features/admin/components/AdminUserStatusBadge";
import { EditSalesAgentDialog } from "@/features/admin/components/EditSalesAgentDialog";
import { adminUserDisplayName, filterAdminUsers } from "@/lib/admin-user-utils";
import type { AdminUser } from "@/services/users";

interface UsersSalesAgentsProps {
  searchQuery: string;
  users?: AdminUser[];
  onUserUpdated?: (updated: AdminUser) => void;
  /** Show the per-row Edit action. Off within /admin/users. */
  showActions?: boolean;
}

export function UsersSalesAgents({
  searchQuery,
  users = [],
  onUserUpdated,
  showActions = true,
}: UsersSalesAgentsProps) {
  const [editing, setEditing] = useState<AdminUser | null>(null);
  const [editOpen, setEditOpen] = useState(false);
  const filteredUsers = filterAdminUsers(users, searchQuery);

  if (filteredUsers.length === 0) {
    return (
      <EmptyState
        icon={Briefcase}
        title="No sales agents found"
        description={
          searchQuery
            ? "No sales agents match your search criteria."
            : "No sales agents have been created yet."
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
              {showActions && (
                <TableHead className="text-right">Actions</TableHead>
              )}
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
                {showActions && (
                  <TableCell className="text-right">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => {
                        setEditing(user);
                        setEditOpen(true);
                      }}
                    >
                      <Pencil className="mr-1 h-4 w-4" />
                      Edit
                    </Button>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
      <EditSalesAgentDialog
        open={editOpen}
        onOpenChange={setEditOpen}
        agent={editing}
        onUpdated={onUserUpdated}
      />
    </Card>
  );
}
