import 'package:audioplayers/audioplayers.dart';

/// Lightweight sound-effect player. Fails silently so audio issues
/// never crash the game.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool enabled = true;

  Future<void> playBumperHit() => _play('bumper_hit.mp3');

  Future<void> playTargetClear() => _play('target_clear.mp3');

  Future<void> playFlipperHit() => _play('flipper_hit.mp3');

  Future<void> playLaunch() => _play('launch.mp3');

  Future<void> playBallLost() => _play('ball_lost.mp3');

  Future<void> playLevelComplete() => _play('level_complete.mp3');

  Future<void> playGameOver() => _play('game_over.mp3');

  Future<void> _play(String file) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/$file'));
    } catch (_) {
      // Swallow errors -- sound must never break the game.
    }
  }

  void dispose() {
    _player.dispose();
  }
}
