import 'package:flutter/material.dart';
import 'dart:convert';

enum UserRole {
  admin,
  user,
}

class UserProfile {
  String id;
  String name;
  String email;
  String password;
  UserRole role; // NOUVEAU : Rôle de l'utilisateur
  int age;
  double weight;
  double height;
  String gender;
  String fitnessLevel;
  String goal;
  String? avatarUrl;
  DateTime createdAt;
  DateTime lastUpdated;
  List<WeightEntry> weightHistory;
  List<String> badges;

   // 🔹 AJOUTEZ CETTE MÉTHODE
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? fitnessLevel,
    String? goal,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<WeightEntry>? weightHistory,
    List<String>? badges,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      weightHistory: weightHistory ?? this.weightHistory,
      badges: badges ?? this.badges,
    );
  }

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.user, // Par défaut: utilisateur normal
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
  })  : weightHistory = weightHistory ?? [],
        badges = badges ?? [];

  bool get isAdmin => role == UserRole.admin;

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
        'password': password,
        'role': role.name, // Sauvegarder le rôle
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
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.user,
        ),
        age: json['age'] as int,
        weight: (json['weight'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        gender: json['gender'] as String,
        fitnessLevel: json['fitnessLevel'] as String,
        goal: json['goal'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        weightHistory: (json['weightHistory'] as List)
            .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        badges: List<String>.from(json['badges'] as List),
      );
}

class WeightEntry {
  DateTime date;
  double weight;

  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight': weight,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        date: DateTime.parse(json['date'] as String),
        weight: (json['weight'] as num).toDouble(),
      );
}