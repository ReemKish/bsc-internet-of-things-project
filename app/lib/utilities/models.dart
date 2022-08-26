// ===== models.dart ==============================
// Data models used throughout the app.

class Profile {
  String name;
  String email;
  String phoneNumber;
  String password;
  Profile(this.name, this.email, this.phoneNumber, this.password);
}

class Device {
  String id;
  Profile holder;
  bool notify;
  Device(this.id, this.holder, {this.notify = true});
}
