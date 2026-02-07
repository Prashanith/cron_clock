import 'package:flutter/material.dart';
import 'about/about_us.dart';
import 'cron/create_schedule.dart';
import 'cron/upcoming_schedules.dart';
import 'cron/scheduled_tasks.dart';
import '../widgets/logo.dart';

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
        return ScheduledTasks();
      case 1:
        return UpcomingSchedules();
      case 2:
        return AboutUs();
      default:
        return Center();
    }
  }

  String getTitle(int i) {
    switch (i) {
      case 0:
        return 'Scheduled Tasks';
      case 1:
        return 'Upcoming Schedules';
      case 2:
        return 'About Us';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
          child: getWidget(currentIndex),
        ),
      ),
      floatingActionButton: currentIndex != 0
          ? null
          : FloatingActionButton(
              elevation: 10,
              shape: const CircleBorder(),
              child: Icon(Icons.add),
              onPressed: () => showModalBottomSheet(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                isScrollControlled: true,
                context: context,
                builder: (context) => CreateSchedule(),
              ),
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
                icon: Icon(Icons.list),
                label: 'Schedules',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications_sharp),
                label: 'Upcoming',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'About',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
