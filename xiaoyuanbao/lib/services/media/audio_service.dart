import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/drift/daos/audio_repository.dart';

class AudioService {
  final AudioRepository _audioRepository;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  ValueChanged<int>? onRecordingProgress;

  AudioService(this._audioRepository);

  Future<void> initRecorder() async {
    try {
      await _recorder.openRecorder();
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    } catch (e) {
      throw Exception('录音初始化失败: $e');
    }
  }

  Future<void> initPlayer() async {
    try {
      await _player.openPlayer();
    } catch (e) {
      throw Exception('播放器初始化失败: $e');
    }
  }

  Future<void> startRecording(String babyId) async {
    try {
      await initRecorder();

      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(p.join(appDir.path, 'audio'));
      if (!audioDir.existsSync()) {
        audioDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = p.join(audioDir.path, '${timestamp}.m4a');

      await _recorder.startRecorder(
        toFile: _currentRecordingPath!,
        codec: Codec.aacMP4,
      );

      _recordingSeconds = 0;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingSeconds++;
        onRecordingProgress?.call(_recordingSeconds);
      });
    } catch (e) {
      throw Exception('开始录音失败: $e');
    }
  }

  Future<String?> stopRecording(String babyId) async {
    try {
      final duration = await _recorder.stopRecorder();
      _recordingTimer?.cancel();

      if (_currentRecordingPath == null) {
        return null;
      }

      final file = File(_currentRecordingPath!);
      if (!file.existsSync()) {
        return null;
      }

      final sizeMb = file.lengthSync() / (1024 * 1024);
      final durationSeconds = duration?.inSeconds ?? _recordingSeconds;

      final id = await _audioRepository.addAudio(
        babyId: babyId,
        filePath: _currentRecordingPath!,
        recordDate: DateTime.now(),
        durationSeconds: durationSeconds,
        sizeMb: sizeMb,
      );

      _currentRecordingPath = null;
      _recordingSeconds = 0;

      return id;
    } catch (e) {
      return null;
    } finally {
      await _recorder.closeRecorder();
    }
  }

  Future<void> playAudio(String filePath) async {
    try {
      await initPlayer();
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.aacMP4,
      );
    } catch (e) {
      throw Exception('播放音频失败: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _player.stopPlayer();
      await _player.closePlayer();
    } catch (_) {}
  }

  bool get isRecording => _recorder.isRecording;

  int get recordingSeconds => _recordingSeconds;

  Future<void> deleteAudio(String id) async {
    final audio = await _audioRepository.getAudioById(id);
    if (audio != null) {
      if (audio.filePath.isNotEmpty) {
        final file = File(audio.filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      await _audioRepository.deleteAudio(id);
    }
  }

  Future<void> toggleFavorite(String id) async {
    await _audioRepository.toggleFavorite(id);
  }

  Future<List<dynamic>> getAudios(String babyId) async {
    return await _audioRepository.getAudiosByBabyId(babyId);
  }

  Future<List<dynamic>> getFavoriteAudios(String babyId) async {
    return await _audioRepository.getFavoriteAudios(babyId);
  }

  Future<int> getAudioCount(String babyId) async {
    return await _audioRepository.getAudioCount(babyId);
  }

  Future<double> getTotalDurationMinutes(String babyId) async {
    return await _audioRepository.getTotalDurationMinutes(babyId);
  }

  Future<void> dispose() async {
    _recordingTimer?.cancel();
    try {
      await _recorder.closeRecorder();
    } catch (_) {}
    try {
      await _player.closePlayer();
    } catch (_) {}
  }
}