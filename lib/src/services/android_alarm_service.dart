import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../features/cron/services/schedule_task_service.dart';
import '../features/cron/services/scheduling_service.dart';
import '../utils/cron_converter.dart';
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
    await _checkExactAlarmPermission();
  }
}

@pragma('vm:entry-point')
Future<void> rescheduleNextForId(int id) async {
  await ServiceInitializer.initializeServices();
  final scheduledTask = await ScheduledTaskService.getTaskById(id.toString());
  if (scheduledTask != null) {
    var service = locator<SchedulingService>();
    final next = CronUtils.computeNextRun(scheduledTask.cron);
    if (next != null) {
      service.listen(scheduledTask, next);
    }
  }
}

@pragma('vm:entry-point')
void alarmCallback(int id) async {
  print('Rescheduling');
  // await AlarmEngine.instance.rescheduleNextForId(id);
}
