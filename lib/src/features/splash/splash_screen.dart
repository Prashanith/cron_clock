import 'package:flutter/material.dart';

import '../../navigation/route_generator.dart';
import '../../navigation/routes.dart';
import '../../services/init_services.dart';
import '../../widgets/logo.dart';
import '../../widgets/plain_scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void navigate() {
    final router = locator<RouteGenerator>();
    Future.delayed(
      Duration(milliseconds: 1500),
      () => router.navigator.currentState?.pushNamed(Routes.cronClock),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
    return const PlainScaffold(
      widget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Logo()],
        ),
      ),
    );
  }
}
