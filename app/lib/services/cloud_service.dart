// ===== cloud_services.dart ==============================
// API to access Azure Cloud Functions.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/profile_device.dart';
import 'package:app/utilities/api_monitor.dart';
import 'package:app/models/profile_device.dart';

class CloudService {
  static const namespace = "arc-fun";

  static Future<bool> signUp(String name, String phoneNumber, String email, String password) async {
    return apiCallSuccess(
      "signUp($name, $phoneNumber, $email, $password)",
      await _signUp(name, phoneNumber, email, password)
    );
  }

  static Future<bool> logIn(String email, String password) async {
    return apiCallSuccess(
      "login($email, $password)",
      await _logIn(email, password),
    );
  }

  static Future<Profile?> follow(String email, String deviceId) async {
    final response = await _follow(email, deviceId);
    if (!apiCallSuccess("follow($email, $deviceId)", response)) return null;
    return Profile.fromJson(jsonDecode(response.body));

  }

  static Future<http.Response> _signUp(String name, String phoneNumber, String email, String password) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/SignUp"),
    body: jsonEncode(<String, dynamic>{
      "name": name,
      "phoneNumber": phoneNumber,
      "email": email,
      "password": password
    })
  );

  static Future<http.Response> _logIn(String email, String password) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/LogIn"),
    body: jsonEncode(<String, dynamic>{
      "email": email,
      "password": password
    })
  );


  static Future<http.Response> _follow(String email, String deviceId) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/Follow"),
    body: jsonEncode(<String, dynamic>{
      "email": email,
      "deviceId": deviceId,
    })
  );
}

