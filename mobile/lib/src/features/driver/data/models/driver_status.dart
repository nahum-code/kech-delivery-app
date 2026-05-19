/// Approval status from driver onboarding/status or me/status APIs.
final class DriverStatus {
  const DriverStatus({
    required this.approvalStatus,
    this.reviewedAt,
    this.rejectionReason,
    this.suspensionReason,
    this.phoneVerified = false,
    this.documentsSubmitted = false,
  });

  final String approvalStatus;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? suspensionReason;
  final bool phoneVerified;
  final bool documentsSubmitted;

  bool get isPending => approvalStatus == 'pending';
  bool get isApproved => approvalStatus == 'approved';
  bool get isRejected => approvalStatus == 'rejected';
  bool get isSuspended => approvalStatus == 'suspended';

  factory DriverStatus.fromJson(Map<String, dynamic> json) {
    return DriverStatus(
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      suspensionReason: json['suspension_reason'] as String?,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      documentsSubmitted: json['documents_submitted'] as bool? ?? false,
    );
  }
}
