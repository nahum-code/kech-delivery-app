import { Card, CardContent } from "@/components/ui/card";
import { LucideIcon } from "lucide-react";

interface KpiCardProps {
  title: string;
  value: string | number;
  change?: string;
  changeType?: "increase" | "decrease" | "neutral";
  icon?: LucideIcon;
}

export function KpiCard({
  title,
  value,
  change,
  changeType = "neutral",
  icon: Icon,
}: KpiCardProps) {
  return (
    <Card>
      <CardContent className="p-6">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <p className="text-sm text-gray-600">{title}</p>
            <p className="text-3xl font-semibold mt-2">{value}</p>
            {change && (
              <p
                className={`text-sm mt-2 ${
                  changeType === "increase"
                    ? "text-green-600"
                    : changeType === "decrease"
                    ? "text-red-600"
                    : "text-gray-600"
                }`}
              >
                {change}
              </p>
            )}
          </div>
          {Icon && (
            <div className="w-12 h-12 rounded-lg bg-[#800020]/10 flex items-center justify-center">
              <Icon className="w-6 h-6 text-[#800020]" />
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
