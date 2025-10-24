import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ocr_service.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});
