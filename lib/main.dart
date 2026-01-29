import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'src/navigation/route_generator.dart';
import 'src/navigation/routes.dart';
import 'src/services/init_services.dart';
import 'src/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  var location = tz.getLocation('Asia/Kolkata');
  tz.setLocalLocation(location);
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
