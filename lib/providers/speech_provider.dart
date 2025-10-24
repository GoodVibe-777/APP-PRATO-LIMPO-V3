import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/speech_service.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(service.dispose);
  return service;
});
