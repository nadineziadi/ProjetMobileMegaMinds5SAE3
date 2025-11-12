import 'category.dart';

class Supplement {
  String id;
  String name;
  String brand;
  String description;
  double price;
  String imageUrl;
  SupplementCategory type;
  int stock;
  double rating;
  int reviewCount;
  bool favorite;
  DateTime createdAt;
  DateTime updatedAt;

  Supplement({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type,
    this.stock = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.favorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Supplement copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    double? price,
    String? imageUrl,
    SupplementCategory? type,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplement(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'type': type.index,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'favorite': favorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (from SQLite)
  factory Supplement.fromMap(Map<String, dynamic> map) {
    return Supplement(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      type: SupplementCategory.values[map['type'] as int],
      stock: map['stock'] as int,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
      favorite: (map['favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  bool get isInStock => stock > 0;
}

