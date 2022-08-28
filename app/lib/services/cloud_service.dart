// ===== cloud_services.dart ==============================
// API to access Azure Cloud Functions.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/utilities/api_monitor.dart';
import 'package:app/models/profile.dart';
import 'package:app/models/login_data.dart';

class CloudService {
  static const namespace = "arc-fun";
  static const apiKeyHeader = {"x-functions-key":"T0m9ThzqRnkVT3EmPhdI3YGx3exjZi8Ttz2ZGhdrH6UaAzFukgO3Ww=="};

  static Future<bool> signUp(String name, String phoneNumber, String email, String password) async {
    return apiCallSuccess(
      "signUp($name, $phoneNumber, $email, $password)",
      await _signUp(name, phoneNumber, email, password)
    );
  }

  static Future<LoginData?> logIn(String email, String password) async {
    final response = await _logIn(email, password);
    if (!apiCallSuccess("logIn($email, $password)", response)) return null;
    return LoginData.fromJson(jsonDecode(response.body));
  }

  static Future<Profile?> follow(String email, String deviceId) async {
    final response = await _follow(email, deviceId);
    if (!apiCallSuccess("follow($email, $deviceId)", response)) return null;
    return Profile.fromJson(jsonDecode(response.body));
  }


  static Future<bool> unfollow(String email, String deviceId) async {
    return apiCallSuccess(
      "follow($email, $deviceId, delete: true)",
      await _follow(email, deviceId, delete: true)
    );
  }


  static Future<bool> link(String email, String deviceId) async {
    return apiCallSuccess(
      "link($email, $deviceId, delete: true)",
      await _registerDevice(email, deviceId)
    );
  }


  static Future<http.Response> _registerDevice(String email, String deviceId) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/RegisterDevice"),
    headers: apiKeyHeader,
    body: jsonEncode(<String, dynamic>{
      "email": email,
      "deviceId": deviceId,
    })
  );

  static Future<http.Response> _signUp(String name, String phoneNumber, String email, String password) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/SignUp"),
    headers: apiKeyHeader,
    body: jsonEncode(<String, dynamic>{
      "name": name,
      "phoneNumber": phoneNumber,
      "email": email,
      "password": password
    })
  );

  static Future<http.Response> _logIn(String email, String password) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/LogIn"),
    headers: apiKeyHeader,
    body: jsonEncode(<String, dynamic>{
      "email": email,
      "password": password
    })
  );


  static Future<http.Response> _follow(String email, String deviceId, {bool? delete}) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/Follow"),
    headers: apiKeyHeader,
    body: jsonEncode(<String, dynamic>{
      "email": email,
      "deviceId": deviceId,
      "delete": delete,
    })
  );
}

