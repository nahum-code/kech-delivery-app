import { requestJson } from "@/services/http";

export type PendingDriver = {
  user_id: number;
  full_name: string;
  phone: string;
  approval_status: string;
  created_at: string;
};

export type ApprovedDriver = {
  id: number;
  full_name: string;
  phone: string;
  vehicle_type: string;
  operational_status: string;
};

export type DriverActionResponse = {
  message: string;
  driver_id: number;
  approval_status: string;
};

export async function fetchPendingDrivers(): Promise<PendingDriver[]> {
  return requestJson<PendingDriver[]>("/api/v1/admin/drivers/pending/");
}

export async function fetchApprovedDriversAdmin(): Promise<ApprovedDriver[]> {
  return requestJson<ApprovedDriver[]>("/api/v1/admin/drivers/approved/?all=true");
}

export async function approveDriver(userId: number): Promise<DriverActionResponse> {
  return requestJson<DriverActionResponse>(`/api/v1/admin/drivers/${userId}/approve/`, {
    method: "POST",
  });
}

export async function rejectDriver(
  userId: number,
  rejectionReason: string,
): Promise<DriverActionResponse> {
  return requestJson<DriverActionResponse>(`/api/v1/admin/drivers/${userId}/reject/`, {
    method: "POST",
    body: JSON.stringify({ rejection_reason: rejectionReason }),
  });
}

export async function suspendDriver(
  userId: number,
  suspensionReason: string,
): Promise<DriverActionResponse> {
  return requestJson<DriverActionResponse>(`/api/v1/admin/drivers/${userId}/suspend/`, {
    method: "POST",
    body: JSON.stringify({ suspension_reason: suspensionReason }),
  });
}
