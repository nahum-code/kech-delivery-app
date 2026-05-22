import { Badge } from "./ui/badge";
import { adminUserStatusBadgeClass, adminUserStatusLabel } from "@/lib/admin-user-utils";

interface AdminUserStatusBadgeProps {
  status: string;
}

export function AdminUserStatusBadge({ status }: AdminUserStatusBadgeProps) {
  return (
    <Badge variant="outline" className={adminUserStatusBadgeClass(status)}>
      {adminUserStatusLabel(status)}
    </Badge>
  );
}
