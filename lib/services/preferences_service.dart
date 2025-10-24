import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_goals.dart';
import '../models/user_restrictions.dart';
import 'bootstrap_service.dart';

class PreferencesService {
  SharedPreferences get _prefs => BootstrapService.prefs;

  UserGoals obterMetas() {
    final raw = _prefs.getString('metas');
    if (raw == null) return UserGoals.padrao();
    return UserGoals.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> salvarMetas(UserGoals goals) async {
    await _prefs.setString('metas', jsonEncode(goals.toMap()));
  }

  UserRestrictions obterRestricoes() {
    final raw = _prefs.getString('restricoes');
    if (raw == null) return UserRestrictions.vazio();
    return UserRestrictions.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> salvarRestricoes(UserRestrictions restrictions) async {
    await _prefs.setString('restricoes', jsonEncode(restrictions.toMap()));
  }

  bool isPro() => _prefs.getString('plano') == 'PRO';

  Future<void> alternarPlano() async {
    final atual = isPro();
    await _prefs.setString('plano', atual ? 'Free' : 'PRO');
  }
}
