import 'package:flutter/material.dart';

import '../features/cron/cron_clock.dart';
import '../features/splash/splash_screen.dart';
import 'routes.dart';

class RouteGenerator {
  final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.init:
        return Page(const SplashScreen());
      case Routes.cronClock:
        return Page(const CronClock());
      default:
        return Page(const SplashScreen());
    }
  }
}

// ignore: non_constant_identifier_names
Route<dynamic> Page(Widget widget) {
  return MaterialPageRoute(builder: (_) => widget);
}
