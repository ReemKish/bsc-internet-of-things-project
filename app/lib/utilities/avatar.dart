// ===== avatar.dart ==============================
// Generate avatars from names.

import 'dart:core';
import 'package:flutter/material.dart';

Color name2color(String name) {
  final colors = List.from(Colors.primaries);
  colors.remove(Colors.yellow);
  colors.remove(Colors.amber);
  return colors[name.hashCode % colors.length].shade700;
}

String name2initials(String name) {
  List<String> words = name.split(" ");
  if (words.isEmpty || words[0].isEmpty) return "";
  if (words.length == 1 || words[1].isEmpty) return words[0][0];
  return words[0][0] + words[1][0];
}

name2avatar(String name, { double size = 24.0 }) {
  return CircleAvatar(
    radius: size * 1.5,
    backgroundColor: name2color(name),
    child: Text(
      name2initials(name),
      style: TextStyle(
        fontSize: size,
        color:  Colors.white
      ),
    ),
  );
}
