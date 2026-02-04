import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../features/cron/services/schedule_task_service.dart';
import '../features/cron/services/scheduling_service.dart';
import '../utils/cron_converter.dart';
import 'db_service.dart';
import 'init_services.dart';

class AndroidAlarmService {
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }
}

@pragma('vm:entry-point')
Future<void> rescheduleNextForId(int id) async {
  print('Rescheduling');
  final scheduledTask = await ScheduledTaskService.getTaskById(id.toString());
  if (scheduledTask != null) {
    print('Scheduled');
    print(scheduledTask.lastScheduledAt);
    print(DateTime.now());
    if (scheduledTask.lastScheduledAt != null &&
        scheduledTask.lastScheduledAt!.isBefore(DateTime.now())) {
      print('Before');
      var service = locator<SchedulingService>();
      final next = CronUtils.computeNextRun(scheduledTask.cron);
      scheduledTask.lastScheduledAt = next;
      await ScheduledTaskService.updateTaskById(scheduledTask);
      if (next != null) {
        print('Listening');
        service.listen(scheduledTask, next);
      }
    }
  }
}

@pragma('vm:entry-point')
void alarmCallback(int id) async {
  print('callbacks');
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  var location = tz.getLocation('Asia/Kolkata');
  tz.setLocalLocation(location);
  if (!locator.isRegistered<DbService>()) {
    await ServiceInitializer.initializeServices(skipPostInitialization: true);
  }
  await rescheduleNextForId(id);
}
