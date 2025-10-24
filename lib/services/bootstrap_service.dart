import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';
import '../models/user_goals.dart';
import '../models/user_restrictions.dart';

class BootstrapService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DiaryEntryAdapter());
    }
    await Hive.openBox<DiaryEntry>('diario');
    await Hive.openBox<Map>('chat');

    _prefs = await SharedPreferences.getInstance();

    // Inicializa metas e restrições padrão se ainda não existirem
    _prefs ??= await SharedPreferences.getInstance();
    _prefs!.setString('metas',
        _prefs!.getString('metas') ?? jsonEncode(UserGoals.padrao().toMap()));
    _prefs!.setString(
        'restricoes',
        _prefs!.getString('restricoes') ??
            jsonEncode(UserRestrictions.vazio().toMap()));
    _prefs!.setString('plano', _prefs!.getString('plano') ?? 'Free');
  }

  static SharedPreferences get prefs => _prefs!;
}
