// ===== cloud_services.dart ==============================
// API to access Azure Cloud Functions.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/profile_device.dart';
import 'package:app/utilities/api_monitor.dart';

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
    // TODO - uncomment line below and replace mock with real
    /* final response = await _follow(email, deviceId); */
    final response = await Future.delayed(Duration(seconds: 3), () => http.Response("", 200));
    if (!apiCallSuccess("follow($email, $deviceId)", response)) return null;
    return Profile("Bobby Boten", "bobby.boten@gmail.com", "054 753 2311", "bobby_boten2003");

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
    Uri.parse("https://arc-fun.azurewebsites.net/api/Follow"),
    body: jsonEncode(<String, dynamic>{
      "email": email,
      "deviceId": deviceId
    })
  );

  static Device id2device(String id) {
    if (id == "ARC-001") {
      return Device("ARC-001", Profile("Reem Kishinevsky", "reemkish@gmail.com", "054 642 1200", "stonewow1"));
    } else
    if (id == "DEV::1a2b3c") {
      return Device('1', Profile("David Molina", "davidm@gmail.com", "054-123-4567", "pas2"));
    } else {
      return Device("2", Profile("Yuval Cohen", "yuvalc@walla.co.il", "054-631-1200", "pas1"));
    }
  }
}

