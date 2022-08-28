// ===== main.dart ========================================
// Sets style settings and invokes the launch of the app.

import 'package:flutter/material.dart';
import 'package:app/routes/register.dart';
import 'package:app/routes/home.dart';
import 'package:app/models/profile_device.dart';
import 'package:app/notification_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getToken();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const App());
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT',
      // ===== Light Theme ======================
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        /* bottomAppBarColor: Colors.deepPurple, */
        cardColor: Colors.grey.shade100,
        expansionTileTheme: const ExpansionTileThemeData(
          textColor: Colors.black,
          iconColor: Colors.orange,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          modalBackgroundColor: Colors.orange.shade300,
        ),
      ),

      // ===== Dark Theme =======================
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
        ).copyWith(
          secondary: Colors.orange
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.orange,
        ),
      ),

      themeMode: ThemeMode.system,
      /* home: const RegisterRoute(), */
      home: HomeRoute(Profile(name: "Reem Kishinevsky", email: "reemkish@gmail.com", phoneNumber: "054 642 1200")),
    );
  }
}
