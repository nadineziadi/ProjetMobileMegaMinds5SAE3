// lib/pages/workout/workout_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_model.dart';
import '../services/workout_database.dart';

class WorkoutFormScreen extends StatefulWidget {
  final Workout? existingWorkout;
  const WorkoutFormScreen({super.key, this.existingWorkout});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'Cardio';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<WorkoutType> _workoutTypes = [
    WorkoutType('Cardio', Icons.directions_run_rounded, const Color(0xFFFF6B6B)),
    WorkoutType('Force', Icons.fitness_center_rounded, const Color(0xFFFF8E53)),
    WorkoutType('Étirement', Icons.self_improvement_rounded, const Color(0xFF4ECDC4)),
    WorkoutType('Yoga', Icons.spa_rounded, const Color(0xFFB565D8)),
    WorkoutType('HIIT', Icons.local_fire_department_rounded, const Color(0xFFF9CA24)),
    WorkoutType('CrossFit', Icons.sports_gymnastics_rounded, const Color(0xFF6C5CE7)),
    WorkoutType('Natation', Icons.pool_rounded, const Color(0xFF00B894)),
    WorkoutType('Course', Icons.directions_run_rounded, const Color(0xFFE17055)),
    WorkoutType('Cyclisme', Icons.directions_bike_rounded, const Color(0xFF0984E3)),
    WorkoutType('Autre', Icons.sports_rounded, const Color(0xFFC7F000)),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingWorkout != null) {
      _nameController.text = widget.existingWorkout!.name;
      _selectedType = widget.existingWorkout!.type;
      _durationController.text = widget.existingWorkout!.duration.toString();
      _caloriesController.text = widget.existingWorkout!.caloriesBurned?.toString() ?? '';
      _notesController.text = widget.existingWorkout!.notes ?? '';
      _selectedDate = widget.existingWorkout!.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingWorkout != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF353A40), Color(0xFF121416)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isEditing),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildSection(
                        title: 'Informations de base',
                        icon: Icons.info_outline_rounded,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nom de l\'entraînement',
                            hint: 'Ex: Séance matinale',
                            icon: Icons.edit_rounded,
                            validator: (v) => v!.isEmpty ? 'Nom requis' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTypeSelector(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _durationController,
                                  label: 'Durée (minutes)',
                                  hint: '30',
                                  icon: Icons.access_time_rounded,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? 'Durée requise' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _caloriesController,
                                  label: 'Calories (opt.)',
                                  hint: '250',
                                  icon: Icons.local_fire_department_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Date',
                        icon: Icons.calendar_today_rounded,
                        children: [
                          _buildDatePicker(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Notes (optionnel)',
                        icon: Icons.note_rounded,
                        children: [
                          _buildTextField(
                            controller: _notesController,
                            label: 'Vos notes',
                            hint: 'Comment vous êtes-vous senti ?',
                            icon: Icons.description_rounded,
                            maxLines: 4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSaveButton(isEditing),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2124),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2D31)),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Modifier' : 'Nouvel entraînement',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditing ? 'Mettez à jour les détails' : 'Ajoutez les détails',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2D31), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7F000).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFC7F000), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        hintStyle: TextStyle(color: const Color(0xFF9E9E9E).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFFC7F000), size: 20),
        filled: true,
        fillColor: const Color(0xFF121416),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2D31)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2D31), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC7F000), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type d\'entraînement',
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _workoutTypes.map((type) {
            final isSelected = _selectedType == type.name;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? type.color.withOpacity(0.15)
                      : const Color(0xFF121416),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? type.color : const Color(0xFF2A2D31),
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected ? type.color : const Color(0xFF9E9E9E),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type.name,
                      style: TextStyle(
                        color: isSelected ? type.color : const Color(0xFF9E9E9E),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121416),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2D31), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFC7F000).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFFC7F000),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date sélectionnée',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF9E9E9E),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC7F000).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveWorkout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC7F000),
          foregroundColor: const Color(0xFF121416),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF121416),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEditing ? Icons.check_circle_rounded : Icons.add_circle_rounded,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'Mettre à jour' : 'Enregistrer',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC7F000),
              onPrimary: Color(0xFF121416),
              surface: Color(0xFF1E2124),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E2124),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final workout = Workout(
        id: widget.existingWorkout?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        duration: int.parse(_durationController.text.trim()),
        date: _selectedDate,
        caloriesBurned: _caloriesController.text.isEmpty
            ? null
            : int.tryParse(_caloriesController.text.trim()),
        notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.existingWorkout == null) {
        await WorkoutDatabase.instance.create(workout);
      } else {
        await WorkoutDatabase.instance.update(workout);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFFC7F000)),
              const SizedBox(width: 12),
              Text(
                widget.existingWorkout == null
                    ? 'Entraînement ajouté !'
                    : 'Entraînement mis à jour !',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E2124),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
              const SizedBox(width: 12),
              Text('Erreur: $e'),
            ],
          ),
          backgroundColor: const Color(0xFF1E2124),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Helper class for workout types
class WorkoutType {
  final String name;
  final IconData icon;
  final Color color;

  WorkoutType(this.name, this.icon, this.color);
}
