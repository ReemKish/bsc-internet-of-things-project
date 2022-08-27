// ===== alerts.dart ======================================
// Various alerts and dialogs used throught the app.

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


alertDiaglog({
  required BuildContext context,
  String? title,
  String? content,
}) {
  showDialog(
    context: context,
    builder: (_) =>
      AlertDialog(
        title: Text(title?? ""),
        content: Text(content?? ""),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop();
          },
            child: const Text("Dismiss")),
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
      duration: const Duration(seconds: 1),
    )
  );
}


class DialogItem extends StatelessWidget {
  const DialogItem({
    Key? key,
    this.icon,
    this.color,
    required this.text,
    required this.action,
  }) : super(key: key);

  final IconData? icon;
  final Color? color;
  final String text;
  final Function action;

  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop(text);
        action();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color ?? defaultColor),
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}


class DialogFieldButton extends StatefulWidget {
  const DialogFieldButton({
    Key? key,
    this.icon,
    this.color,
    required this.text,
    required this.action,
  }) : super(key: key);

  final IconData? icon;
  final Color? color;
  final String text;
  final Function(String) action;

  @override
  State<DialogFieldButton> createState() => _DialogFieldButtonState();
}

class _DialogFieldButtonState extends State<DialogFieldButton> {
  bool _isTextFieldShown = false;
  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _isTextFieldShown = true;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 36, color: widget.color ?? defaultColor),
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: FieldButton(action: (String value) {
                  Navigator.of(context).pop(widget.text);
                  widget.action(value);
                },
                text: widget.text,
                isTextFieldShown: _isTextFieldShown
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class FieldButton extends StatelessWidget {
  final bool isTextFieldShown;
  final String text;
  final Function(String) action;
  const FieldButton({Key? key, required this.action, required this.text, required this.isTextFieldShown}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isTextFieldShown 
          ? TextFormField(
              initialValue: "ARC-001",  // TODO remove this
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
              onFieldSubmitted: (String value) {action(value);},
            )
          : Text(text);
  }
}
