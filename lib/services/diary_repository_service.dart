import 'package:hive/hive.dart';

import '../models/diary_entry.dart';

class DiaryRepositoryService {
  DiaryRepositoryService() : _box = Hive.box<DiaryEntry>('diario');

  final Box<DiaryEntry> _box;

  List<DiaryEntry> get entries => _box.values.toList()
    ..sort((a, b) => b.data.compareTo(a.data));

  Future<void> saveEntry(DiaryEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }
}
