import 'package:flutter/cupertino.dart';

import '../../widgets/bottom_nav_scaffold.dart';

class CronClock extends StatefulWidget {
  const CronClock({super.key});

  @override
  State<CronClock> createState() => _CronClockState();
}

class _CronClockState extends State<CronClock> {
  @override
  Widget build(BuildContext context) {
    return const BottomNavScaffold();
  }
}
