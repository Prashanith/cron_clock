import 'package:flutter/material.dart';

import '../../utils/cron_summary.dart';
import '../../utils/cron_validators.dart';
import 'models/scheduled_task.dart';
import 'services/schedule_task_service.dart';

class CreateSchedule extends StatefulWidget {
  const CreateSchedule({super.key});

  @override
  State<CreateSchedule> createState() => _CreateScheduleState();
}

class _CreateScheduleState extends State<CreateSchedule> {
  final _formKey = GlobalKey<FormState>();
  String? cronInfo;

  final cronController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: titleController,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: descriptionController,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'cron',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: cronController,
              validator: validateCronExpression,
            ),
            SizedBox(height: 20),
            ?cronInfo != null ? Text(cronInfo!) : null,
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 10,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        cronInfo = describeCron(cronController.value.text);
                      }
                    },
                    child: Text('Create Summary'),
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 10,
                  child: FilledButton(
                    onPressed: () async => {
                      if (_formKey.currentState!.validate())
                        {
                          await ScheduledTaskService.createTask(
                            ScheduledTask(
                              title: 'Cron',
                              description: "The Nerd's Clock",
                              cron: '* * * * *',
                            ),
                          ),
                        },
                    },
                    child: Text('Create Schedule'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
