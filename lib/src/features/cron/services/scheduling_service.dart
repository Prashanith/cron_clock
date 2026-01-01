import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../../../services/alarm_engine.dart';
import '../../../services/notification_service.dart';
import '../../../utils/cron_converter.dart';
import '../models/scheduled_task.dart';
import 'schedule_task_service.dart';

class SchedulingService {
  Future<void> scheduleCron(int id) async {
    final scheduledTask = await ScheduledTaskService.getTaskById(id.toString());
    if (scheduledTask != null) {
      final next = CronUtils.computeNextRun(scheduledTask.cron);
      listen(scheduledTask, next ?? DateTime.now());
    }
  }

  Future<void> listen(ScheduledTask scheduledTask, DateTime next) async {
    await AndroidAlarmManager.oneShotAt(
      next,
      int.tryParse(scheduledTask.id) ?? 0,
      alarmCallback,
      wakeup: true,
      exact: true,
      rescheduleOnReboot: true,
    );
    print('Alarm');
    await NotificationService.instance.schedule(
      id: int.tryParse(scheduledTask.id) ?? 0,
      title: scheduledTask.title,
      body: scheduledTask.description,
      dateTime: next,
    );
    print('Notification');
  }
}
