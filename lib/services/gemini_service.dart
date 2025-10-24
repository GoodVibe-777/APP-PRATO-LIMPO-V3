import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/chat_message.dart';
import '../models/nutrition_macros.dart';
import '../models/scan_result.dart';
import '../models/user_restrictions.dart';

class GeminiService {
  GeminiService()
      : _apiKey = Platform.environment['GEMINI_API_KEY'] ??
            const String.fromEnvironment('GEMINI_API_KEY');

  final String? _apiKey;
  GenerativeModel? _cachedModel;

  GenerativeModel? get _model {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return null;
    }
    _cachedModel ??= GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey!,
    );
    return _cachedModel;
  }

  Future<ScanResult> analisarRotulo(
      String texto, UserRestrictions restricoes) async {
    final prompt = '''Você é uma nutricionista brasileira.
Analise o rótulo a seguir considerando as restrições: ${restricoes.monitores.join(', ')} ${restricoes.custom}.
Responda estritamente em JSON com o formato:
{
  "name": string,
  "verdict": "bom" | "atenção" | "alerta",
  "macros": {"calorias": number, "proteínas": number, "carboidratos": number, "gorduras": number},
  "summaryHtml": string,
  "tipHtml": string
}

Texto:
$texto
''';
    try {
      final model = _model;
      if (model == null) {
        throw const FormatException('sem chave');
      }
      final response = await model.generateContent([Content.text(prompt)]);
      final raw = response.text ?? '';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ScanResult.fromMap(map);
    } catch (_) {
      return const ScanResult(
        nomeProduto: 'Amostra de Granola',
        veredito: 'atenção',
        macros: NutritionMacros(
          calorias: 180,
          proteinas: 5,
          carboidratos: 22,
          gorduras: 7,
        ),
        resumoHtml:
            '<h3>O que encontramos</h3><ul><li>Fonte razoável de fibras</li><li>Açúcar adicionado entre os primeiros ingredientes</li></ul>',
        dicaHtml:
            '<p>Prefira versões sem açúcar adicionado ou faça uma mistura caseira com aveia, castanhas e sementes.</p>',
      );
    }
  }

  Future<ChatMessage> enviarMensagem(String mensagem) async {
    final prompt =
        'Você é a Nutri-IA 🥑✨, uma nutricionista amigável. Responda em português brasileiro com tom acolhedor.';
    try {
      final model = _model;
      if (model == null) throw const FormatException('sem chave');
      final response = await model.generateContent([
        Content.text(prompt),
        Content.text('Pergunta: $mensagem'),
      ]);
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conteudo: response.text ??
            'Estou aqui para ajudar! Experimente combinar proteínas magras com vegetais coloridos na próxima refeição.',
        eDoUsuario: false,
        data: DateTime.now(),
      );
    } catch (_) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conteudo:
            'Mesmo offline posso sugerir: inclua uma porção de legumes crus ou cozidos e uma fonte de proteína magra no seu próximo prato.',
        eDoUsuario: false,
        data: DateTime.now(),
      );
    }
  }

  NutritionMacros interpretarMacrosDeTexto(String fala) {
    final lower = fala.toLowerCase();
    double calorias = 0;
    if (lower.contains('banana')) calorias += 90;
    if (lower.contains('ovo')) calorias += 70;
    if (lower.contains('aveia')) calorias += 150;
    if (lower.contains('salada')) calorias += 40;
    return NutritionMacros(
      calorias: calorias == 0 ? 200 : calorias,
      proteinas: lower.contains('ovo') ? 6 : 10,
      carboidratos: lower.contains('banana') ? 23 : 20,
      gorduras: lower.contains('abacate') ? 12 : 8,
    );
  }
}
