import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

import 'alarm_engine.dart';

void alarmCallback(int id) async {
  await AlarmEngine.instance.showNotificationAndPlaySound(id);
  await AlarmEngine.instance.rescheduleNextForId(id);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await AlarmEngine.instance.initialize();

  runApp(const MyApp());
}

/// Simple app UI + controller
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cron Alarm Example',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const CronAlarmPage(),
    );
  }
}

class CronAlarmPage extends StatefulWidget {
  const CronAlarmPage({super.key});
  @override
  State<CronAlarmPage> createState() => _CronAlarmPageState();
}

class _CronAlarmPageState extends State<CronAlarmPage> {
  final _formKey = GlobalKey<FormState>();
  final _cronController = TextEditingController(
    text: '*/1 * * * *',
  ); // default every minute
  final _labelController = TextEditingController(text: 'My Cron Alarm');

  // Keeps mapping: alarmId -> cron expression
  // In a production app persist this mapping (shared_preferences / database) so reboot/reschedule works.
  Map<int, String> scheduledCrons = {};

  int nextId = 1;

  @override
  void dispose() {
    _cronController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _scheduleCron() async {
    final cron = _cronController.text.trim();
    if (cron.isEmpty) return;

    // For demo we do minimal validation here
    final next = CronUtils.computeNextRun(cron);
    if (next == null) {
      _showSnack(
        'Unsupported cron format (supported: "*/N * * * *" or "M H * * *" or simple lists/ranges).',
      );
      return;
    }

    final id = nextId++;
    // Save mapping in-memory. Persist in real app.
    scheduledCrons[id] = cron;

    // Store the label for notifications
    AlarmEngine.instance.labels[id] = _labelController.text.trim().isEmpty
        ? 'Alarm'
        : _labelController.text.trim();

    // Schedule one-shot at 'next'
    await AndroidAlarmManager.oneShotAt(
      next,
      id,
      alarmCallback,
      wakeup: true,
      exact: true,
      rescheduleOnReboot: true,
    );

    _showSnack('Scheduled alarm #$id at $next for cron: $cron');
    setState(() {});
  }

  Future<void> _cancelAll() async {
    for (final id in scheduledCrons.keys) {
      await AndroidAlarmManager.cancel(id);
    }
    scheduledCrons.clear();
    AlarmEngine.instance.labels.clear();
    _showSnack('Canceled all alarms');
    setState(() {});
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cron Alarm Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cronController,
                decoration: const InputDecoration(
                  labelText: 'Cron expression (minute hour day month weekday)',
                  hintText: 'Examples: "*/5 * * * *" or "30 7 * * *"',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Alarm label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _scheduleCron,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _cancelAll,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Scheduled (in-memory)'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: scheduledCrons.entries
                      .map(
                        (e) => ListTile(
                          title: Text('ID ${e.key} — ${e.value}'),
                          subtitle: Text(
                            'Label: ${AlarmEngine.instance.labels[e.key] ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await AndroidAlarmManager.cancel(e.key);
                              scheduledCrons.remove(e.key);
                              AlarmEngine.instance.labels.remove(e.key);
                              setState(() {});
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
