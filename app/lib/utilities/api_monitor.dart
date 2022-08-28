// ===== api_monitor.dart =================================
// useful utillity functions to monitor api calls.

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

bool apiCallSuccess(String func, Response response) {
  debugPrint(response.statusCode == 200 ?
    "$func - success" :
    "$func - failed with status ${response.statusCode}");
  debugPrint("Recieved headers: ${response.headers}");
  return response.statusCode == 200;
}
