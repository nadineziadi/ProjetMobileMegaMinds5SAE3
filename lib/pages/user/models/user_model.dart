import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  int age;

  @HiveField(4)
  double weight;

  @HiveField(5)
  double height;

  @HiveField(6)
  String gender; // 'male' ou 'female'

  @HiveField(7)
  String fitnessLevel; // 'beginner', 'intermediate', 'advanced'

  @HiveField(8)
  String goal; // 'weight_loss', 'muscle_gain', 'maintenance', 'endurance'

  @HiveField(9)
  String? avatarUrl;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime lastUpdated;

  @HiveField(12)
  List<WeightEntry> weightHistory;

  @HiveField(13)
  List<String> badges;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.fitnessLevel,
    required this.goal,
    this.avatarUrl,
    required this.createdAt,
    required this.lastUpdated,
    List<WeightEntry>? weightHistory,
    List<String>? badges,
  }) : weightHistory = weightHistory ?? [],
       badges = badges ?? [];

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Sous-poids';
    if (bmi < 25) return 'Poids santé';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }

  Color get bmiColor {
    if (bmi < 18.5) return Colors.yellow;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String get personalizedAdvice {
    if (bmi < 18.5) {
      return 'Augmentez votre apport calorique et entraînez-vous 3-4 fois par semaine.';
    } else if (bmi < 25) {
      return 'Vous êtes dans la zone de poids saine. Continuez 3-4 séances par semaine.';
    } else if (bmi < 30) {
      return 'Combinez cardio et alimentation équilibrée. 4-5 séances recommandées.';
    }
    return 'Consultez un professionnel. Commencez doucement avec 3 séances/semaine.';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender,
    'fitnessLevel': fitnessLevel,
    'goal': goal,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'weightHistory': weightHistory.map((e) => e.toJson()).toList(),
    'badges': badges,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    age: json['age'],
    weight: json['weight'].toDouble(),
    height: json['height'].toDouble(),
    gender: json['gender'],
    fitnessLevel: json['fitnessLevel'],
    goal: json['goal'],
    avatarUrl: json['avatarUrl'],
    createdAt: DateTime.parse(json['createdAt']),
    lastUpdated: DateTime.parse(json['lastUpdated']),
    weightHistory: (json['weightHistory'] as List)
        .map((e) => WeightEntry.fromJson(e))
        .toList(),
    badges: List<String>.from(json['badges']),
  );
}

@HiveType(typeId: 1)
class WeightEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double weight;

  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    date: DateTime.parse(json['date']),
    weight: json['weight'].toDouble(),
  );
}