import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import 'gemini_provider.dart';
import 'preferences_provider.dart';

final chatHistoryProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<List<ChatMessage>> {
  late final GeminiService _service;

  @override
  List<ChatMessage> build() {
    _service = ref.read(geminiServiceProvider);
    return [];
  }

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
