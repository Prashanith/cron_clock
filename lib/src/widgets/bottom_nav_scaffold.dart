import 'package:flutter/material.dart';
import '../features/cron/create_schedule.dart';
import '../features/cron/scheduled_notifications.dart';
import '../features/cron/scheduled_tasks.dart';
import 'logo.dart';

class BottomNavScaffold extends StatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int currentIndex = 0;

  Widget getWidget(int i) {
    switch (i) {
      case 0:
        return CreateSchedule();
      case 1:
        return ScheduledTasks();
      case 2:
        return ScheduledNotifications();
      default:
        return Center();
    }
  }

  String getTitle(int i) {
    switch (i) {
      case 0:
        return 'Cron Clock';
      case 1:
        return 'Scheduled Tasks';
      case 2:
        return 'Notifications';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle(currentIndex)),
        leading: Transform.scale(scale: 0.7, child: Logo()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: getWidget(currentIndex),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        height: 90,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (i) => setState(() {
              currentIndex = i;
            }),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.timelapse_sharp),
                label: 'Clock',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Schedules',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications_sharp),
                label: 'Notifications',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
