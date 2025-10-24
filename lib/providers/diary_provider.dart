import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/diary_entry.dart';
import '../models/nutrition_macros.dart';
import '../services/diary_repository_service.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import 'gemini_provider.dart';
import 'speech_provider.dart';

final diaryRepositoryProvider = Provider<DiaryRepositoryService>((ref) {
  return DiaryRepositoryService();
});

final diarioEntriesProvider = StateNotifierProvider<DiaryNotifier, List<DiaryEntry>>(
  (ref) => DiaryNotifier(ref.read(diaryRepositoryProvider)),
);

class DiaryNotifier extends StateNotifier<List<DiaryEntry>> {
  DiaryNotifier(this._repository) : super(_repository.entries);

  final DiaryRepositoryService _repository;

  Future<void> adicionarEntrada(DiaryEntry entry) async {
    await _repository.saveEntry(entry);
    state = _repository.entries;
  }

  Future<void> removerEntrada(String id) async {
    await _repository.deleteEntry(id);
    state = _repository.entries;
  }
}

final speechToMacrosProvider = Provider<Future<NutritionMacros> Function(String)>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return (texto) async => gemini.interpretarMacrosDeTexto(texto);
});

final speechCaptureProvider = Provider<Future<String?> Function()>((ref) {
  final speech = ref.watch(speechServiceProvider);
  return () => speech.listenOnce();
});
