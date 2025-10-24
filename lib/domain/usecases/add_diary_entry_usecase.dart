import 'package:uuid/uuid.dart';

import '../../models/diary_entry.dart';
import '../../models/nutrition_macros.dart';
import '../../services/diary_repository_service.dart';

class AddDiaryEntryUseCase {
  AddDiaryEntryUseCase(this._repository);

  final DiaryRepositoryService _repository;
  final _uuid = const Uuid();

  Future<void> call({
    required String titulo,
    required NutritionMacros macros,
    String origem = 'manual',
  }) async {
    final entry = DiaryEntry(
      id: _uuid.v4(),
      nome: titulo,
      macros: macros,
      origem: origem,
      data: DateTime.now(),
    );
    await _repository.saveEntry(entry);
  }
}
