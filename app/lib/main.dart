// ===== main.dart ==============================
// Sets style settings and invokes the launch of the app.

import 'package:flutter/material.dart';
import 'package:app/routes/register.dart';


void main() {
  runApp(const App());
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.purple,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
      ),
      themeMode: ThemeMode.system,
      home: const RegisterRoute(),
    );
  }
}
