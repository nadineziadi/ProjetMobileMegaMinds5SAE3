import 'package:flutter/material.dart';
import 'healthy_meal_model.dart';
import 'healthy_meals_service.dart';
import 'meal_detail_page.dart';

class HealthyMealsPage extends StatefulWidget {
  const HealthyMealsPage({super.key});

  @override
  State<HealthyMealsPage> createState() => _HealthyMealsPageState();
}

class _HealthyMealsPageState extends State<HealthyMealsPage> {
  List<HealthyMeal> _allMeals = [];
  List<HealthyMeal> _filteredMeals = [];
  bool _isLoading = true;
  String _selectedCategory = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  Set<String> _favorites = {};

  final List<String> _categories = [
    'Tous',
    'Petit-déjeuner',
    'Déjeuner',
    'Dîner',
    'Collation',
  ];

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _loadFavorites();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    final meals = await HealthyMealsService.getAllMeals();
    setState(() {
      _allMeals = meals;
      _filteredMeals = meals;
      _isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final favorites = await HealthyMealsService.getFavorites();
    setState(() => _favorites = favorites.toSet());
  }

  void _filterMeals(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Tous') {
        _filteredMeals = _allMeals;
      } else {
        _filteredMeals = _allMeals.where((meal) => meal.category == category).toList();
      }
    });
  }

  void _searchMeals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMeals = _selectedCategory == 'Tous' 
            ? _allMeals 
            : _allMeals.where((meal) => meal.category == _selectedCategory).toList();
      } else {
        _filteredMeals = _allMeals.where((meal) {
          return meal.name.toLowerCase().contains(query.toLowerCase()) ||
              meal.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  Future<void> _toggleFavorite(String mealId) async {
    if (_favorites.contains(mealId)) {
      await HealthyMealsService.removeFromFavorites(mealId);
      setState(() => _favorites.remove(mealId));
    } else {
      await HealthyMealsService.addToFavorites(mealId);
      setState(() => _favorites.add(mealId));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: const Text(
          'Recettes Healthy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFFC7F000)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteMealsPage(),
                ),
              ).then((_) => _loadFavorites());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC7F000)),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchMeals,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une recette...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFC7F000)),
                      filled: true,
                      fillColor: const Color(0xFF2A2E32),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Categories
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () => _filterMeals(category),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFC7F000)
                                : const Color(0xFF2A2E32),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Meals grid
                Expanded(
                  child: _filteredMeals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 80, color: Colors.grey[700]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune recette trouvée',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredMeals.length,
                          itemBuilder: (context, index) {
                            final meal = _filteredMeals[index];
                            final isFavorite = _favorites.contains(meal.id);
                            return _buildMealCard(meal, isFavorite);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMealCard(HealthyMeal meal, bool isFavorite) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealDetailPage(meal: meal),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2E32),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    meal.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: const Color(0xFF17191C),
                        child: const Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Color(0xFFC7F000),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(meal.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Color(0xFFC7F000),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(
                            color: Color(0xFFC7F000),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.prepTime} min',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(meal.difficulty),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            meal.difficulty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Facile':
        return Colors.green;
      case 'Moyen':
        return Colors.orange;
      case 'Difficile':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Page des favoris
class FavoriteMealsPage extends StatefulWidget {
  const FavoriteMealsPage({super.key});

  @override
  State<FavoriteMealsPage> createState() => _FavoriteMealsPageState();
}

class _FavoriteMealsPageState extends State<FavoriteMealsPage> {
  List<HealthyMeal> _favoriteMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final meals = await HealthyMealsService.getFavoriteMeals();
    setState(() {
      _favoriteMeals = meals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: const Text(
          'Mes Favoris',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC7F000)),
            )
          : _favoriteMeals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey[700]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun favori pour le moment',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez vos recettes préférées',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteMeals.length,
                  itemBuilder: (context, index) {
                    final meal = _favoriteMeals[index];
                    return _buildFavoriteCard(meal);
                  },
                ),
    );
  }

  Widget _buildFavoriteCard(HealthyMeal meal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealDetailPage(meal: meal),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2E32),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                meal.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: const Color(0xFF17191C),
                    child: const Icon(Icons.restaurant, color: Color(0xFFC7F000)),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Color(0xFFC7F000),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(
                            color: Color(0xFFC7F000),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.prepTime} min',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


