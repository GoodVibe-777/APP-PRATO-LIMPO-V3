import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import 'gemini_provider.dart';
import 'preferences_provider.dart';

final chatHistoryProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(ref.read(geminiServiceProvider)),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._service) : super([]);

  final GeminiService _service;

  Future<void> enviarMensagem(String texto) async {
    final mensagemUsuario = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conteudo: texto,
      eDoUsuario: true,
      data: DateTime.now(),
    );
    state = [...state, mensagemUsuario];
    final resposta = await _service.enviarMensagem(texto);
    state = [...state, resposta];
  }
}

final chatDisponivelProvider = Provider<bool>((ref) {
  final isPro = ref.watch(planoProProvider);
  return isPro;
});
