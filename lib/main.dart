import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'src/navigation/route_generator.dart';
import 'src/navigation/routes.dart';
import 'src/services/init_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  const channel = MethodChannel('exact_alarm_permission');

  if (Platform.isAndroid) {
    try {
      await channel.invokeMethod('requestExactAlarm');
    } catch (_) {}
  }
  await ServiceInitializer.initializeServices();
  runApp(const CronClock());
}

class CronClock extends StatelessWidget {
  const CronClock({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cron Clock',
      initialRoute: Routes.init,
      navigatorKey: locator.get<RouteGenerator>().navigator,
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          surface: Colors.blueGrey.shade900,
          seedColor: Colors.deepPurple.shade900,
        ),
      ),
    );
  }
}
