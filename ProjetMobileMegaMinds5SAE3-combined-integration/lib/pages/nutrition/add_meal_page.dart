import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'meal_model.dart';
import 'meal_service.dart';
import 'package:uuid/uuid.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Petit-déjeuner', 'icon': Icons.wb_sunny},
    {'name': 'Déjeuner', 'icon': Icons.lunch_dining},
    {'name': 'Dîner', 'icon': Icons.dinner_dining},
    {'name': 'Collation', 'icon': Icons.apple},
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      final meal = Meal(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        calories: int.tryParse(_caloriesController.text) ?? 0,
        category: _selectedCategory,
        imagePath: _imageFile?.path,
        // ← SUPPRIMÉ date: DateTime.now() → c’est la cause de l’erreur !
      );
      await MealService.addMeal(meal);
      if (mounted) Navigator.pop(context, meal);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17191C),
        title: const Text("Ajouter un repas", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Catégorie *", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) {
                  final isSelected = _selectedCategory == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = i),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFC7F000) : const Color(0xFF2A2E32),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(_categories[i]['icon'], color: isSelected ? Colors.black : const Color(0xFFC7F000), size: 32),
                          const SizedBox(height: 4),
                          Text(
                            _categories[i]['name'],
                            style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(color: const Color(0xFF2A2E32), borderRadius: BorderRadius.circular(16)),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Aucune image sélectionnée", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_imageFile!, fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Galerie"),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC7F000), side: const BorderSide(color: Color(0xFFC7F000))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Photo"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC7F000), foregroundColor: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom du plat *",
                  prefixIcon: Icon(Icons.restaurant_menu, color: Color(0xFFC7F000)),
                  filled: true,
                  fillColor: Color(0xFF2A2E32),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v!.trim().isEmpty ? "Obligatoire" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Calories (kcal) *",
                  prefixIcon: Icon(Icons.local_fire_department, color: Color(0xFFC7F000)),
                  filled: true,
                  fillColor: Color(0xFF2A2E32),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) {
                  if (v!.trim().isEmpty) return "Obligatoire";
                  if (int.tryParse(v) == null) return "Nombre invalide";
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7F000),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Ajouter le repas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
