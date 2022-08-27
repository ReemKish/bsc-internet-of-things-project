// ===== profile_device.dart ==============================
// Containcs Profile and Device models.

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

class Device {
  String id;
  Profile holder;
  bool notify;
  Device(this.id, this.holder, {this.notify = true});
}
