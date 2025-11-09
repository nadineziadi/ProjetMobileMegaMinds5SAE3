import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/program_generator_service.dart';
import '../services/database_helper.dart';
import '../providers/program_provider.dart';
import 'program_detail_screen.dart';

class ProgramGeneratorScreen extends StatefulWidget {
  const ProgramGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<ProgramGeneratorScreen> createState() => _ProgramGeneratorScreenState();
}

class _ProgramGeneratorScreenState extends State<ProgramGeneratorScreen> {
  int _currentStep = 0;
  
  // User selections
  String _selectedGoal = 'fat_loss';
  String _selectedEquipment = 'none';
  int _selectedDays = 3;
  int _selectedDuration = 30;
  String _selectedExperience = 'beginner';

  final List<String> _goals = ['fat_loss', 'strength', 'cardio', 'flexibility'];
  final List<String> _equipment = ['none', 'dumbbells', 'full_gym'];
  final List<int> _daysOptions = [3, 4, 5, 6];
  final List<int> _durationOptions = [20, 30, 45, 60];
  final List<String> _experienceLevels = ['beginner', 'intermediate', 'advanced'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Program'),
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep++);
          } else {
            _generateProgram();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 4 ? 'Generate Program' : 'Continue'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Goal
          Step(
            title: const Text('Your Goal'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What is your fitness goal?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ..._goals.map((goal) => RadioListTile<String>(
                      title: Text(_getGoalLabel(goal)),
                      subtitle: Text(_getGoalDescription(goal)),
                      value: goal,
                      groupValue: _selectedGoal,
                      onChanged: (value) {
                        setState(() => _selectedGoal = value!);
                      },
                    )),
              ],
            ),
          ),

          // Step 2: Equipment
          Step(
            title: const Text('Equipment'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What equipment do you have access to?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ..._equipment.map((equip) => RadioListTile<String>(
                      title: Text(_getEquipmentLabel(equip)),
                      subtitle: Text(_getEquipmentDescription(equip)),
                      value: equip,
                      groupValue: _selectedEquipment,
                      onChanged: (value) {
                        setState(() => _selectedEquipment = value!);
                      },
                    )),
              ],
            ),
          ),

          // Step 3: Days per week
          Step(
            title: const Text('Frequency'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How many days per week can you train?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ..._daysOptions.map((days) => RadioListTile<int>(
                      title: Text('$days days per week'),
                      subtitle: Text(_getDaysDescription(days)),
                      value: days,
                      groupValue: _selectedDays,
                      onChanged: (value) {
                        setState(() => _selectedDays = value!);
                      },
                    )),
              ],
            ),
          ),

          // Step 4: Duration
          Step(
            title: const Text('Duration'),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How long should each workout be?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ..._durationOptions.map((duration) => RadioListTile<int>(
                      title: Text('$duration minutes'),
                      value: duration,
                      groupValue: _selectedDuration,
                      onChanged: (value) {
                        setState(() => _selectedDuration = value!);
                      },
                    )),
              ],
            ),
          ),

          // Step 5: Experience
          Step(
            title: const Text('Experience Level'),
            isActive: _currentStep >= 4,
            state: _currentStep > 4 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What is your fitness experience level?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ..._experienceLevels.map((level) => RadioListTile<String>(
                      title: Text(_getExperienceLabel(level)),
                      subtitle: Text(_getExperienceDescription(level)),
                      value: level,
                      groupValue: _selectedExperience,
                      onChanged: (value) {
                        setState(() => _selectedExperience = value!);
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateProgram() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your custom program...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Generate program
    final program = ProgramGeneratorService.generateProgram(
      goal: _selectedGoal,
      equipment: _selectedEquipment,
      daysPerWeek: _selectedDays,
      durationMinutes: _selectedDuration,
      experience: _selectedExperience,
    );

    // Save to database
    await DatabaseHelper.instance.insertProgram(program);

    // Reload programs
    await context.read<ProgramProvider>().loadPrograms();

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Show success and navigate
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to programs list
      Navigator.pop(context);
    }
  }

  String _getGoalLabel(String goal) {
    switch (goal) {
      case 'fat_loss':
        return 'Fat Loss';
      case 'strength':
        return 'Build Strength';
      case 'cardio':
        return 'Improve Cardio';
      case 'flexibility':
        return 'Increase Flexibility';
      default:
        return goal;
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'fat_loss':
        return 'Burn calories and lose weight';
      case 'strength':
        return 'Build muscle and get stronger';
      case 'cardio':
        return 'Improve endurance and heart health';
      case 'flexibility':
        return 'Improve mobility and reduce injury risk';
      default:
        return '';
    }
  }

  String _getEquipmentLabel(String equip) {
    switch (equip) {
      case 'none':
        return 'No Equipment';
      case 'dumbbells':
        return 'Dumbbells';
      case 'full_gym':
        return 'Full Gym Access';
      default:
        return equip;
    }
  }

  String _getEquipmentDescription(String equip) {
    switch (equip) {
      case 'none':
        return 'Bodyweight exercises only';
      case 'dumbbells':
        return 'Access to dumbbells or resistance bands';
      case 'full_gym':
        return 'Complete gym with all equipment';
      default:
        return '';
    }
  }

  String _getDaysDescription(int days) {
    if (days == 3) return 'Good for beginners';
    if (days == 4) return 'Balanced approach';
    if (days == 5) return 'Serious commitment';
    return 'Advanced training';
  }

  String _getExperienceLabel(String level) {
    return level[0].toUpperCase() + level.substring(1);
  }

  String _getExperienceDescription(String level) {
    switch (level) {
      case 'beginner':
        return 'New to fitness or returning after a break';
      case 'intermediate':
        return '6+ months of consistent training';
      case 'advanced':
        return '2+ years of regular training';
      default:
        return '';
    }
  }
}