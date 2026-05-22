import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'src/app/bootstrap.dart';
import 'src/app/kech_delivery_app.dart';
import 'src/core/config/api_base_url.dart';
import 'src/features/auth/data/auth_repository.dart';
import 'src/features/customer/cart/data/cart_repository.dart';
import 'src/features/customer/orders/data/order_api.dart';
import 'src/features/customer/orders/data/order_repository.dart';
import 'src/features/customer/payments/data/payment_api.dart';
import 'src/features/customer/payments/data/payment_repository.dart';
import 'src/features/customer/restaurants/data/restaurant_api.dart';
import 'src/features/customer/restaurants/data/restaurant_repository.dart';
import 'src/features/driver/data/driver_onboarding_api.dart';
import 'src/features/driver/data/driver_onboarding_repository.dart';
import 'src/features/driver/orders/data/driver_order_api.dart';
import 'src/features/driver/orders/data/driver_order_repository.dart';

Future<void> main() async {
  await bootstrap(() async {
    final String baseUrl = ApiBaseUrl.resolve();
    final AuthRepository authRepository = AuthRepository(baseUrl: baseUrl);
    final DriverOnboardingRepository driverOnboarding = DriverOnboardingRepository(
      api: DriverOnboardingApi(baseUrl: baseUrl),
    );
    final RestaurantRepository restaurantRepository = RestaurantRepository(
      api: RestaurantApi(baseUrl: baseUrl),
    );
    final CartRepository cartRepository = CartRepository();
    final OrderRepository orderRepository = OrderRepository(
      apiFactory: (String token) => OrderApi(baseUrl: baseUrl, accessToken: token),
    );
    final PaymentRepository paymentRepository = PaymentRepository(
      apiFactory: (String token) => PaymentApi(baseUrl: baseUrl, accessToken: token),
    );
    final DriverOrderRepository driverOrderRepository = DriverOrderRepository(
      apiFactory: (String token) => DriverOrderApi(baseUrl: baseUrl, accessToken: token),
      authRepository: authRepository,
    );
    await authRepository.restoreSession();
    await driverOnboarding.restoreOnboarding();
    await cartRepository.load();
    runApp(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<AuthRepository>.value(value: authRepository),
          Provider<DriverOnboardingRepository>.value(value: driverOnboarding),
          Provider<RestaurantRepository>.value(value: restaurantRepository),
          ChangeNotifierProvider<CartRepository>.value(value: cartRepository),
          Provider<OrderRepository>.value(value: orderRepository),
          Provider<PaymentRepository>.value(value: paymentRepository),
          Provider<DriverOrderRepository>.value(value: driverOrderRepository),
        ],
        child: const KechDeliveryApp(),
      ),
    );
  });
}
