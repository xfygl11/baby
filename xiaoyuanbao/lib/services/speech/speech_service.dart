import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  String _lastRecognizedText = '';
  double _confidence = 0.0;
  String? _errorMessage;

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  String get lastRecognizedText => _lastRecognizedText;
  double get confidence => _confidence;
  String? get errorMessage => _errorMessage;

  Future<bool> initialize() async {
    final available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    return available;
  }

  Future<void> startListening({
    ValueChanged<String>? onResult,
    ValueChanged<bool>? onListeningChanged,
  }) async {
    if (!_isListening) {
      _recognizedText = '';
      _errorMessage = null;
      notifyListeners();

      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _lastRecognizedText = result.recognizedWords;
          _confidence = result.confidence;
          onResult?.call(_recognizedText);
          notifyListeners();
        },
        listenMode: ListenMode.dictation,
        localeId: 'zh_CN',
        partialResults: true,
      );

      _isListening = true;
      onListeningChanged?.call(true);
      notifyListeners();
    }
  }

  Future<void> stopListening({
    ValueChanged<String>? onResult,
    ValueChanged<bool>? onListeningChanged,
  }) async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      onListeningChanged?.call(false);
      onResult?.call(_recognizedText);
      notifyListeners();
    }
  }

  void cancelListening() {
    if (_isListening) {
      _speech.cancel();
      _isListening = false;
      _recognizedText = '';
      notifyListeners();
    }
  }

  void clearText() {
    _recognizedText = '';
    notifyListeners();
  }

  void _onStatus(String status) {
    if (status == 'listening') {
      _isListening = true;
    } else if (status == 'notListening') {
      _isListening = false;
    }
    notifyListeners();
  }

  void _onError(SpeechRecognitionError error) {
    _errorMessage = error.errorMsg;
    _isListening = false;
    notifyListeners();
  }

  bool get isAvailable => _speech.isAvailable;

  bool get isNotAvailable => _speech.isNotAvailable;

  Future<void> dispose() async {
    cancelListening();
    _speech.cancel();
  }
}