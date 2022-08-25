import 'dart:convert';

import 'package:http/http.dart' as http;

class NotificationHub {
  static const name = "arc-notification-hub";
  static const namespace = "arc-notification-hub-namespace";
  static const sasToken = "SharedAccessSignature sr=https%3A%2F%2Farc-notification-hub-namespace.servicebus.windows.net%2Farc-notification-hub&sig=%2BEIP/7sLxujF3Ns5T0QamCKmiN%2BZ1IU4xAlcoTIg2Io%3D&se=1661441599&skn=DefaultFullSharedAccessSignature";
  static final headers = {"Content-Type": "application/json", "Authorization": sasToken};
  /* static const emulatorGcm = "dTH7TAklTFmFP9clT8WebB:APA91bGPDmi9tnTwd9Pnhb1HCljIuT_6BSxpxyR5y8Dta2z1U1SXCmbf2p51l3SyekKW8El7XE8QsMYwLJj67JmEQCwHM5nv6TdJfW-BRP3SmKzZHBdutEznA28B0mG6_2-SgfD3DM5o"; */
  /* static const phoneGcm = "eDU2WBQoR1yK1h2p-K9rGb:APA91bE4WLZO5bHgLMsg5R_aNwVkeIMZ2iLc-7Ce9mQJtciJ90zEoj98hQxLkml-piao8OkMoUcmZN_ZRbQVVpUNMs3GQLm4-n3y3oUyzLdaPlHVpmG98uhx4Wu30BwAZ46EZgVfI6nP"; */
static Future<http.Response> registerDevice(String id, String gcmToken) async {
    return http.put(
      Uri.parse("https://$namespace.servicebus.windows.net/$name/installations/$id?api-version=2015-01"),
      headers: headers,
      body: jsonEncode(<String, String>{
        "installationId": id,
        "platform": "gcm",
        "pushChannel": gcmToken,
      })
    );
  }
}
