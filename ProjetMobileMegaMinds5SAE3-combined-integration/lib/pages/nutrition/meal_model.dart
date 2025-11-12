import 'package:flutter/foundation.dart';

enum MealCategory {
  breakfast,
  lunch,
  dinner,
  snack
}

class Meal {
  final String id;
  String name;
  String? imagePath;
  int calories;
  DateTime dateAdded;
  int category; // 0=breakfast, 1=lunch, 2=dinner, 3=snack

  Meal({
    required this.id,
    required this.name,
    this.imagePath,
    required this.calories,
    DateTime? dateAdded,
    this.category = 0,
  }) : dateAdded = dateAdded ?? DateTime.now();

  // === Méthodes utilitaires pour SQLite ===

  /// Convertir un objet Meal → Map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'calories': calories,
      'dateAdded': dateAdded.toIso8601String(),
      'category': category,
    };
  }

  /// Convertir une ligne de la table SQLite → Meal
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      calories: map['calories'],
      dateAdded: DateTime.parse(map['dateAdded']),
      category: map['category'],
    );
  }

  // === Propriétés utilitaires ===

  MealCategory get mealCategory => MealCategory.values[category];

  String get categoryName {
    switch (category) {
      case 0:
        return 'Petit-déjeuner';
      case 1:
        return 'Déjeuner';
      case 2:
        return 'Dîner';
      case 3:
        return 'Collation';
      default:
        return 'Autre';
    }
  }

  String get categoryIcon {
    switch (category) {
      case 0:
        return '🌅';
      case 1:
        return '☀️';
      case 2:
        return '🌙';
      case 3:
        return '🍎';
      default:
        return '🍽️';
    }
  }

  String get formattedDate {
    return '${dateAdded.day}/${dateAdded.month}/${dateAdded.year}';
  }

  bool get isToday {
    final now = DateTime.now();
    return dateAdded.year == now.year &&
        dateAdded.month == now.month &&
        dateAdded.day == now.day;
  }
}
