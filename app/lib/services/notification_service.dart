// ===== notification_hub.dart ============================
// Unified API to access Azure's Notification Hun and the device's Push Notification Service (PNS)

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static const name = "arc-notification-hub";
  static const namespace = "arc-notification-hub-namespace";
  static const sasToken = "SharedAccessSignature sr=https%3A%2F%2Farc-notification-hub-namespace.servicebus.windows.net%2Farc-notification-hub&sig=GWKH1XbiCn5qFOm6DSk3UHHc%2BHCcORZ53tlGBTJGCcE%3D&se=11661451928&skn=DefaultFullSharedAccessSignature";

  static void subscribe(String email) async {
    FirebaseMessaging.instance.getToken().then((value) {
      String token = value!;
      email = email.replaceAll('@', '_at_');
      _addInstallation(email, token).then((http.Response value) {
        debugPrint(value.statusCode == 200 ?
          "subscribe($email) - failed with status ${value.statusCode}" :
          "subscribe($email) - success"
        );
      });
    });
  }

  static void followDevice(String email, String deviceId) async {
    FirebaseMessaging.instance.getToken().then((value) {
      String token = value!;
      email = email.replaceAll('@', '_at_');
      _patchInstallation(email, token, deviceId).then((http.Response value) {
        debugPrint(value.statusCode == 200 ?
          "subscribe($email) - failed with status ${value.statusCode}" :
          "subscribe($email) - success"
        );
      });
    });
  }


  static void registerForegroundHandler(Function(String deviceId) action) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
      action(message.data["deviceId"]);
    });
  }

  static Future<http.Response> _addInstallation(String id, String gcmToken) async {
    final headers = {"Content-Type": "application/json", "Authorization": sasToken};
    return http.put(
      Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        "installationId": id,
        "platform": "gcm",
        "pushChannel": gcmToken,
      })
    );
  }

  static Future<http.Response> _patchInstallation(String id, String gcmToken, String tag) async {
    final headers = {"Content-Type": "application/json-patch+json", "Authorization": sasToken};
    return http.patch(
      Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
      headers: headers,
      body: jsonEncode([{
        "op": "add",
        "path": "/tags",
        "value": tag,
      }])
    );
  }
}
