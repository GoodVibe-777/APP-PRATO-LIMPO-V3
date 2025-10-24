import 'nutrition_macros.dart';

class ScanResult {
  const ScanResult({
    required this.nomeProduto,
    required this.veredito,
    required this.macros,
    required this.resumoHtml,
    required this.dicaHtml,
  });

  final String nomeProduto;
  final String veredito;
  final NutritionMacros macros;
  final String resumoHtml;
  final String dicaHtml;

  bool get isBom => veredito == 'bom';
  bool get isAtencao => veredito == 'atenção';
  bool get isAlerta => veredito == 'alerta';

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      nomeProduto: (map['name'] ?? 'Produto analisado') as String,
      veredito: (map['verdict'] ?? 'atenção') as String,
      macros: NutritionMacros.fromMap(Map<String, dynamic>.from(map['macros'] ?? {})),
      resumoHtml: (map['summaryHtml'] ?? '<p>Sem detalhes.</p>') as String,
      dicaHtml: (map['tipHtml'] ?? '<p>Experimente trocar por opções mais naturais.</p>') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': nomeProduto,
        'verdict': veredito,
        'macros': macros.toMap(),
        'summaryHtml': resumoHtml,
        'tipHtml': dicaHtml,
      };
}
