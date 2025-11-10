import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/program_provider.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({Key? key, required this.workout}) : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isCompleted = false;
  int? _fatigueLevel;
  final _notesController = TextEditingController();

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
          child: Text(
            widget.workout.name,
            style: const TextStyle(
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [cardBg, accentGreen.withOpacity(0.10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                  Text(widget.workout.description, style: TextStyle(fontSize: 16, color: Colors.grey[100])),
                  if (!widget.workout.isRestDay) ...[
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 18, color: accentGreen),
                        const SizedBox(width: 6),
                        Text('${widget.workout.durationMinutes} minutes', style: TextStyle(color: accentBlue)),
                        const SizedBox(width: 17),
                        Icon(Icons.fitness_center, size: 18, color: accentBlue),
                        const SizedBox(width: 6),
                        Text('${widget.workout.exercises.length} exercises', style: TextStyle(color: accentGreen)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Exercises List
            if (!widget.workout.isRestDay)
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exercises', style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold, color: accentGreen)),
                    const SizedBox(height: 11),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.workout.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = widget.workout.exercises[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: accentBlue.withOpacity(0.12),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: accentBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: TextStyle(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.bold,
                                            color: accentGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${exercise.sets} sets × ${exercise.reps} reps',
                                          style: TextStyle(color: accentBlue, fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 11),
                              Text(
                                exercise.description,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              if (exercise.equipment != null && exercise.equipment!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.sports, size: 16, color: accentGreen),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Equipment: ${exercise.equipment}',
                                      style: TextStyle(fontSize: 12, color: accentGreen),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            // Log/Edit Section
            Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Log Your Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentBlue)),
                    const SizedBox(height: 14),
                    Card(
                      color: cardBg,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: accentGreen,
                              title: Text('Mark as completed', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                              value: _isCompleted,
                              onChanged: (value) {
                                setState(() => _isCompleted = value ?? false);
                              },
                            ),
                            if (!widget.workout.isRestDay) ...[
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                'How fatigued do you feel? (1 = Easy, 5 = Very Hard)',
                                style: TextStyle(fontWeight: FontWeight.w500, color: accentBlue),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: List.generate(5, (index) {
                                  final level = index + 1;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _fatigueLevel = level);
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _fatigueLevel == level ? accentBlue : cardBg,
                                            border: Border.all(color: accentBlue, width: 2),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$level',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: _fatigueLevel == level ? darkBg : accentBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getLevelLabel(level),
                                          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Add notes about your workout...',
                                  hintStyle: TextStyle(color: Colors.grey.shade700),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: cardBg,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context.read<ProgramProvider>().logWorkout(
                            widget.workout.id!,
                            _isCompleted,
                            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                            fatigueLevel: _fatigueLevel,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Workout logged successfully!'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(Icons.check, color: darkBg),
                        label: Text('Log Workout', style: TextStyle(fontSize: 16, color: darkBg)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
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

  String _getLevelLabel(int level) {
    switch (level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Light';
      case 3:
        return 'Moderate';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
