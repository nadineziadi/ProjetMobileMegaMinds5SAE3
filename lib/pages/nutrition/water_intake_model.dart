class WaterIntake {
  final String id;
  int amount; // en ml
  DateTime timestamp;

  WaterIntake({
    required this.id,
    required this.amount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Créer depuis Map SQLite
  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'],
      amount: map['amount'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  // Vérifier si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  // Obtenir l'heure formatée
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Objectif journalier de l'utilisateur
class WaterGoal {
  int dailyGoal; // en ml (par défaut 2000ml = 2L)
  bool remindersEnabled;

  WaterGoal({
    this.dailyGoal = 2000,
    this.remindersEnabled = true,
  });

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'dailyGoal': dailyGoal,
      'remindersEnabled': remindersEnabled ? 1 : 0,
    };
  }

  // Créer depuis Map SQLite
  factory WaterGoal.fromMap(Map<String, dynamic> map) {
    return WaterGoal(
      dailyGoal: map['dailyGoal'],
      remindersEnabled: map['remindersEnabled'] == 1,
    );
  }
}