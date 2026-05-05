import 'package:flutter/material.dart';

import '../presentation/screens/customer_registration_screen.dart';

abstract final class CustomerRegistrationNavigation {
  static Future<void> openFromLogin(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerRegistrationScreen(),
      ),
    );
  }
}
