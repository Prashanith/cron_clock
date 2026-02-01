import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'src/navigation/route_generator.dart';
import 'src/navigation/routes.dart';
import 'src/services/init_services.dart';

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
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A73E8), // Vivid Blue accent
              brightness: Brightness.dark,
              surface: const Color(0xFF0D1117), // Very dark navy background
              surfaceContainer: const Color(
                0xFF161B22,
              ), // Lighter navy for cards/tiles
              onSurface: const Color(0xFFC9D1D9), // Soft white/grey text
            ).copyWith(
              primary: const Color(
                0xFF58A6FF,
              ), // Bright blue for active elements
              secondary: const Color(0xFF79C0FF),
            ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161B22),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
