// ===== profile_device.dart ==============================
// Containcs Profile and DeviceEntry models.

class Profile {
  String name;
  String email;
  String phoneNumber;
  String? password;
  Profile({
    this.name = "",
    this.email = "",
    this.phoneNumber = "",
    this.password,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class DeviceEntry {
  String deviceId;
  Profile holder;
  bool notify;
  bool emergenecy;
  DeviceEntry(this.deviceId, this.holder, {this.notify = true, this.emergenecy = false});
}
