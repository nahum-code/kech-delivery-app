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
import { Briefcase } from "lucide-react";
import type { AdminUser } from "@/services/users";

interface UsersSalesAgentsProps {
  searchQuery: string;
  users?: AdminUser[];
}

const getStatusBadgeColor = (status: string) => {
  return status === "Active"
    ? "bg-green-100 text-green-700"
    : "bg-gray-100 text-gray-700";
};

export function UsersSalesAgents({ searchQuery, users = [] }: UsersSalesAgentsProps) {
  const filteredUsers = users.filter((user) =>
    user.phone.toLowerCase().includes(searchQuery.toLowerCase())
  );

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
                <TableCell>{user.phone}</TableCell>
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
                <TableCell className="text-right text-sm text-gray-500">--</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
