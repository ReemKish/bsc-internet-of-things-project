// ===== dialog_item.dart ==============================
import 'package:flutter/material.dart';

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
