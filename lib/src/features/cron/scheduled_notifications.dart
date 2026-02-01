import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/init_services.dart';
import '../../services/notification_service.dart';
import '../../utils/cron_summary.dart';
import 'package:intl/intl.dart';

class UpcomingSchedules extends StatefulWidget {
  const UpcomingSchedules({super.key});

  @override
  State<UpcomingSchedules> createState() => _UpcomingSchedulesState();
}

class _UpcomingSchedulesState extends State<UpcomingSchedules> {
  late List<PendingNotificationRequest> scheduledTasks = [];
  Future<List<PendingNotificationRequest>> _future = Future.delayed(
    Duration(seconds: 0),
    () => [],
  );

  String getText(CronDescriptionResult? result) {
    if (result != null) {
      if (result.errorMessage != null) {
        return result.errorMessage!;
      }
      if (result.outputMessage != null) {
        return result.outputMessage!;
      }
    }
    return '';
  }

  Future<List<PendingNotificationRequest>> fetchData() async {
    var list = await locator<NotificationService>().getAll();
    return list;
  }

  void _reload() {
    setState(() {
      _future = fetchData();
    });
  }

  @override
  void initState() {
    super.initState();
    _future = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PendingNotificationRequest>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No scheduled tasks'));
        }

        final notifications = snapshot.data!;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final task = notifications[index];
            return ListTile(
              title: Text(task.title ?? ''),
              subtitle: Text(task.body ?? ''),
              trailing: Text(
                DateFormat(
                  'MMM dd hh:mm a',
                ).format(DateTime.parse(task.payload ?? '')),
              ),
            );
          },
        );
      },
    );
  }
}
