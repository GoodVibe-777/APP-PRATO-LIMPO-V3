import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/diary_entry.dart';
import '../../models/nutrition_macros.dart';
import '../../providers/diary_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/scanner_provider.dart';
import '../../utils/paywall.dart';
import '../settings/settings_screen.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(planoProProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isPro ? _ProDiaryView(ref: ref) : _FreeDiaryView(),
      ),
      floatingActionButton: isPro
          ? FloatingActionButton.extended(
              onPressed: () => _adicionarPorVoz(context, ref),
              icon: const Icon(Icons.mic_none),
              label: const Text('Adicionar por voz'),
            )
          : FloatingActionButton.extended(
              onPressed: () => mostrarPaywall(context),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Somente PRO'),
            ),
    );
  }

  Future<void> _adicionarPorVoz(BuildContext context, WidgetRef ref) async {
    final capturar = ref.read(speechCaptureProvider);
    final texto = await capturar();
    if (texto == null || texto.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível ouvir nada.')),
        );
      }
      return;
    }
    final interpretar = ref.read(speechToMacrosProvider);
    final macros = await interpretar(texto);
    final notifier = ref.read(diarioEntriesProvider.notifier);
    await notifier.adicionarEntrada(
      DiaryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: texto,
        macros: macros,
        origem: 'voz',
        data: DateTime.now(),
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada adicionada por voz!')),
      );
    }
  }
}

class _ProDiaryView extends ConsumerWidget {
  const _ProDiaryView({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final entries = ref.watch(diarioEntriesProvider);
    final metas = ref.watch(metasProvider);
    final hoje = DateTime.now();
    final diarioHoje = entries
        .where((e) => e.data.year == hoje.year && e.data.month == hoje.month && e.data.day == hoje.day)
        .toList();
    final totais = _somarMacros(diarioHoje);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Dashboard(metas: metas.toMacros(), totais: totais),
          const SizedBox(height: 20),
          if (ref.watch(lastScanProvider) != null)
            FilledButton.icon(
              onPressed: () async {
                final last = ref.read(lastScanProvider);
                if (last == null) return;
                final notifier = ref.read(diarioEntriesProvider.notifier);
                await notifier.adicionarEntrada(
                  DiaryEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nome: last.nomeProduto,
                    macros: last.macros,
                    origem: 'scanner',
                    data: DateTime.now(),
                  ),
                );
              },
              icon: const Icon(Icons.save_alt),
              label: const Text('Adicionar última análise'),
            ),
          const SizedBox(height: 12),
          if (diarioHoje.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Nenhuma refeição registrada hoje. Que tal adicionar a primeira?',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...diarioHoje.map((entry) => _DiaryEntryTile(entry: entry)),
        ],
      ),
    );
  }

  NutritionMacros _somarMacros(List<DiaryEntry> entries) {
    double calorias = 0;
    double proteinas = 0;
    double carboidratos = 0;
    double gorduras = 0;
    for (final entry in entries) {
      calorias += entry.macros.calorias;
      proteinas += entry.macros.proteinas;
      carboidratos += entry.macros.carboidratos;
      gorduras += entry.macros.gorduras;
    }
    return NutritionMacros(
      calorias: calorias,
      proteinas: proteinas,
      carboidratos: carboidratos,
      gorduras: gorduras,
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.metas, required this.totais});

  final NutritionMacros metas;
  final NutritionMacros totais;

  double _progress(double atual, double meta) {
    if (meta <= 0) return 0;
    return (atual / meta).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do dia (${DateFormat('dd/MM').format(DateTime.now())})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('Calorias: ${totais.calorias.toStringAsFixed(0)} / ${metas.calorias.toStringAsFixed(0)} kcal'),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress(totais.calorias, metas.calorias),
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Colors.green),
          ),
          const SizedBox(height: 20),
          _MacroProgress(
            label: 'Proteínas',
            atual: totais.proteinas,
            meta: metas.proteinas,
            cor: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _MacroProgress(
            label: 'Carboidratos',
            atual: totais.carboidratos,
            meta: metas.carboidratos,
            cor: Colors.orange.shade400,
          ),
          const SizedBox(height: 12),
          _MacroProgress(
            label: 'Gorduras',
            atual: totais.gorduras,
            meta: metas.gorduras,
            cor: Colors.red.shade300,
          ),
        ],
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  const _MacroProgress({
    required this.label,
    required this.atual,
    required this.meta,
    required this.cor,
  });

  final String label;
  final double atual;
  final double meta;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${atual.toStringAsFixed(0)}g / ${meta.toStringAsFixed(0)}g'),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: meta == 0 ? 0 : (atual / meta).clamp(0, 1),
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(cor),
          ),
        ),
      ],
    );
  }
}

class _DiaryEntryTile extends ConsumerWidget {
  const _DiaryEntryTile({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.restaurant_menu, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calorias ${entry.macros.calorias.toStringAsFixed(0)} kcal · ${entry.origem}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(diarioEntriesProvider.notifier).removerEntrada(entry.id);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _FreeDiaryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'O Diário Alimentar é exclusivo para assinantes PRO.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => mostrarPaywall(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Conhecer plano PRO'),
          ),
        ],
      ),
    );
  }
}
