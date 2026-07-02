/// Driver registration details collected on the detail-info screen and held in
/// memory until the driver uploads documents and taps "Create account" — the
/// account is only registered at that final step, not on "Continue".
final class DriverRegistrationDraft {
  const DriverRegistrationDraft({
    required this.fullName,
    required this.email,
    required this.phoneRaw,
    required this.password,
    required this.confirmPassword,
    required this.vehicleType,
  });

  final String fullName;
  final String email;
  final String phoneRaw;
  final String password;
  final String confirmPassword;
  final String vehicleType;
}
