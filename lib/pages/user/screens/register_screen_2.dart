
import 'package:flutter/material.dart';

class RegisterScreen2 extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const RegisterScreen2({Key? key, required this.previousData}) : super(key: key);

  @override
  State<RegisterScreen2> createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedFitnessLevel = 'beginner';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('📊', style: TextStyle(fontSize: 70)),
                  const SizedBox(height: 16),
                  const Text(
                    'Physical Information',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Help us personalize your experience',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  // Age
                  _buildNumberField(
                    controller: _ageController,
                    hintText: 'Age (years)',
                    icon: Icons.cake,
                  ),
                  const SizedBox(height: 16),
                  
                  // Weight
                  _buildNumberField(
                    controller: _weightController,
                    hintText: 'Weight (kg)',
                    icon: Icons.monitor_weight,
                  ),
                  const SizedBox(height: 16),
                  
                  // Height
                  _buildNumberField(
                    controller: _heightController,
                    hintText: 'Height (cm)',
                    icon: Icons.height,
                  ),
                  const SizedBox(height: 24),
                  
                  // Gender Selection
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Gender',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderButton('Male', 'male', '👨'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenderButton('Female', 'female', '👩'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Fitness Level
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fitness Level',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d2d2d),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFitnessLevel,
                      dropdownColor: const Color(0xFF2d2d2d),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.fitness_center, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'beginner', child: Text('Débutant')),
                        DropdownMenuItem(value: 'intermediate', child: Text('Intermédiaire')),
                        DropdownMenuItem(value: 'advanced', child: Text('Avancé')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedFitnessLevel = value!);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final data = {
                            ...widget.previousData,
                            'age': int.parse(_ageController.text),
                            'weight': double.parse(_weightController.text),
                            'height': double.parse(_heightController.text),
                            'gender': _selectedGender,
                            'fitnessLevel': _selectedFitnessLevel,
                          };
                          Navigator.pushNamed(context, '/register3', arguments: data);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFa3e635),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2d2d2d)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2d2d2d),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFa3e635)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        if (double.tryParse(value) == null) {
          return 'Nombre invalide';
        }
        return null;
      },
    );
  }

  Widget _buildGenderButton(String label, String value, String emoji) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFa3e635), Color(0xFF22c55e)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF2d2d2d),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}