import 'package:flutter/material.dart';

Future<T?> mostrarCarregamento<T>(BuildContext context, Future<T> futuro,
    {String mensagem = 'Processando...'}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 16),
            Text(
              mensagem,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );

  try {
    final resultado = await futuro;
    if (context.mounted) Navigator.of(context).pop();
    return resultado;
  } catch (e) {
    if (context.mounted) Navigator.of(context).pop();
    rethrow;
  }
}
