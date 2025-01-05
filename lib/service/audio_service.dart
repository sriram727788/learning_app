import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final Map<String, AudioPlayer> _players = {};

  static AudioPlayer createPlayer(String playerId) {
    if (_players.containsKey(playerId)) {
      return _players[playerId]!;
    }
    final player = AudioPlayer(playerId: playerId);
    _players[playerId] = player;
    return player;
  }

  static AudioPlayer? _getPlayer(String playerId) {
    return _players[playerId];
  }

  static Future<void> playAudio(
    String playerId,
    String audioPath,
    double volume,
    ReleaseMode releaseMode,
  ) async {
    final audioPlayer = _getPlayer(playerId) ?? createPlayer(playerId);
    await audioPlayer.setReleaseMode(releaseMode);
    await audioPlayer.play(AssetSource(audioPath), volume: volume);
  }

  static Future<void> stopAudio(String playerId) async {
    final audioPlayer = _getPlayer(playerId);
    if (audioPlayer != null) {
      await audioPlayer.stop();
    }
  }

  static Future<void> pauseAudio(String playerId) async {
    final audioPlayer = _getPlayer(playerId);
    if (audioPlayer != null) {
      await audioPlayer.pause();
    }
  }

  static Future<void> resumeAudio(String playerId) async {
    final audioPlayer = _getPlayer(playerId);
    if (audioPlayer != null) {
      await audioPlayer.resume();
    }
  }

  static Future<void> disposeAudio(String playerId) async {
    final audioPlayer = _getPlayer(playerId);
    if (audioPlayer != null) {
      await audioPlayer.dispose();
      _players.remove(playerId);
    }
  }

  static Future<void> disposeAllPlayers() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
