import 'package:flutter/material.dart';
import '../../services/init_services.dart';
import '../../utils/cron_converter.dart';
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
              validator: (v) => !v!.isNotEmpty ? 'Required' : null,
              decoration: InputDecoration(
                isDense: true,
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
                isDense: true,
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
                isDense: true,
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
                    child: Text('Summarize'),
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 10,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final ValueNotifier<bool> loadingNotifier =
                          ValueNotifier<bool>(true);
                      final ValueNotifier<String> responseNotifier =
                          ValueNotifier<String>('');

                      showDialog(
                        context: context,
                        barrierDismissible:
                            false,
                        builder: (context) {
                          return AlertDialog(
                            content: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              height: MediaQuery.sizeOf(context).height * 0.33,
                              child: ValueListenableBuilder(
                                valueListenable: loadingNotifier,
                                builder: (context, isLoading, _) {
                                  return ValueListenableBuilder(
                                    valueListenable: responseNotifier,
                                    builder: (context, responseMsg, _) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isLoading)
                                            const CircularProgressIndicator(),
                                          if (responseMsg.isNotEmpty)
                                            Text(responseMsg),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            actions: [
                              ValueListenableBuilder(
                                valueListenable: loadingNotifier,
                                builder: (context, isLoading, _) {
                                  return isLoading
                                      ? const SizedBox.shrink()
                                      : FilledButton(
                                          onPressed: () => Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop(),
                                          child: const Text('OK'),
                                        );
                                },
                              ),
                            ],
                          );
                        },
                      );

                      try {
                        var lastScheduledAt = CronUtils.computeNextRun(
                          cronController.text,
                        );
                        var task = ScheduledTask(
                          title: titleController.text,
                          description: descriptionController.text,
                          cron: cronController.text,
                          lastScheduledAt: lastScheduledAt,
                        );

                        var id = await ScheduledTaskService.createTask(task);
                        var service = locator<SchedulingService>();
                        await service.scheduleCron(id);

                        responseNotifier.value = 'Schedule Created';
                      } catch (e) {
                        responseNotifier.value = 'Error Occurred';
                      } finally {
                        loadingNotifier.value = false;
                      }
                    },
                    child: Text('Schedule'),
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
