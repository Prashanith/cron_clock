import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import '../features/cron/services/scheduling_service.dart';
import '../navigation/route_generator.dart';
import 'android_alarm_service.dart';
import 'db_service.dart';
import 'local_storage.dart';
import 'notification_service.dart';
import 'permission_service.dart';

final locator = GetIt.instance;

class ServiceInitializer {
  static Future<void> initializeServices() async {
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, 'isolate');

    locator.registerSingleton<DbService>(DbService());
    locator.registerSingleton<LocalStorage>(LocalStorage());
    locator.registerSingleton<RouteGenerator>(RouteGenerator());
    locator.registerSingleton<PermissionService>(PermissionService());
    locator.registerSingleton<SchedulingService>(SchedulingService());
    locator.registerSingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin(),
    );
    locator.registerSingleton<NotificationService>(NotificationService());

    await postInitializationServices();
  }

  static Future<void> postInitializationServices() async {
    await AndroidAlarmService.init();
    final db = locator<DbService>();
    await db.createDatabase();
    await NotificationService.instance.init();
  }
}
