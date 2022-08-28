// ===== device_entry.dart ================================
// The DeviceEntry represents an entry in the device list.

import 'profile.dart';

class DeviceEntry {
  Profile holder;
  String deviceId;
  bool notify;
  bool emergenecy;
  DeviceEntry(this.deviceId, this.holder, {this.notify = true, this.emergenecy = false});
}
