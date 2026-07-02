import 'package:flutter/material.dart';

import '../presentation/screens/driver_registration_screen.dart';
import '../domain/driver_registration_draft.dart';
import '../../documents/presentation/screens/driver_documents_screen.dart';

abstract final class DriverRegistrationNavigation {
  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DriverRegistrationScreen()),
    );
  }

  static void openDocuments(BuildContext context, {required DriverRegistrationDraft draft}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DriverDocumentsScreen(draft: draft)),
    );
  }
}
