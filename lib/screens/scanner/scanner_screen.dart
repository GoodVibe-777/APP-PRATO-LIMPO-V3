import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/scan_result.dart';
import '../../utils/dialogs.dart';
import '../../utils/paywall.dart';
import '../../utils/verdict_color.dart';
import '../../models/nutrition_macros.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/scanner_provider.dart';
import '../../providers/diary_provider.dart';
import '../../models/diary_entry.dart';
import '../../widgets/html_widget.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastScanProvider);
    final compare = ref.watch(compareScanProvider);
    final isPro = ref.watch(planoProProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Scanner'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prato Limpo — Entenda o que você come',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escaneie rótulos ou fotos de ingredientes e receba análise personalizada.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _requestPermissions();
                            final controller =
                                ref.read(scannerControllerProvider);
                            // ignore: use_build_context_synchronously
                            await mostrarCarregamento(
                              context,
                              controller.analisarCamera(),
                              mensagem: 'Lendo rótulo...',
                            );
                          },
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Usar câmera'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _requestPermissions();
                            final controller =
                                ref.read(scannerControllerProvider);
                            // ignore: use_build_context_synchronously
                            await mostrarCarregamento(
                              context,
                              controller.analisarGaleria(),
                              mensagem: 'Interpretando imagem...',
                            );
                          },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galeria'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!isPro)
                    Card(
                      color: const Color(0xFFE8F5E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium,
                            color: Colors.green),
                        title: const Text(
                            'Comparar rótulos e salvar no diário são recursos PRO.'),
                        trailing: TextButton(
                          onPressed: () => mostrarPaywall(context),
                          child: const Text('Saiba mais'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (result != null) ...[
              _ScannerResultCard(
                result: result,
                onAddToDiary: isPro
                    ? () async {
                        await ref.read(diarioEntriesProvider.notifier).adicionarEntrada(
                          DiaryEntry(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            nome: result.nomeProduto,
                            macros: result.macros,
                            origem: 'scanner',
                            data: DateTime.now(),
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Adicionado ao diário com sucesso!'),
                            ),
                          );
                        }
                      }
                    : () => mostrarPaywall(context),
              ),
              const SizedBox(height: 16),
            ],
            if (isPro && result != null)
              FilledButton.icon(
                onPressed: () async {
                  await _requestPermissions();
                  final controller = ref.read(scannerControllerProvider);
                  // ignore: use_build_context_synchronously
                  await mostrarCarregamento(
                    context,
                    controller.analisarCamera(comparar: true),
                    mensagem: 'Escaneando para comparar...',
                  );
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Comparar com outro'),
              ),
            if (compare != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child:
                    _ComparisonCard(baseResult: result, compareResult: compare),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScannerResultCard extends StatelessWidget {
  const _ScannerResultCard({
    required this.result,
    this.onAddToDiary,
  });

  final ScanResult result;
  final VoidCallback? onAddToDiary;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: corParaVeredito(result.veredito), width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x11000000),
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.nomeProduto,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(result.veredito.toUpperCase()),
            backgroundColor: corParaVeredito(result.veredito).withOpacity(0.15),
            labelStyle: TextStyle(
              color: corParaVeredito(result.veredito),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _MacrosRow(macros: result.macros),
          const SizedBox(height: 16),
          const Text(
            'Resumo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          HtmlWidget(result.resumoHtml),
          const SizedBox(height: 12),
          const Text(
            'Dica saudável',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          HtmlWidget(result.dicaHtml),
          const SizedBox(height: 16),
          if (onAddToDiary != null)
            ElevatedButton.icon(
              onPressed: onAddToDiary,
              icon: const Icon(Icons.playlist_add),
              label: const Text('Adicionar ao Diário'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
        ],
      ),
    );
  }
}

class _MacrosRow extends StatelessWidget {
  const _MacrosRow({required this.macros});

  final NutritionMacros macros;

  @override
  Widget build(BuildContext context) {
    final style =
        Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MacroTile(label: 'Calorias', value: macros.calorias, style: style),
        _MacroTile(label: 'Proteínas', value: macros.proteinas, style: style),
        _MacroTile(label: 'Carboidratos', value: macros.carboidratos, style: style),
        _MacroTile(label: 'Gorduras', value: macros.gorduras, style: style),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.value,
    this.style,
  });

  final String label;
  final double value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(0)}g', style: style),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.baseResult,
    required this.compareResult,
  });

  final ScanResult? baseResult;
  final ScanResult compareResult;

  @override
  Widget build(BuildContext context) {
    if (baseResult == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparação rápida',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ComparisonRow(
            label: 'Produto',
            a: baseResult!.nomeProduto,
            b: compareResult.nomeProduto,
          ),
          _ComparisonRow(
            label: 'Veredito',
            a: baseResult!.veredito,
            b: compareResult.veredito,
          ),
          _ComparisonRow(
            label: 'Calorias',
            a: baseResult!.macros.calorias.toStringAsFixed(0),
            b: compareResult.macros.calorias.toStringAsFixed(0),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.a,
    required this.b,
  });

  final String label;
  final String a;
  final String b;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    )),
                const SizedBox(height: 4),
                Text(a, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.sync_alt, color: Colors.green),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    )),
                const SizedBox(height: 4),
                Text(b, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
