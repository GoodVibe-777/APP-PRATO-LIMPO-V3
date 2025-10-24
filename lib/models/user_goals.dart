import 'nutrition_macros.dart';

class UserGoals {
  UserGoals({
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
  });

  final double calorias;
  final double proteinas;
  final double carboidratos;
  final double gorduras;

  factory UserGoals.padrao() => UserGoals(
        calorias: 2000,
        proteinas: 120,
        carboidratos: 250,
        gorduras: 70,
      );

  NutritionMacros toMacros() => NutritionMacros(
        calorias: calorias,
        proteinas: proteinas,
        carboidratos: carboidratos,
        gorduras: gorduras,
      );

  Map<String, dynamic> toMap() => {
        'calorias': calorias,
        'proteinas': proteinas,
        'carboidratos': carboidratos,
        'gorduras': gorduras,
      };

  factory UserGoals.fromMap(Map<String, dynamic> map) {
    return UserGoals(
      calorias: (map['calorias'] ?? 0).toDouble(),
      proteinas: (map['proteinas'] ?? 0).toDouble(),
      carboidratos: (map['carboidratos'] ?? 0).toDouble(),
      gorduras: (map['gorduras'] ?? 0).toDouble(),
    );
  }
}
