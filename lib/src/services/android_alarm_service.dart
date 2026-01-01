import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class AndroidAlarmService {
  Future<bool> _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    return currentStatus.isGranted;
  }

  static void init() async {
    AndroidAlarmManager.initialize();
  }
}
