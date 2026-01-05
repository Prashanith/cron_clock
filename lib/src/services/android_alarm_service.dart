import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'init_services.dart';
import 'permission_service.dart';

class AndroidAlarmService {
  static Future<bool> _checkExactAlarmPermission() async {
    final currentStatus = await locator<PermissionService>().requestPermission(
      Permission.scheduleExactAlarm,
    );
    return currentStatus.isGranted;
  }

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
 //   await _checkExactAlarmPermission();
  }
}
