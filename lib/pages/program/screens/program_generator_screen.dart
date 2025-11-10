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
    const darkBg = Color(0xFF181A20);
    const cardBg = Color(0xFF23252B);
    const accentGreen = Color(0xFF6DFD7D);
    const accentBlue = Color(0xFF4886FE);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: accentGreen),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accentBlue, accentGreen],
          ).createShader(bounds),
          child: const Text(
            'Create Custom Program',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(primary: accentGreen, surface: cardBg),
          cardColor: cardBg,
        ),
        child: Stepper(
          type: StepperType.vertical,
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
              padding: const EdgeInsets.only(top: 16, left: 4, right: 4),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: darkBg,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    child: Text(_currentStep == 4 ? 'Generate Program' : 'Continue'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    style: TextButton.styleFrom(foregroundColor: accentBlue),
                    child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text('Your Goal', style: TextStyle(color: accentGreen, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What is your fitness goal?', style: TextStyle(fontSize: 16, color: Colors.grey[200])),
                    const SizedBox(height: 14),
                    ..._goals.map((goal) => Card(
                          color: cardBg,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: RadioListTile<String>(
                            title: Text(_getGoalLabel(goal), style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                            subtitle: Text(_getGoalDescription(goal), style: TextStyle(color: Colors.grey[400])),
                            value: goal,
                            groupValue: _selectedGoal,
                            activeColor: accentGreen,
                            onChanged: (value) { setState(() => _selectedGoal = value!); },
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Step(
              title: Text('Equipment', style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What equipment do you have access to?', style: TextStyle(fontSize: 16, color: Colors.grey[200])),
                    const SizedBox(height: 14),
                    ..._equipment.map((equip) => Card(
                          color: cardBg,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: RadioListTile<String>(
                            title: Text(_getEquipmentLabel(equip), style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
                            subtitle: Text(_getEquipmentDescription(equip), style: TextStyle(color: Colors.grey[400])),
                            value: equip,
                            groupValue: _selectedEquipment,
                            activeColor: accentBlue,
                            onChanged: (value) { setState(() => _selectedEquipment = value!); },
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Step(
              title: Text('Frequency', style: TextStyle(color: accentGreen, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How many days per week can you train?', style: TextStyle(fontSize: 16, color: Colors.grey[200])),
                    const SizedBox(height: 14),
                    ..._daysOptions.map((days) => Card(
                          color: cardBg,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: RadioListTile<int>(
                            title: Text('$days days per week', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                            subtitle: Text(_getDaysDescription(days), style: TextStyle(color: Colors.grey[400])),
                            value: days,
                            groupValue: _selectedDays,
                            activeColor: accentGreen,
                            onChanged: (value) { setState(() => _selectedDays = value!); },
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Step(
              title: Text('Duration', style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How long should each workout be?', style: TextStyle(fontSize: 16, color: Colors.grey[200])),
                    const SizedBox(height: 14),
                    ..._durationOptions.map((duration) => Card(
                          color: cardBg,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: RadioListTile<int>(
                            title: Text('$duration minutes', style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
                            value: duration,
                            groupValue: _selectedDuration,
                            activeColor: accentBlue,
                            onChanged: (value) { setState(() => _selectedDuration = value!); },
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Step(
              title: Text('Experience Level', style: TextStyle(color: accentGreen, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 4,
              state: _currentStep > 4 ? StepState.complete : StepState.indexed,
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What is your fitness experience level?', style: TextStyle(fontSize: 16, color: Colors.grey[200])),
                    const SizedBox(height: 14),
                    ..._experienceLevels.map((level) => Card(
                          color: cardBg,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: RadioListTile<String>(
                            title: Text(_getExperienceLabel(level), style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                            subtitle: Text(_getExperienceDescription(level), style: TextStyle(color: Colors.grey[400])),
                            value: level,
                            groupValue: _selectedExperience,
                            activeColor: accentGreen,
                            onChanged: (value) { setState(() => _selectedExperience = value!); },
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateProgram() async {
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

    final program = ProgramGeneratorService.generateProgram(
      goal: _selectedGoal,
      equipment: _selectedEquipment,
      daysPerWeek: _selectedDays,
      durationMinutes: _selectedDuration,
      experience: _selectedExperience,
    );

    await DatabaseHelper.instance.insertProgram(program);
    await context.read<ProgramProvider>().loadPrograms();

    if (mounted) Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
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
