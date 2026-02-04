import 'package:flutter/material.dart';
import '../../services/init_services.dart';
import '../../utils/cron_converter.dart';
import '../../utils/cron_summary.dart';
import '../../utils/cron_validators.dart';
import '../../widgets/snack_bar.dart';
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
  final ValueNotifier<bool> loadingNotifier = ValueNotifier<bool>(false);

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
      padding: EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Text('Create Schedule', style: TextStyle(fontSize: 30)),
            SizedBox(height: 20),
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
                      loadingNotifier.value = true;
                      if (!_formKey.currentState!.validate()) return;
                      _formKey.currentState?.deactivate();
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

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(getSnackBar('Schedule Created'));
                        _formKey.currentState?.reset();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(getSnackBar('Error Creating Schedule'));
                      } finally {
                        _formKey.currentState?.activate();
                        loadingNotifier.value = false;
                      }
                    },
                    child: Text('Schedule'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            ValueListenableBuilder(
              valueListenable: loadingNotifier,
              builder: (context, isLoading, _) {
                return ValueListenableBuilder(
                  valueListenable: loadingNotifier,
                  builder: (context, responseMsg, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading) const CircularProgressIndicator(),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
