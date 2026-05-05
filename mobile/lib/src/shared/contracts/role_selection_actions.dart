import 'package:flutter/foundation.dart';

typedef RoleSelectionHandler = void Function();

/// Cross-cutting actions for the role selection surface (wired per app flavor).
@immutable
class RoleSelectionActions {
  const RoleSelectionActions({
    required this.onContinueAsCustomer,
    required this.onContinueAsDriver,
    required this.onTermsOfService,
    this.onLanguage,
    this.onAccount,
    this.onTrust,
  });

  final RoleSelectionHandler onContinueAsCustomer;
  final RoleSelectionHandler onContinueAsDriver;
  final RoleSelectionHandler onTermsOfService;
  final RoleSelectionHandler? onLanguage;
  final RoleSelectionHandler? onAccount;
  final RoleSelectionHandler? onTrust;
}
