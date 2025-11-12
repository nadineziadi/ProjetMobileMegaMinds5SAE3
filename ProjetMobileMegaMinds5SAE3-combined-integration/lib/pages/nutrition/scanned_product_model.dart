import 'package:flutter/material.dart';

class ScannedProduct {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final int calories; // pour 100g/ml
  final double? proteins;
  final double? carbs;
  final double? fats;
  final double? fiber;
  final String? nutriScore; // A, B, C, D, E
  final List<String> allergens;
  final String? servingSize;
  final DateTime scannedAt;

  ScannedProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.calories,
    this.proteins,
    this.carbs,
    this.fats,
    this.fiber,
    this.nutriScore,
    this.allergens = const [],
    this.servingSize,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  // Créer depuis l'API Open Food Facts
  factory ScannedProduct.fromOpenFoodFacts(Map<String, dynamic> json, String barcode) {
    final product = json['product'] ?? {};
    final nutriments = product['nutriments'] ?? {};
    
    return ScannedProduct(
      barcode: barcode,
      name: product['product_name'] ?? 'Produit inconnu',
      brand: product['brands'],
      imageUrl: product['image_url'],
      calories: (nutriments['energy-kcal_100g'] ?? 0).toInt(),
      proteins: _toDouble(nutriments['proteins_100g']),
      carbs: _toDouble(nutriments['carbohydrates_100g']),
      fats: _toDouble(nutriments['fat_100g']),
      fiber: _toDouble(nutriments['fiber_100g']),
      nutriScore: product['nutriscore_grade']?.toString().toUpperCase(),
      allergens: _extractAllergens(product['allergens_tags']),
      servingSize: product['serving_size'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _extractAllergens(dynamic allergensData) {
    if (allergensData == null) return [];
    if (allergensData is List) {
      return allergensData
          .map((e) => e.toString().replaceAll('en:', '').replaceAll('-', ' '))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'nutriScore': nutriScore,
      'allergens': allergens,
      'servingSize': servingSize,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  factory ScannedProduct.fromJson(Map<String, dynamic> json) {
    return ScannedProduct(
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      calories: json['calories'] ?? 0,
      proteins: json['proteins'],
      carbs: json['carbs'],
      fats: json['fats'],
      fiber: json['fiber'],
      nutriScore: json['nutriScore'],
      allergens: List<String>.from(json['allergens'] ?? []),
      servingSize: json['servingSize'],
      scannedAt: DateTime.parse(json['scannedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Color getNutriScoreColor() {
    switch (nutriScore) {
      case 'A':
        return Color(0xFF038141);
      case 'B':
        return Color(0xFF85BB2F);
      case 'C':
        return Color(0xFFFECB02);
      case 'D':
        return Color(0xFFEE8100);
      case 'E':
        return Color(0xFFE63E11);
      default:
        return Color(0xFF9E9E9E);
    }
  }
}