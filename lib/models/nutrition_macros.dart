class NutritionMacros {
  final double calorias;
  final double proteinas;
  final double carboidratos;
  final double gorduras;

  const NutritionMacros({
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
  });

  factory NutritionMacros.zero() => const NutritionMacros(
        calorias: 0,
        proteinas: 0,
        carboidratos: 0,
        gorduras: 0,
      );

  NutritionMacros copyWith({
    double? calorias,
    double? proteinas,
    double? carboidratos,
    double? gorduras,
  }) {
    return NutritionMacros(
      calorias: calorias ?? this.calorias,
      proteinas: proteinas ?? this.proteinas,
      carboidratos: carboidratos ?? this.carboidratos,
      gorduras: gorduras ?? this.gorduras,
    );
  }

  Map<String, dynamic> toMap() => {
        'calorias': calorias,
        'proteinas': proteinas,
        'carboidratos': carboidratos,
        'gorduras': gorduras,
      };

  factory NutritionMacros.fromMap(Map<String, dynamic> map) {
    return NutritionMacros(
      calorias: (map['calorias'] ?? 0).toDouble(),
      proteinas: (map['proteinas'] ?? 0).toDouble(),
      carboidratos: (map['carboidratos'] ?? 0).toDouble(),
      gorduras: (map['gorduras'] ?? 0).toDouble(),
    );
  }
}
