import '../features/cron/services/schedule_task_service.dart';
import '../features/cron/services/scheduling_service.dart';
import '../utils/cron_converter.dart';
import 'init_services.dart';

class AlarmEngine {
  AlarmEngine._private();

  static final AlarmEngine instance = AlarmEngine._private();

  @pragma('vm:entry-point')
  Future<void> rescheduleNextForId(int id) async {
    final scheduledTask = await ScheduledTaskService.getTaskById(id.toString());
    if (scheduledTask != null) {
      var service = locator<SchedulingService>();
      final next = CronUtils.computeNextRun(scheduledTask.cron);
      if (next != null) {
        service.listen(scheduledTask, next);
      }
    }
  }
}

@pragma('vm:entry-point')
void alarmCallback(int id) async {
  print('Rescheduling');
  await AlarmEngine.instance.rescheduleNextForId(id);
}
