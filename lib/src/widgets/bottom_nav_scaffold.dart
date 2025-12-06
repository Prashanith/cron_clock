import 'package:flutter/material.dart';

import '../features/cron/create_schedule.dart';

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
        return 'About';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getTitle(currentIndex)), leading: null),
      body: getWidget(currentIndex),
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
            ],
          ),
        ),
      ),
    );
  }
}
