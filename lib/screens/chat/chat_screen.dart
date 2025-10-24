import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chat_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../utils/paywall.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  static const _sugestoes = [
    'Sugestão de pré-treino rico em proteínas',
    'Ideia de almoço leve com salada',
    'Refeição com proteína vegetal',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(planoProProvider);

    if (!isPro) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nutri-IA')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.green, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Converse com a Nutri-IA ao se tornar PRO.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => mostrarPaywall(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Desbloquear Nutri-IA'),
              ),
            ],
          ),
        ),
      );
    }

    final mensagens = ref.watch(chatHistoryProvider);
    final controladorTexto = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutri-IA 🥑✨'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final mensagem = mensagens[index];
                final alinhamento =
                    mensagem.eDoUsuario ? Alignment.centerRight : Alignment.centerLeft;
                final cor = mensagem.eDoUsuario
                    ? Colors.green.shade400
                    : Colors.white;
                final textoCor = mensagem.eDoUsuario ? Colors.white : Colors.black87;
                return Align(
                  alignment: alinhamento,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: mensagem.eDoUsuario
                          ? null
                          : const [
                              BoxShadow(
                                blurRadius: 10,
                                color: Color(0x14000000),
                                offset: Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Text(
                      mensagem.conteudo,
                      style: TextStyle(color: textoCor),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, index) {
                final sugestao = _sugestoes[index];
                return ActionChip(
                  label: Text(sugestao),
                  avatar: const Icon(Icons.flash_on, size: 18, color: Colors.green),
                  onPressed: () => _enviarMensagem(ref, sugestao),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: _sugestoes.length,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controladorTexto,
                    decoration: const InputDecoration(
                      hintText: 'Escreva sua pergunta...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final texto = controladorTexto.text.trim();
                    if (texto.isEmpty) return;
                    controladorTexto.clear();
                    _enviarMensagem(ref, texto);
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _enviarMensagem(WidgetRef ref, String texto) {
    ref.read(chatHistoryProvider.notifier).enviarMensagem(texto);
  }
}
