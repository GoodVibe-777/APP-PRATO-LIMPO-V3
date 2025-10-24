import 'package:flutter/material.dart';

Future<void> mostrarPaywall(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Desbloqueie o Prato Limpo PRO',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            '• Comparar rótulos ilimitados\n• Diário alimentar completo\n• Nutri-IA sem limites',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Quero ser PRO'),
          ),
        ],
      ),
    ),
  );
}
