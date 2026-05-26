import { requestJson } from "@/services/http";

export type PendingDriver = {
  user_id: number;
  full_name: string;
  phone: string;
  approval_status: string;
  created_at: string;
  documents_submitted: boolean;
  uploaded_document_count: number;
};

export type DriverDocumentRecord = {
  document_type: string;
  document_type_label: string;
  file_url: string | null;
  uploaded_at: string;
  is_pdf: boolean;
};

export type DriverDocumentsResponse = {
  user_id: number;
  full_name: string;
  phone: string;
  documents_submitted: boolean;
  documents: DriverDocumentRecord[];
};

export type ApprovedDriver = {
  id: number;
  full_name: string;
  phone: string;
  vehicle_type: string;
  operational_status: string;
  payout_percentage: string;
};

export type SuspendedDriver = {
  user_id: number;
  full_name: string;
  phone: string;
  vehicle_type: string;
  suspended_at: string | null;
  suspension_reason: string;
};

export type DriverActionResponse = {
  message: string;
  driver_id: number;
  approval_status: string;
};

export async function fetchPendingDrivers(): Promise<PendingDriver[]> {
  return requestJson<PendingDriver[]>("/api/v1/admin/drivers/pending/");
}

export async function fetchDriverDocuments(userId: number): Promise<DriverDocumentsResponse> {
  return requestJson<DriverDocumentsResponse>(`/api/v1/admin/drivers/${userId}/documents/`);
}

export async function fetchApprovedDriversAdmin(): Promise<ApprovedDriver[]> {
  return requestJson<ApprovedDriver[]>("/api/v1/admin/drivers/approved/?all=true");
}

export async function fetchSuspendedDrivers(): Promise<SuspendedDriver[]> {
  return requestJson<SuspendedDriver[]>("/api/v1/admin/drivers/suspended/");
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

export async function reactivateDriver(userId: number): Promise<DriverActionResponse> {
  return requestJson<DriverActionResponse>(`/api/v1/admin/drivers/${userId}/reactivate/`, {
    method: "POST",
  });
}

export async function updateDriverPayoutPercentage(
  userId: number,
  payoutPercentage: number,
): Promise<{ driver_id: number; payout_percentage: string; message: string }> {
  return requestJson(`/api/v1/admin/drivers/${userId}/payout-percentage/`, {
    method: "PATCH",
    body: JSON.stringify({ payout_percentage: payoutPercentage }),
  });
}
