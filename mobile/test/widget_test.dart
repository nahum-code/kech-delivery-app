// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kech_delivery_mobile/src/app/role_selection_bootstrap.dart';
import 'package:kech_delivery_mobile/src/features/auth/data/auth_repository.dart';
import 'package:kech_delivery_mobile/src/features/customer/auth/login/presentation/screens/customer_login_screen.dart';
import 'package:kech_delivery_mobile/src/features/customer/onboarding/presentation/screens/customer_onboarding_screen.dart';
import 'package:kech_delivery_mobile/src/features/customer/registration/presentation/screens/customer_registration_screen.dart';
import 'package:kech_delivery_mobile/src/features/customer/add_address/presentation/screens/customer_add_address_screen.dart';
import 'package:kech_delivery_mobile/src/features/customer/home/presentation/screens/customer_home_screen.dart';
import 'package:kech_delivery_mobile/src/features/customer/location_access/presentation/screens/customer_location_access_screen.dart';
import 'package:kech_delivery_mobile/src/features/customer/splash/presentation/screens/customer_splash_screen.dart';

import 'support/test_auth_repository.dart';

void main() {
  testWidgets('Role selection renders and opens customer flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RoleSelectionBootstrap()));
    await tester.pumpAndSettle();

    expect(find.text('Continue as customer'), findsOneWidget);
    expect(find.text('Continue as driver'), findsOneWidget);
    expect(find.textContaining('KECH'), findsWidgets);

    await tester.tap(find.text('Continue as customer'));
    await tester.pumpAndSettle();

    expect(find.text('CUSTOMER - SPLASH SCREEN'), findsOneWidget);
  });

  testWidgets('Role selection opens driver flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RoleSelectionBootstrap()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue as driver'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Customer login shows server error when password is wrong', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthRepository>.value(
        value: createTestAuthRepository(),
        child: const MaterialApp(home: CustomerLoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '+10000000001');
    await tester.enterText(find.byType(TextFormField).last, 'wrongwrong');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Incorrect password'), findsOneWidget);
  });

  testWidgets('Customer login Sign up opens registration', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthRepository>.value(
        value: createTestAuthRepository(),
        child: const MaterialApp(home: CustomerLoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('FULL NAME'), findsOneWidget);
  });

  testWidgets('Customer registration requires terms before submit', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthRepository>.value(
        value: createTestAuthRepository(),
        child: const MaterialApp(home: CustomerRegistrationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Yassine El Amrani');
    await tester.enterText(find.byType(TextFormField).at(1), '+212600000000');
    await tester.enterText(find.byType(TextFormField).at(2), 'ComplexPass1!');
    await tester.enterText(find.byType(TextFormField).at(3), 'ComplexPass1!');
    await tester.tap(find.text('REGISTER'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Please accept the Terms'), findsOneWidget);
  });

  testWidgets('Customer login succeeds and opens home placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthRepository>.value(
        value: createTestAuthRepository(),
        child: const MaterialApp(home: CustomerLoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '+10000000001');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Find your perfect spot.'), findsOneWidget);
    expect(find.text('Allow location'), findsOneWidget);
  });

  testWidgets('Customer splash renders key copy', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerSplashScreen(navigateToOnboardingAfter: null),
      ),
    );

    expect(find.text('CUSTOMER - SPLASH SCREEN'), findsOneWidget);
    expect(find.textContaining('Kech'), findsWidgets);
    expect(find.text('SYSTEM CHECK'), findsOneWidget);
    expect(find.text('On-time reliability: 99.8%'), findsOneWidget);
  });

  testWidgets('Customer home screen renders header, search, and top rated', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthRepository>.value(
        value: createTestAuthRepository(),
        child: const MaterialApp(home: CustomerHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CUSTOMER - HOME'), findsOneWidget);
    expect(find.text('Deliver to'), findsOneWidget);
    expect(find.text('Where should we deliver?'), findsNothing);
    expect(find.text('Top rated'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Customer add address screen renders form and save action', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CustomerAddAddressScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Customer – Add Address'), findsOneWidget);
    expect(find.text('Add address'), findsOneWidget);
    expect(find.text('Where should we deliver?'), findsOneWidget);
    expect(find.text('Save address'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Save address'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter a street address'), findsOneWidget);
  });

  testWidgets('Customer location access screen renders hero and actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CustomerLocationAccessScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Find your perfect spot.'), findsOneWidget);
    expect(find.text('Allow location'), findsOneWidget);
    expect(find.text('Select manually'), findsOneWidget);
    expect(find.textContaining('privacy is our priority'), findsOneWidget);
  });

  testWidgets('Customer onboarding slide 1 renders key copy', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CustomerOnboardingScreen()),
    );

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next step'), findsOneWidget);
    expect(find.textContaining('promise'), findsOneWidget);
    expect(find.text('Average delivery'), findsOneWidget);
    expect(find.text('24 Minutes or less'), findsOneWidget);
  });
}
