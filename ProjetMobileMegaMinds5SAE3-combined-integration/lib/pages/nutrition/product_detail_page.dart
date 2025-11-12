import 'package:flutter/material.dart';
import 'scanned_product_model.dart';
import 'meal_model.dart';
import 'meal_service.dart';
import 'package:uuid/uuid.dart';

class ProductDetailPage extends StatefulWidget {
  final ScannedProduct product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  double _portion = 100; // Portion par défaut en grammes
  int _selectedCategory = 1; // Déjeuner par défaut

  int get calculatedCalories => (widget.product.calories * _portion / 100).round();
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Petit-déjeuner', 'icon': Icons.wb_sunny},
    {'name': 'Déjeuner', 'icon': Icons.lunch_dining},
    {'name': 'Dîner', 'icon': Icons.dinner_dining},
    {'name': 'Collation', 'icon': Icons.apple},
  ];

  Future<void> _addToMeals() async {
    final newMeal = Meal(
      id: const Uuid().v4(),
      name: '${widget.product.name}${widget.product.brand != null ? ' - ${widget.product.brand}' : ''}',
      imagePath: widget.product.imageUrl, // Sauvegarder l'URL de l'image
      calories: calculatedCalories,
      category: _selectedCategory,
    );

    await MealService.addMeal(newMeal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ajouté avec ${calculatedCalories} kcal !',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFC7F000),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: const Text(
          'Détails du produit',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image du produit
            if (widget.product.imageUrl != null)
              Container(
                height: 250,
                color: Colors.white,
                child: Image.network(
                  widget.product.imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.shopping_bag,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                color: const Color(0xFF2A2E32),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 100,
                  color: Color(0xFFC7F000),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et marque
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.product.brand != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.product.brand!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Nutri-Score
                  if (widget.product.nutriScore != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2E32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Nutri-Score',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.product.getNutriScoreColor(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.product.nutriScore!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Portion selector
                  _buildSectionTitle('Portion'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2E32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quantité',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              '${_portion.round()}g',
                              style: const TextStyle(
                                color: Color(0xFFC7F000),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _portion,
                          min: 10,
                          max: 500,
                          divisions: 49,
                          activeColor: const Color(0xFFC7F000),
                          inactiveColor: Colors.grey[700],
                          onChanged: (value) {
                            setState(() => _portion = value);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickButton('50g', 50),
                            _buildQuickButton('100g', 100),
                            _buildQuickButton('150g', 150),
                            _buildQuickButton('200g', 200),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Calories calculées
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC7F000), Color(0xFFA0C000)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.black,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$calculatedCalories kcal',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Valeurs nutritionnelles pour 100g
                  _buildSectionTitle('Valeurs nutritionnelles (pour 100g)'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2E32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (widget.product.proteins != null)
                          _buildNutritionRow('Protéines', '${widget.product.proteins}g', Icons.fitness_center),
                        if (widget.product.carbs != null)
                          _buildNutritionRow('Glucides', '${widget.product.carbs}g', Icons.grain),
                        if (widget.product.fats != null)
                          _buildNutritionRow('Lipides', '${widget.product.fats}g', Icons.water_drop),
                        if (widget.product.fiber != null)
                          _buildNutritionRow('Fibres', '${widget.product.fiber}g', Icons.spa),
                      ],
                    ),
                  ),

                  // Allergènes
                  if (widget.product.allergens.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle('Allergènes'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.allergens.map((allergen) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                allergen,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Catégorie de repas
                  _buildSectionTitle('Ajouter à'),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_categories.length, (index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = index),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: index < _categories.length - 1 ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFC7F000)
                                  : const Color(0xFF2A2E32),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFC7F000)
                                    : Colors.grey[800]!,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  category['icon'],
                                  color: isSelected
                                      ? Colors.black
                                      : const Color(0xFFC7F000),
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Bouton d'ajout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addToMeals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC7F000),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ajouter à mon journal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFC7F000),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC7F000), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFC7F000),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, double value) {
    final isSelected = _portion == value;
    return GestureDetector(
      onTap: () => setState(() => _portion = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC7F000) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFFC7F000) : Colors.grey[700]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}