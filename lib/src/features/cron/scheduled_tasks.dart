import 'package:flutter/material.dart';

import '../../utils/cron_summary.dart';
import 'models/scheduled_task.dart';
import 'services/schedule_task_service.dart';

class ScheduledTasks extends StatefulWidget {
  const ScheduledTasks({super.key});

  @override
  State<ScheduledTasks> createState() => _ScheduledTasksState();
}

class _ScheduledTasksState extends State<ScheduledTasks> {
  late List<ScheduledTask> scheduledTasks = [];
  Future<List<ScheduledTask>> _future = Future.delayed(Duration(seconds: 0), ()=>[]);

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

  Future<List<ScheduledTask>> fetchData() async {
    var list = await ScheduledTaskService.getAllTasks();
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
    return FutureBuilder<List<ScheduledTask>>(
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

        final tasks = snapshot.data!;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ExpansionTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  var data = await ScheduledTaskService.deleteTaskById(task.id);
                  if (data == 1) {
                    setState(() {
                      _future = fetchData();
                    });
                  }
                },
              ),
              children: [
                Text(task.cron),
                Text(getText(describeCron(task.cron))),
              ],
            );
          },
        );
      },
    );
  }
}
