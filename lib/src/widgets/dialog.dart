import 'package:flutter/material.dart';

Future<T?> customDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  String? positiveText,
  String? negativeText,
  T? positiveResult,
  T? negativeResult,
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          if (negativeText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(negativeResult),
              child: Text(negativeText),
            ),
          if (positiveText != null)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(positiveResult),
              child: Text(positiveText),
            ),
        ],
      );
    },
  );
}
