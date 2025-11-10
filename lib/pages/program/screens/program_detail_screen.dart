import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/program_provider.dart';
import '../services/adaptation_service.dart';
import '../widgets/adaptation_dialog.dart';
import 'workout_detail_screen.dart';
import 'edit_program_screen.dart';

class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({Key? key}) : super(key: key);

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
            'Program Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
        ),
        actions: [
          Consumer<ProgramProvider>(
            builder: (context, provider, _) {
              if (provider.selectedProgram == null) return const SizedBox();
              return PopupMenuButton<String>(
                color: cardBg,
                icon: const Icon(Icons.more_vert, color: accentGreen),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProgramScreen(program: provider.selectedProgram!),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, provider);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: accentGreen),
                        const SizedBox(width: 12),
                        const Text('Edit Program', style: TextStyle(color: accentGreen)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete Program', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ProgramProvider>(
        builder: (context, provider, _) {
          final program = provider.selectedProgram;
          if (program == null) {
            return const Center(child: Text('No program selected', style: TextStyle(color: Colors.white)));
          }
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [cardBg, accentGreen.withOpacity(0.08)],
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
                      Text(
                        program.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: accentGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        program.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(icon: Icons.calendar_today, label: 'Duration', value: '${program.durationWeeks}w', accent: accentBlue),
                    _StatCard(icon: Icons.trending_up, label: 'Difficulty', value: program.difficulty, accent: accentGreen),
                    _StatCard(icon: Icons.check_circle, label: 'Completed', value: '${provider.getCompletedWorkoutsCount()}', accent: Colors.amber),
                  ],
                ),
                const SizedBox(height: 22),
                // Smart Adaptation Card
                Container(
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentGreen, width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(Icons.psychology, color: accentGreen, size: 30),
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Adaptation',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentGreen),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Analyze your progress and adjust intensity',
                              style: TextStyle(color: Colors.grey[400], fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _checkAdaptation(context, provider),
                        icon: const Icon(Icons.insights, size: 20),
                        label: const Text('Analyze'),
                        style: FilledButton.styleFrom(
                          backgroundColor: accentGreen,
                          foregroundColor: darkBg,
                          minimumSize: const Size(0, 38),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Weekly Schedule Header
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 6),
                  child: Text(
                    'Weekly Schedule',
                    style: TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.bold,
                      color: accentBlue,
                    ),
                  ),
                ),
                // Weekly Schedule List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: program.workouts.length,
                  itemBuilder: (context, index) {
                    final workout = program.workouts[index];
                    final dayNames = [
                      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
                    ];
                    final isCompleted = provider.isWorkoutCompletedToday(workout.id!);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: isCompleted ? accentGreen : Colors.grey.shade800, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCompleted ? accentGreen : Colors.grey.shade700,
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  dayNames[index].substring(0, 3),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: accentBlue,
                                  ),
                                ),
                        ),
                        title: Text(
                          workout.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentBlue,
                          ),
                        ),
                        subtitle: Text(
                          workout.isRestDay
                              ? 'Rest day'
                              : '${workout.durationMinutes} min • ${workout.exercises.length} exercises',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: accentBlue),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutDetailScreen(workout: workout),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _checkAdaptation(BuildContext context, ProgramProvider provider) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Check adaptation
    final recommendation = await provider.checkAdaptation();

    // Close loading
    if (context.mounted) Navigator.pop(context);

    // Show result
    if (context.mounted) {
      if (recommendation.shouldAdapt) {
        showDialog(
          context: context,
          builder: (context) => AdaptationDialog(
            recommendation: recommendation,
            onAccept: () async {
              // ✅ FIXED: Save navigator reference before async operations
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              // Close the adaptation dialog
              navigator.pop();
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Apply adaptation
                await provider.applyAdaptation(
                  recommendation.intensityMultiplier!,
                );

                // Close loading - use saved navigator
                navigator.pop();

                // Show success - use saved scaffoldMessenger
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Program adapted successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                // Close loading on error
                navigator.pop();
                
                // Show error
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error applying adaptation: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            onDismiss: () {
              provider.dismissAdaptation();
              Navigator.pop(context);
            },
          ),
        );
      } else {
        // No adaptation needed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Perfect Balance!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.reason,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Keep up the great work!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, ProgramProvider provider) {
    final program = provider.selectedProgram;
    if (program == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program'),
        content: Text(
          'Are you sure you want to delete "${program.name}"?\n\nThis will permanently remove the program and all its workouts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // ✅ Save navigator and messenger references
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              // Close dialog
              navigator.pop();
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Delete program
                await provider.deleteProgram(program.id!);

                // Close loading and detail screen
                navigator.pop(); // Close loading
                navigator.pop(); // Close detail screen
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('${program.name} deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Close loading on error
                navigator.pop();
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error deleting program: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;


  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,

  });

 @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: accent, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}