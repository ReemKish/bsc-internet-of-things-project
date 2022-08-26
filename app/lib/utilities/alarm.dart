import 'package:audioplayers/audioplayers.dart';

class Alarm {
  static final AudioPlayer _alarmPlayer = AudioPlayer();

  static Future<void> sound() async {
    await _alarmPlayer.play(AssetSource("sounds/alarm.wav"));
  }

  static Future<void> mute() async {
    await _alarmPlayer.stop();
  }
}
