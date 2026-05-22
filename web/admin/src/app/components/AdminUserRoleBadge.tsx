import { Badge } from "./ui/badge";
import { adminUserRoleBadgeClass, adminUserRoleLabel } from "@/lib/admin-user-utils";

interface AdminUserRoleBadgeProps {
  role: string;
}

export function AdminUserRoleBadge({ role }: AdminUserRoleBadgeProps) {
  return (
    <Badge variant="outline" className={adminUserRoleBadgeClass(role)}>
      {adminUserRoleLabel(role)}
    </Badge>
  );
}
