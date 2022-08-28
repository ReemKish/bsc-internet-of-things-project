// ===== login_data.dart ==================================
// The LoginData model represents a response from the server for a login request,
// it contains the user's profile as well as a list of followed devices.

import 'profile.dart';


class LoginData {
  final Profile profile;
  final List<Profile>? following;
  final List<Profile>? followedBy;
  final String? deviceId; 
  LoginData({
    required this.profile,
    this.following,
    this.followedBy,
    this.deviceId,
  });


  factory LoginData.fromJson(Map<String, dynamic> json) {
    List<Profile>? following;
    List<Profile>? followedBy;
    if (json['following'] != null) {
      following = <Profile>[];
      json['following'].forEach((v) {
        following!.add(Profile.fromJson(v));
      });
    }
    if (json['followed_by'] != null) {
      followedBy = <Profile>[];
      json['followed_by'].forEach((v) {
        followedBy!.add(Profile.fromJson(v));
      });
    }
    final profile = Profile.fromJson(json);
    return LoginData(
      profile: profile,
      following: following,
      followedBy: followedBy,
      deviceId: json['device_id'],
    );
  }
}
