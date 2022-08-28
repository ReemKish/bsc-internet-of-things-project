// ===== notification_hub.dart ============================
// Unified API to access Azure's Notification Hun and the device's Push Notification Service (PNS)

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app/utilities/api_monitor.dart';

class NotificationService {
  static const name = "arc-notification-hub";
  static const namespace = "arc-notification-hub-namespace";
  static const sasToken = "SharedAccessSignature sr=https%3A%2F%2Farc-notification-hub-namespace.servicebus.windows.net%2Farc-notification-hub&sig=GWKH1XbiCn5qFOm6DSk3UHHc%2BHCcORZ53tlGBTJGCcE%3D&se=11661451928&skn=DefaultFullSharedAccessSignature";

  static Future<bool> subscribe(String email) async {
    email = email.replaceAll('@', '_at_');
    String? gcmToken = await FirebaseMessaging.instance.getToken();
    return apiCallSuccess(
      "subscribe($email)",
      await _addInstallation(email, gcmToken!),
    );
    
  }


  static Future<bool> unsubscribe(String email) async {
    email = email.replaceAll('@', '_at_');
    return apiCallSuccess(
      "unsubscribe($email)",
      await _removeInstallation(email),
    );
  }


  static Future<bool> pauseSubscribtion(String email) async {
    email = email.replaceAll('@', '_at_');
    return apiCallSuccess(
      "pauseSubscription($email)",
      await _unlinkInstallationFromToken(email),
    );
  }

  static Future<bool> resumeSubscription(String email) async {
    email = email.replaceAll('@', '_at_');
    String? gcmToken = await FirebaseMessaging.instance.getToken();
    return apiCallSuccess(
      "resumeSubscription($email)",
      await _linkInstallationToToken(email, gcmToken!),
    );
  }


  static Future<bool> followDevice(String email, String deviceId) async {
    email = email.replaceAll('@', '_at_');
    String? gcmToken = await FirebaseMessaging.instance.getToken();
    return apiCallSuccess(
      "followDevice($email, $deviceId)",
      await _patchInstallationTags(email, gcmToken!, deviceId, 'add'),
    );
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

  static Future<http.Response> _addInstallation(String id, String gcmToken) async => http.put(
    Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
    headers: {"Content-Type": "application/json", "Authorization": sasToken},
    body: jsonEncode(<String, dynamic>{
      "installationId": id,
      "platform": "gcm",
      "pushChannel": gcmToken,
    })
  );


  static Future<http.Response> _removeInstallation(String id) async => http.delete(
    Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
    headers: {"Authorization": sasToken},
  );

  static Future<http.Response> _patchInstallationTags(String id, String gcmToken, String tag, String op) async => http.patch(
    Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
    headers: {"Content-Type": "application/json-patch+json", "Authorization": sasToken},
    body: jsonEncode([{
      "op": op,
      "path": "/tags",
      "value": tag,
    }])
  );

  static Future<http.Response> _unlinkInstallationFromToken(String id) async => http.patch(
    Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
    headers: {"Content-Type": "application/json-patch+json", "Authorization": sasToken},
    body: jsonEncode([{
      "op": "add",
      "path": "/pushChannel",
      "value": "_"
    }])
  );

  static Future<http.Response> _linkInstallationToToken(String id, String gcmToken) async => http.patch(
    Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
    headers: {"Content-Type": "application/json-patch+json", "Authorization": sasToken},
    body: jsonEncode([{
      "op": "add",
      "path": "/pushChannel",
      "value": gcmToken
    }])
  );
}
