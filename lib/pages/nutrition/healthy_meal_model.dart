class HealthyMeal {
  final String id;
  final String name;
  final String imageUrl;
  final int calories;
  final String category;
  final int prepTime; // en minutes
  final String difficulty; // Facile, Moyen, Difficile
  final List<String> ingredients;
  final List<String> steps;
  final Map<String, dynamic> nutrition; // protéines, glucides, lipides
  final List<String> tags; // végétarien, vegan, sans gluten, etc.

  HealthyMeal({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.category,
    required this.prepTime,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.tags,
  });

  factory HealthyMeal.fromJson(Map<String, dynamic> json) {
    return HealthyMeal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      calories: json['calories'] ?? 0,
      category: json['category'] ?? '',
      prepTime: json['prepTime'] ?? 0,
      difficulty: json['difficulty'] ?? 'Moyen',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      nutrition: Map<String, dynamic>.from(json['nutrition'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'calories': calories,
      'category': category,
      'prepTime': prepTime,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'steps': steps,
      'nutrition': nutrition,
      'tags': tags,
    };
  }
}

