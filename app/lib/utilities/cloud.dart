// ===== cloud.dart ==============================
import 'package:app/utilities/models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app/api/notification_hub.dart';


/* Notification Hub */
const nhName = "arc-notification-hub";
const nhNamespace = "arc-notification-hub-namespace";

Device id2device(String id) {
  if (id == "DEV::123456") {
    return Device("2", Profile("Yuval Cohen", "yuvalc@walla.co.il", "054-631-1200"));
  } else
  if (id == "DEV::1a2b3c") {
    return Device('1', Profile("David Molina", "davidm@gmail.com", "054-123-4567"));
  } else {
    return Device("2", Profile("Re'em Kishinevsky", "reem.kishinevsky@gmail.com", "054-642-1200"));
  }
}

void fallAction(Function(String deviceId) action) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
    action(message.data["deviceId"]);
  });
}


void subscribeToNotifications(String email) async {
  FirebaseMessaging.instance.getToken().then((value) {
    String token = value!;
    print("Registering $email");
    email = email.replaceAll('@', '_at_');
    NotificationHub.registerDevice(email, token);
  });
}
