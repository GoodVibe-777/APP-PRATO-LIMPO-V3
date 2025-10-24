import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  Future<bool> initialize() => _speech.initialize(
        onStatus: (status) {},
        onError: (error) {},
      );

  Future<String?> listenOnce() async {
    final available = await initialize();
    if (!available) return null;
    _speech.listen(onResult: (value) {});
    await Future.delayed(const Duration(seconds: 4));
    await _speech.stop();
    return _speech.lastRecognizedWords;
  }

  void dispose() {
    _speech.stop();
  }
}
