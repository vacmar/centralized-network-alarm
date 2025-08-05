import 'package:audioplayers/audioplayers.dart';

class AlertSoundPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAlertSound() async {
    await _audioPlayer.play(AssetSource('alert.mp3'));
  }
}
