class UserRestrictions {
  UserRestrictions({
    required this.monitores,
    required this.custom,
  });

  final List<String> monitores;
  final String custom;

  factory UserRestrictions.vazio() => UserRestrictions(
        monitores: const [],
        custom: '',
      );

  Map<String, dynamic> toMap() => {
        'monitores': monitores,
        'custom': custom,
      };

  factory UserRestrictions.fromMap(Map<String, dynamic> map) {
    return UserRestrictions(
      monitores: List<String>.from(map['monitores'] ?? []),
      custom: (map['custom'] ?? '') as String,
    );
  }
}
