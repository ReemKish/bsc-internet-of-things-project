// ===== alerts.dart ==============================

import 'package:flutter/material.dart';

confirmDiaglog({
  required BuildContext context,
  required String prompt,
  required Function() action
}) {
  showDialog(
    context: context,
    builder: (_) =>
      AlertDialog(
        content: Text(prompt),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop();
            action();
          },
            child: const Text("Yes")),
          TextButton(onPressed: () {
              Navigator.of(context).pop();
          },
            child: const Text("No")),
        ]
      ),
  );
}


void showInSnackBar(
  BuildContext context,
  String msg,
) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      duration: const Duration(milliseconds: 1000),
    )
  );
}
