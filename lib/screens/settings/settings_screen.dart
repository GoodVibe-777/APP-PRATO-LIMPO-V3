import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_goals.dart';
import '../../models/user_restrictions.dart';
import '../../providers/preferences_provider.dart';
import '../../services/preferences_service.dart';
import '../../utils/paywall.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController caloriasController;
  late TextEditingController proteinasController;
  late TextEditingController carboidratosController;
  late TextEditingController gordurasController;
  late TextEditingController restricoesController;
  final monitores = ['Glúten', 'Lactose', 'Sódio Alto'];
  final selecionados = <String>{};

  @override
  void initState() {
    super.initState();
    final metas = ref.read(metasProvider);
    caloriasController = TextEditingController(text: metas.calorias.toString());
    proteinasController = TextEditingController(text: metas.proteinas.toString());
    carboidratosController =
        TextEditingController(text: metas.carboidratos.toString());
    gordurasController = TextEditingController(text: metas.gorduras.toString());
    final restricoes = ref.read(restricoesProvider);
    selecionados.addAll(restricoes.monitores);
    restricoesController = TextEditingController(text: restricoes.custom);
  }

  @override
  void dispose() {
    caloriasController.dispose();
    proteinasController.dispose();
    carboidratosController.dispose();
    gordurasController.dispose();
    restricoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesServiceProvider);
    final isPro = ref.watch(planoProProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              titulo: 'Minhas Metas',
              descricao:
                  'Personalize suas metas diárias de calorias e macronutrientes.',
              child: Column(
                children: [
                  _GoalField(controller: caloriasController, label: 'Calorias (kcal)'),
                  _GoalField(controller: proteinasController, label: 'Proteínas (g)'),
                  _GoalField(
                      controller: carboidratosController, label: 'Carboidratos (g)'),
                  _GoalField(controller: gordurasController, label: 'Gorduras (g)'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final goals = UserGoals(
                        calorias: double.tryParse(caloriasController.text) ?? 0,
                        proteinas: double.tryParse(proteinasController.text) ?? 0,
                        carboidratos:
                            double.tryParse(carboidratosController.text) ?? 0,
                        gorduras: double.tryParse(gordurasController.text) ?? 0,
                      );
                      await preferences.salvarMetas(goals);
                      ref.read(metasProvider.notifier).state = goals;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Metas atualizadas!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Salvar metas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              titulo: 'Meus Monitores',
              descricao:
                  'Controle ingredientes que deseja evitar nas análises e no diário.',
              badge: isPro ? null : 'PRO',
              child: isPro
                  ? Column(
                      children: [
                        for (final item in monitores)
                          CheckboxListTile(
                            value: selecionados.contains(item),
                            title: Text(item),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selecionados.add(item);
                                } else {
                                  selecionados.remove(item);
                                }
                              });
                            },
                          ),
                        TextField(
                          controller: restricoesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Restrições personalizadas',
                            hintText: 'Ex.: evitar açúcar refinado, bebidas energéticas...'
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            final restrictions = UserRestrictions(
                              monitores: selecionados.toList(),
                              custom: restricoesController.text,
                            );
                            await preferences.salvarRestricoes(restrictions);
                            ref.read(restricoesProvider.notifier).state = restrictions;
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Monitores atualizados!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Salvar monitores'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text(
                          'Monitore glúten, lactose e outros ingredientes com o plano PRO.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => mostrarPaywall(context),
                          child: const Text('Conhecer benefícios PRO'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              titulo: 'Conta',
              descricao: 'Informações da sua assinatura.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        'Plano atual: ${isPro ? 'PRO' : 'Free'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final desejaAlternar = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Gerenciar Assinatura'),
                          content: Text(isPro
                              ? 'Você já é PRO. Deseja voltar ao plano Free para testar o paywall?'
                              : 'Experimente o plano PRO para liberar todos os recursos.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(isPro ? 'Voltar ao Free' : 'Assinar PRO'),
                            ),
                          ],
                        ),
                      );
                      if (desejaAlternar == true) {
                        await preferences.alternarPlano();
                        ref.read(planoProProvider.notifier).state = !isPro;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Plano atualizado para ' + (!isPro ? 'PRO' : 'Free'))),
                          );
                        }
                      }
                    },
                    child: const Text('Gerenciar Assinatura'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.titulo,
    required this.descricao,
    required this.child,
    this.badge,
  });

  final String titulo;
  final String descricao;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(descricao, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _GoalField extends StatelessWidget {
  const _GoalField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
