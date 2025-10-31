import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class AudioCacheService {
  static final AudioCacheService _instance = AudioCacheService._internal();
  factory AudioCacheService() => _instance;
  AudioCacheService._internal();

  final Map<String, String> _cachedFiles = {};
  final Map<String, AudioPlayer> _players = {};

  Future<AudioPlayer> getAudioPlayer(String url) async {

    if (_players.containsKey(url)) {
      return _players[url]!;
    }

    final player = AudioPlayer();
    String audioPath = await _getCachedPath(url);
    
    if (audioPath.isEmpty) {
      audioPath = await _downloadAndCache(url);
    }
    
    await player.setFilePath(audioPath);
    _players[url] = player;

    return player;
  }

  Future<String> _getCachedPath(String url) async {
    if (_cachedFiles.containsKey(url)) {
      return _cachedFiles[url]!;
    }
    
    final cacheDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;
    final file = File('${cacheDir.path}/$fileName');
    
    if (await file.exists()) {
      _cachedFiles[url] = file.path;
      return file.path;
    }
    
    return '';
  }

  Future<String> _downloadAndCache(String url) async {
    final response = await http.get(Uri.parse(url));
    final cacheDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;
    final file = File('${cacheDir.path}/$fileName');
    
    await file.writeAsBytes(response.bodyBytes);
    _cachedFiles[url] = file.path;
    return file.path;
  }

  void dispose(String url) {
    _players[url]?.dispose();
    _players.remove(url);
  }
} 