// ===== cloud_services.dart ==============================
// API to access Azure Cloud Functions.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/profile_device.dart';

class CloudService {
  static const namespace = "arc-fun";

  static Future<http.Response> signUp(String name, String phoneNumber, String email, String password) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/SignUp"),
    body: jsonEncode(<String, dynamic>{
      "name": name,
      "phoneNumber": phoneNumber,
      "email": email,
      "password": password
    })
  );

  static Future<http.Response> logIn(String name, String phoneNumber, String email, String password) async => http.post(
    Uri.parse("https://$namespace.azurewebsites.net/api/SignUp"),
    body: jsonEncode(<String, dynamic>{
      "name": name,
      "phoneNumber": phoneNumber,
      "email": email,
      "password": password
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

