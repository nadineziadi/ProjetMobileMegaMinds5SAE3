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
    _descriptionController =
        TextEditingController(text: widget.program.description);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Program'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Name
            const Text(
              'Program Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter program name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter program description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Difficulty
            const Text(
              'Difficulty Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'easy', label: Text('Easy')),
                ButtonSegment(value: 'medium', label: Text('Medium')),
                ButtonSegment(value: 'hard', label: Text('Hard')),
              ],
              selected: {_selectedDifficulty},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedDifficulty = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Duration in weeks
            const Text(
              'Duration (Weeks)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _weekOptions.map((weeks) {
                return ChoiceChip(
                  label: Text('$weeks weeks'),
                  selected: _selectedWeeks == weeks,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedWeeks = weeks);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a program name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Create updated program
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

    // Update in database
    await context.read<ProgramProvider>().updateProgram(updatedProgram);

    // Close loading
    if (mounted) Navigator.pop(context);

    // Show success and go back
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to programs list
    }
  }
}