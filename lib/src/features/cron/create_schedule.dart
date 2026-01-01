import 'package:flutter/material.dart';

import '../../services/init_services.dart';
import '../../utils/cron_summary.dart';
import '../../utils/cron_validators.dart';
import 'models/scheduled_task.dart';
import 'services/schedule_task_service.dart';
import 'services/scheduling_service.dart';

class CreateSchedule extends StatefulWidget {
  const CreateSchedule({super.key});

  @override
  State<CreateSchedule> createState() => _CreateScheduleState();
}

class _CreateScheduleState extends State<CreateSchedule> {
  final _formKey = GlobalKey<FormState>();
  CronDescriptionResult? cronInfo;
  bool isLoading = false;
  String response = '';

  final cronController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

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
            ?cronInfo != null ? Text(getText(cronInfo)) : null,
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
                        var info = describeCron(cronController.value.text);
                        setState(() {
                          cronInfo = info;
                        });
                      }
                    },
                    child: Text('Create Summary'),
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 10,
                  child: FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                width: MediaQuery.widthOf(context) * 0.9,
                                height: MediaQuery.heightOf(context) * 0.33,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (isLoading) CircularProgressIndicator(),
                                    if (response != '') Text(response),
                                  ],
                                ),
                              ),
                              actions: [
                                if (!isLoading)
                                  FilledButton(
                                    onPressed: () => Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(),
                                    child: Text('OK'),
                                  ),
                              ],
                            );
                          },
                        );
                        try {
                          setState(() {
                            isLoading = true;
                          });
                          var task = ScheduledTask(
                            title: titleController.text,
                            description: descriptionController.text,
                            cron: cronController.text,
                          );
                          var id = await ScheduledTaskService.createTask(task);
                          setState(() {
                            response = 'Schedule Created';
                          });
                          var service = locator<SchedulingService>();
                          service.scheduleCron(id);
                        } catch (e) {
                          setState(() {
                            response = 'Error Occurred';
                          });
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
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
