import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'healthy_meal_model.dart';

class HealthyMealsService {
  static List<HealthyMeal> _mockMeals = [
    HealthyMeal(
      id: '1',
      name: 'Salade Caesar au Poulet',
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800',
      calories: 350,
      category: 'Déjeuner',
      prepTime: 20,
      difficulty: 'Facile',
      ingredients: [
        '200g de poulet grillé',
        '100g de laitue romaine',
        '30g de parmesan râpé',
        '2 cuillères à soupe de sauce Caesar',
        'Croûtons maison',
        'Citron',
      ],
      steps: [
        'Laver et couper la laitue en morceaux',
        'Griller le poulet et le couper en lanières',
        'Préparer les croûtons au four (5 min à 180°C)',
        'Mélanger tous les ingrédients dans un bol',
        'Ajouter la sauce Caesar et bien mélanger',
        'Râper le parmesan par-dessus',
        'Servir immédiatement',
      ],
      nutrition: {
        'protéines': '35g',
        'glucides': '18g',
        'lipides': '15g',
        'fibres': '4g',
      },
      tags: ['Riche en protéines', 'Sans gluten possible'],
    ),
    HealthyMeal(
      id: '2',
      name: 'Bowl Buddha Végétarien',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
      calories: 420,
      category: 'Déjeuner',
      prepTime: 30,
      difficulty: 'Moyen',
      ingredients: [
        '150g de quinoa',
        '100g de pois chiches rôtis',
        '1 avocat',
        '100g de patate douce',
        '50g d\'épinards frais',
        'Graines de sésame',
        'Sauce tahini',
      ],
      steps: [
        'Cuire le quinoa selon les instructions',
        'Rôtir les pois chiches avec des épices (paprika, cumin)',
        'Cuire la patate douce au four en cubes',
        'Préparer la sauce tahini (tahini, citron, eau)',
        'Disposer tous les ingrédients dans un bol',
        'Ajouter l\'avocat coupé en tranches',
        'Arroser de sauce et saupoudrer de graines de sésame',
      ],
      nutrition: {
        'protéines': '18g',
        'glucides': '52g',
        'lipides': '20g',
        'fibres': '12g',
      },
      tags: ['Végétarien', 'Vegan', 'Sans gluten', 'Riche en fibres'],
    ),
    HealthyMeal(
      id: '3',
      name: 'Saumon Grillé aux Légumes',
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800',
      calories: 480,
      category: 'Dîner',
      prepTime: 25,
      difficulty: 'Facile',
      ingredients: [
        '200g de filet de saumon',
        '150g de brocoli',
        '100g de haricots verts',
        '1 citron',
        'Huile d\'olive',
        'Herbes de Provence',
        'Ail',
      ],
      steps: [
        'Préchauffer le four à 200°C',
        'Assaisonner le saumon avec sel, poivre et herbes',
        'Cuire le saumon au four pendant 15 minutes',
        'Faire cuire les légumes à la vapeur',
        'Faire revenir l\'ail dans l\'huile d\'olive',
        'Mélanger les légumes avec l\'ail',
        'Servir le saumon avec les légumes et un filet de citron',
      ],
      nutrition: {
        'protéines': '42g',
        'glucides': '12g',
        'lipides': '28g',
        'oméga-3': '2.5g',
      },
      tags: ['Riche en protéines', 'Oméga-3', 'Sans gluten'],
    ),
    HealthyMeal(
      id: '4',
      name: 'Smoothie Bowl aux Fruits',
      imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=800',
      calories: 280,
      category: 'Petit-déjeuner',
      prepTime: 10,
      difficulty: 'Facile',
      ingredients: [
        '1 banane congelée',
        '100g de fruits rouges surgelés',
        '150ml de lait d\'amande',
        '1 cuillère de beurre d\'amande',
        'Toppings: granola, noix de coco, fruits frais',
        'Graines de chia',
      ],
      steps: [
        'Mixer la banane, fruits rouges et lait jusqu\'à consistance lisse',
        'Verser dans un bol',
        'Ajouter les toppings de votre choix',
        'Disposer les fruits frais joliment',
        'Saupoudrer de graines de chia',
        'Servir immédiatement',
      ],
      nutrition: {
        'protéines': '8g',
        'glucides': '45g',
        'lipides': '10g',
        'fibres': '8g',
      },
      tags: ['Végétarien', 'Vegan possible', 'Antioxydants', 'Rapide'],
    ),
    HealthyMeal(
      id: '5',
      name: 'Wrap au Poulet et Houmous',
      imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=800',
      calories: 380,
      category: 'Déjeuner',
      prepTime: 15,
      difficulty: 'Facile',
      ingredients: [
        '1 tortilla complète',
        '150g de poulet grillé',
        '3 cuillères de houmous',
        'Laitue',
        'Tomate',
        'Concombre',
        'Oignon rouge',
      ],
      steps: [
        'Réchauffer légèrement la tortilla',
        'Étaler le houmous sur toute la surface',
        'Disposer les tranches de poulet au centre',
        'Ajouter la laitue, tomate et concombre',
        'Ajouter l\'oignon rouge émincé',
        'Rouler fermement la tortilla',
        'Couper en deux et servir',
      ],
      nutrition: {
        'protéines': '32g',
        'glucides': '38g',
        'lipides': '12g',
        'fibres': '6g',
      },
      tags: ['Riche en protéines', 'Rapide', 'Transport facile'],
    ),
    HealthyMeal(
      id: '6',
      name: 'Omelette aux Légumes',
      imageUrl: 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=800',
      calories: 320,
      category: 'Petit-déjeuner',
      prepTime: 15,
      difficulty: 'Facile',
      ingredients: [
        '3 œufs',
        '50g de poivrons',
        '50g de champignons',
        '30g de fromage râpé',
        'Épinards frais',
        'Sel, poivre',
        'Huile d\'olive',
      ],
      steps: [
        'Battre les œufs dans un bol',
        'Faire revenir les légumes dans une poêle',
        'Verser les œufs sur les légumes',
        'Laisser cuire à feu moyen',
        'Ajouter le fromage',
        'Plier l\'omelette en deux',
        'Servir chaud avec des herbes fraîches',
      ],
      nutrition: {
        'protéines': '24g',
        'glucides': '8g',
        'lipides': '22g',
        'fibres': '2g',
      },
      tags: ['Riche en protéines', 'Sans gluten', 'Végétarien'],
    ),
    HealthyMeal(
      id: '7',
      name: 'Poke Bowl au Thon',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
      calories: 450,
      category: 'Déjeuner',
      prepTime: 25,
      difficulty: 'Moyen',
      ingredients: [
        '200g de thon frais',
        '150g de riz à sushi',
        '1 avocat',
        'Edamame',
        'Concombre',
        'Algue nori',
        'Sauce soja',
        'Graines de sésame',
      ],
      steps: [
        'Cuire le riz à sushi',
        'Couper le thon en cubes',
        'Préparer tous les légumes en dés',
        'Disposer le riz dans un bol',
        'Ajouter le thon mariné',
        'Disposer les légumes joliment',
        'Arroser de sauce et parsemer de sésame',
      ],
      nutrition: {
        'protéines': '38g',
        'glucides': '42g',
        'lipides': '18g',
        'oméga-3': '2g',
      },
      tags: ['Riche en protéines', 'Oméga-3', 'Sans gluten'],
    ),
    HealthyMeal(
      id: '8',
      name: 'Curry de Lentilles',
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
      calories: 390,
      category: 'Dîner',
      prepTime: 35,
      difficulty: 'Moyen',
      ingredients: [
        '200g de lentilles corail',
        '400ml de lait de coco',
        '1 oignon',
        '2 gousses d\'ail',
        'Curry en poudre',
        'Tomates',
        'Épinards',
        'Riz basmati',
      ],
      steps: [
        'Faire revenir l\'oignon et l\'ail',
        'Ajouter le curry et faire griller 1 minute',
        'Ajouter les lentilles et les tomates',
        'Verser le lait de coco',
        'Laisser mijoter 20 minutes',
        'Ajouter les épinards en fin de cuisson',
        'Servir avec du riz basmati',
      ],
      nutrition: {
        'protéines': '16g',
        'glucides': '48g',
        'lipides': '15g',
        'fibres': '10g',
      },
      tags: ['Végétarien', 'Vegan', 'Sans gluten', 'Riche en fibres'],
    ),
  ];

  // Obtenir tous les plats
  static Future<List<HealthyMeal>> getAllMeals() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simuler un appel API
    return _mockMeals;
  }

  // Obtenir les plats par catégorie
  static Future<List<HealthyMeal>> getMealsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMeals.where((meal) => meal.category == category).toList();
  }

  // Rechercher des plats
  static Future<List<HealthyMeal>> searchMeals(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _mockMeals.where((meal) {
      return meal.name.toLowerCase().contains(lowercaseQuery) ||
          meal.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Gestion des favoris avec SharedPreferences
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorite_meals') ?? [];
  }

  static Future<void> addToFavorites(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(mealId)) {
      favorites.add(mealId);
      await prefs.setStringList('favorite_meals', favorites);
    }
  }

  static Future<void> removeFromFavorites(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(mealId);
    await prefs.setStringList('favorite_meals', favorites);
  }

  static Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavorites();
    return favorites.contains(mealId);
  }

  static Future<List<HealthyMeal>> getFavoriteMeals() async {
    final favorites = await getFavorites();
    return _mockMeals.where((meal) => favorites.contains(meal.id)).toList();
  }
}
