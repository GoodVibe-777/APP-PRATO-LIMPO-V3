import '../../models/scan_result.dart';
import '../../models/user_restrictions.dart';
import '../../services/gemini_service.dart';

class AnalyzeLabelUseCase {
  AnalyzeLabelUseCase(this._service);

  final GeminiService _service;

  Future<ScanResult> call({
    required String texto,
    required UserRestrictions restricoes,
  }) {
    return _service.analisarRotulo(texto, restricoes);
  }
}
