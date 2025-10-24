import 'package:hive/hive.dart';

import 'nutrition_macros.dart';

class DiaryEntry extends HiveObject {
  DiaryEntry({
    required this.id,
    required this.nome,
    required this.macros,
    required this.origem,
    required this.data,
  });

  final String id;
  final String nome;
  final NutritionMacros macros;
  final String origem;
  final DateTime data;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'macros': macros.toMap(),
        'origem': origem,
        'data': data.toIso8601String(),
      };

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] as String,
      nome: map['nome'] as String,
      macros: NutritionMacros.fromMap(Map<String, dynamic>.from(map['macros'])),
      origem: map['origem'] as String,
      data: DateTime.parse(map['data'] as String),
    );
  }
}

class DiaryEntryAdapter extends TypeAdapter<DiaryEntry> {
  @override
  final int typeId = 1;

  @override
  DiaryEntry read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return DiaryEntry.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, DiaryEntry obj) {
    writer.writeMap(obj.toMap());
  }
}
