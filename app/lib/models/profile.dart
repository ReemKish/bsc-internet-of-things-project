// ===== profile.dart =====================================
// The Profile model represents a user profile (name, email, phone number and password).

class Profile {
  String name;
  String email;
  String phoneNumber;
  String? password;
  String? deviceId;
  Profile({
    this.name = "",
    this.email = "",
    this.phoneNumber = "",
    this.password,
    this.deviceId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      deviceId: json['device_id'],
    );
  }
}
