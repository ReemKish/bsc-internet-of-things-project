// ===== structures.dart ==============================
// Data structures used throughout the app.

class Profile {
  String name;
  String email;
  String phoneNumber;
  Profile(this.name, this.email, this.phoneNumber);
}

class Device {
  int id;
  Profile holder;
  bool notify;
  Device(this.id, this.holder, {this.notify = true});
}
