import 'package:flutter/material.dart';

import '../../utils/cron_validators.dart';

class CreateSchedule extends StatefulWidget {
  const CreateSchedule({super.key});

  @override
  State<CreateSchedule> createState() => _CreateScheduleState();
}

class _CreateScheduleState extends State<CreateSchedule> {
  final _formKey = GlobalKey<FormState>();

  final cronController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(border: OutlineInputBorder( )),
              controller: cronController,
              validator: validateCronMinute,
            ),
            Text(cronController.value.text),
            FilledButton(onPressed: () => {}, child: Text('Create Schedule')),
          ],
        ),
      ),
    );
  }
}
