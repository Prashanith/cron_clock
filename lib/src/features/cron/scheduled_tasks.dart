import 'package:flutter/material.dart';
import 'models/scheduled_task.dart';
import 'services/schedule_task_service.dart';

class ScheduledTasks extends StatefulWidget {
  const ScheduledTasks({super.key});

  @override
  State<ScheduledTasks> createState() => _ScheduledTasksState();
}

class _ScheduledTasksState extends State<ScheduledTasks> {
  late List<ScheduledTask> scheduledTasks = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduledTask>>(
      future: ScheduledTaskService.getAllTasks(),
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
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.cron),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await ScheduledTaskService.deleteTaskById(task.id);
                  // 🔄 Rebuild UI
                  (context as Element).markNeedsBuild();
                },
              ),
            );
          },
        );
      },
    );
  }
}
