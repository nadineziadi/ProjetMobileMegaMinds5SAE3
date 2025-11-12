// lib/pages/nutrition/nutrition_page.dart
import 'package:flutter/material.dart';
import '../../widgets/meal_card.dart';
import 'meal_model.dart';
import 'meal_service.dart';
import 'add_meal_page.dart';
import 'barcode_scanner_page.dart';
import 'healthy_meals_page.dart';
import 'water_tracker_page.dart';
import 'nutrition_stats_page.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});
  @override
  NutritionPageState createState() => NutritionPageState();
}

class NutritionPageState extends State<NutritionPage> {
  List<Meal> meals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  Future<void> loadMeals() async {
    setState(() => isLoading = true);
    final data = await MealService.getTodayMeals();
    if (mounted) {
      setState(() {
        meals = data;
        isLoading = false;
      });
    }
  }

  // Accessible depuis main.dart
  void showAddOptions() => _showAddOptions();

  int get totalCalories => meals.fold(0, (a, b) => a + b.calories);

  Map<int, int> get caloriesByCategory {
    final map = {0: 0, 1: 0, 2: 0, 3: 0};
    for (var m in meals) map[m.category] = (map[m.category] ?? 0) + m.calories;
    return map;
  }

  List<Meal> getMealsByCategory(int cat) => meals.where((m) => m.category == cat).toList();

  String get advice {
    if (totalCalories > 2500) return "Vous avez dépassé votre objectif de calories aujourd'hui.";
    if (totalCalories < 1500) return "Pensez à ajouter plus de protéines.";
    return "Bon équilibre alimentaire aujourd'hui.";
  }

  Future<void> deleteMeal(Meal meal) async {
    await MealService.deleteMeal(meal.id);
    loadMeals();
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2A2E32),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Ajouter un repas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _optionButton(Icons.qr_code_scanner, 'Scanner un produit', 'Code-barres avec Open Food Facts', () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const BarcodeScannerPage()));
              loadMeals();
            }),
            const SizedBox(height: 12),
            _optionButton(Icons.edit, 'Saisie manuelle', 'Créer un repas personnalisé', () async {
              Navigator.pop(context);
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMealPage()));
              if (res is Meal) {
                await MealService.addMeal(res);
                loadMeals();
              }
            }),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  Widget _optionButton(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF17191C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFC7F000).withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFC7F000).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFFC7F000), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ])),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFFC7F000), size: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2124),
      appBar: AppBar(
        title: const Text("Nutrition"),
        backgroundColor: const Color(0xFF2A2E32),
        elevation: 0,
        actions: [
          // Add Meal Button
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFC7F000)),
            onPressed: () => showAddOptions(),
          ),

          // Statistics Button
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Color(0xFFC7F000)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionStatsPage()));
            },
          ),

          // Favorites / Recettes Préférées Button - CHANGÉ: coeur -> fastfood
          IconButton(
            icon: const Icon(Icons.fastfood, color: Color(0xFFC7F000)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthyMealsPage()));
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC7F000)))
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Calories totales
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2A2E32), Color(0xFF1E2124)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(children: [
                      const Text("Calories d'aujourd'hui", style: TextStyle(color: Colors.white70, fontSize: 15)),
                      const SizedBox(height: 10),
                      Text("$totalCalories", style: const TextStyle(color: Color(0xFFC7F000), fontSize: 50, fontWeight: FontWeight.bold)),
                      const Text("kcal", style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Mini cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _miniCard(0, 'Petit-déj', caloriesByCategory[0]!),
                        const SizedBox(width: 12),
                        _miniCard(1, 'Déj', caloriesByCategory[1]!),
                        const SizedBox(width: 12),
                        _miniCard(2, 'Dîner', caloriesByCategory[2]!),
                        const SizedBox(width: 12),
                        _miniCard(3, 'Snack', caloriesByCategory[3]!),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Advice
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF2A2E32), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Color(0xFFC7F000), size: 28),
                          const SizedBox(width: 12),
                          Expanded(child: Text(advice, style: const TextStyle(color: Colors.white, fontSize: 15))),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Meals by category
                ...List.generate(4, (cat) {
                  final catMeals = getMealsByCategory(cat);
                  if (catMeals.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverToBoxAdapter(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                        child: Row(
                          children: [
                            Text(['🌅', '☀️', '🌙', '🍎'][cat], style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 12),
                            Text(
                              ['Petit-déjeuner', 'Déjeuner', 'Dîner', 'Collation'][cat],
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      ...catMeals.map((m) => MealCard(meal: m, onDelete: () => deleteMeal(m))),
                      const SizedBox(height: 16),
                    ]),
                  );
                }),

                // SUPPRIMÉ: L'espace supplémentaire en bas a été enlevé
              ],
            ),

      // Floating button déplacé vers le haut
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0), // Déplacé vers le haut
        child: FloatingActionButton(
          heroTag: "water",
          backgroundColor: const Color(0xFF0288D1),
          child: const Icon(Icons.local_drink, color: Colors.white, size: 32),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterTrackerPage()));
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2A2E32),
        selectedItemColor: const Color(0xFFC7F000),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Nutrition"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workouts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: 0,
        onTap: (index) {
          // handle navigation
        },
      ),
    );
  }

  Widget _miniCard(int cat, String title, int cal) {
    final emojis = ['🌅', '☀️', '🌙', '🍎'];
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFF2A2E32), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(emojis[cat], style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text('$cal', style: const TextStyle(color: Color(0xFFC7F000), fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}