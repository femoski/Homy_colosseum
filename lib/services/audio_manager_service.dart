import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioManagerService extends GetxService {
  AudioPlayer? currentlyPlaying;
  String? currentPlayingUrl;

  Future<void> stopCurrentlyPlaying() async {
    if (currentlyPlaying != null && currentlyPlaying!.playing) {
      await currentlyPlaying!.pause();
      await currentlyPlaying!.seek(Duration.zero);
      currentlyPlaying = null;
      currentPlayingUrl = null;
    }
  }

  void setCurrentlyPlaying(AudioPlayer player) {
    if (currentlyPlaying != player) {
      currentlyPlaying = player;
    }
  }
} 