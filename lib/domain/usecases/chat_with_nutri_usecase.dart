import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';

class ChatWithNutriUseCase {
  ChatWithNutriUseCase(this._service);

  final GeminiService _service;

  Future<ChatMessage> call(String pergunta) {
    return _service.enviarMensagem(pergunta);
  }
}
