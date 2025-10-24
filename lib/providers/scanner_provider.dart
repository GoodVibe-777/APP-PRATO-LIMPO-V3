import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_result.dart';
import '../services/gemini_service.dart';
import '../services/ocr_service.dart';
import 'gemini_provider.dart';
import 'ocr_provider.dart';
import 'preferences_provider.dart';

final lastScanProvider = StateProvider<ScanResult?>((ref) => null);
final compareScanProvider = StateProvider<ScanResult?>((ref) => null);

final scannerControllerProvider = Provider<ScannerController>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  final ocr = ref.watch(ocrServiceProvider);
  final restricoes = ref.watch(restricoesProvider);
  return ScannerController(
    gemini: gemini,
    ocr: ocr,
    restricoes: restricoes,
    storeResult: (result) => ref.read(lastScanProvider.notifier).state = result,
    storeComparison: (result) =>
        ref.read(compareScanProvider.notifier).state = result,
  );
});

class ScannerController {
  ScannerController({
    required this.gemini,
    required this.ocr,
    required this.restricoes,
    required this.storeResult,
    required this.storeComparison,
  });

  final GeminiService gemini;
  final OcrService ocr;
  final dynamic restricoes;
  final void Function(ScanResult) storeResult;
  final void Function(ScanResult) storeComparison;

  Future<ScanResult?> analisarCamera({bool comparar = false}) async {
    final text = await ocr.scanFromCamera();
    if (text == null) return null;
    final result = await gemini.analisarRotulo(text, restricoes);
    if (comparar) {
      storeComparison(result);
    } else {
      storeResult(result);
    }
    return result;
  }

  Future<ScanResult?> analisarGaleria({bool comparar = false}) async {
    final text = await ocr.scanFromGallery();
    if (text == null) return null;
    final result = await gemini.analisarRotulo(text, restricoes);
    if (comparar) {
      storeComparison(result);
    } else {
      storeResult(result);
    }
    return result;
  }
}
