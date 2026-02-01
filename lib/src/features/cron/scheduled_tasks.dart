import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Future<List<ScheduledTask>> _future = Future.delayed(
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
              dense: true,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () async {
                  var data = await ScheduledTaskService.deleteTaskById(task.id);
                  if (data == 1) {
                    setState(() {
                      _future = fetchData();
                    });
                  }
                },
              ),
              // 4. Content Layout: Added padding and structure
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule: ${task.cron}',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getText(describeCron(task.cron)),
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM dd').format(
                            task.lastScheduledAt ?? DateTime.now(),
                          ), // Jan 17 Time
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(
                            task.lastScheduledAt ?? DateTime.now(),
                          ), // Jan 17 Time
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
