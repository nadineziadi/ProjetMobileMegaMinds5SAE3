import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/program.dart';
import '../providers/program_provider.dart';

class EditProgramScreen extends StatefulWidget {
  final Program program;
  const EditProgramScreen({Key? key, required this.program}) : super(key: key);

  @override
  State<EditProgramScreen> createState() => _EditProgramScreenState();
}

class _EditProgramScreenState extends State<EditProgramScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedDifficulty;
  late int _selectedWeeks;

  final List<String> _difficulties = ['easy', 'medium', 'hard'];
  final List<int> _weekOptions = [2, 4, 6, 8, 12];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.program.name);
    _descriptionController = TextEditingController(text: widget.program.description);
    _selectedDifficulty = widget.program.difficulty;
    _selectedWeeks = widget.program.durationWeeks;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF181A20);
    const cardBg = Color(0xFF23252B);
    const accentGreen = Color(0xFF6DFD7D);
    const accentBlue = Color(0xFF4886FE);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        iconTheme: const IconThemeData(color: accentGreen),
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accentBlue, accentGreen],
          ).createShader(bounds),
          child: const Text(
            'Edit Program',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: [
            // Editable Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[900]!, width: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.09),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Program Name', accentGreen),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter program name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _label('Description', accentBlue),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter program description',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _label('Difficulty Level', accentGreen),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: _difficulties.map((diff) {
                      final isSelected = _selectedDifficulty == diff;
                      return ChoiceChip(
                        label: Text(
                          diff[0].toUpperCase() + diff.substring(1),
                          style: TextStyle(color: isSelected ? darkBg : accentGreen),
                        ),
                        selected: isSelected,
                        selectedColor: accentGreen,
                        backgroundColor: cardBg,
                        side: BorderSide(color: accentGreen, width: 2),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedDifficulty = diff);
                        },
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  _label('Duration (Weeks)', accentBlue),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: _weekOptions.map((weeks) {
                      final isSelected = _selectedWeeks == weeks;
                      return ChoiceChip(
                        label: Text(
                          '$weeks weeks',
                          style: TextStyle(color: isSelected ? darkBg : accentBlue),
                        ),
                        selected: isSelected,
                        selectedColor: accentBlue,
                        backgroundColor: cardBg,
                        side: BorderSide(color: accentBlue, width: 2),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedWeeks = weeks);
                        },
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: Icon(Icons.save, color: darkBg),
                      label: Text('Save Changes', style: TextStyle(fontSize: 16, color: darkBg)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String txt, Color color) {
    return Text(
      txt,
      style: TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  void _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a program name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final updatedProgram = Program(
      id: widget.program.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      goal: widget.program.goal,
      durationWeeks: _selectedWeeks,
      workouts: widget.program.workouts,
      difficulty: _selectedDifficulty,
      equipment: widget.program.equipment,
    );

    await context.read<ProgramProvider>().updateProgram(updatedProgram);

    if (mounted) Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
