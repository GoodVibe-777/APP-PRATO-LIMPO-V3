import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_goals.dart';
import '../models/user_restrictions.dart';
import '../services/preferences_service.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final planoProProvider = StateProvider<bool>((ref) {
  final service = ref.watch(preferencesServiceProvider);
  return service.isPro();
});

final metasProvider = StateProvider<UserGoals>((ref) {
  final service = ref.watch(preferencesServiceProvider);
  return service.obterMetas();
});

final restricoesProvider = StateProvider<UserRestrictions>((ref) {
  final service = ref.watch(preferencesServiceProvider);
  return service.obterRestricoes();
});
