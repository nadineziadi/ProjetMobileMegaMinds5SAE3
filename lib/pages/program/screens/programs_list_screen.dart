import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/program_provider.dart';
import '../models/program.dart';
import 'program_detail_screen.dart';
import 'program_generator_screen.dart';
import 'edit_program_screen.dart';

class ProgramsListScreen extends StatelessWidget {
  const ProgramsListScreen({Key? key}) : super(key: key);

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
            'Available Programs',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentGreen,
        foregroundColor: darkBg,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProgramGeneratorScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Program'),
      ),
      body: Consumer<ProgramProvider>(
        builder: (context, provider, _) {
          if (provider.programs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 75,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No programs available',
                    style: TextStyle(
                      fontSize: 18,
                      color: accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProgramGeneratorScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: darkBg),
                    label: const Text(
                      'Create Your First Program',
                      style: TextStyle(color: darkBg),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            itemCount: provider.programs.length,
            itemBuilder: (context, index) {
              final program = provider.programs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentGreen.withOpacity(0.27),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: accentGreen.withOpacity(0.2),
                    child: Icon(
                      _getIconForGoal(program.goal),
                      color: accentGreen,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    program.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: accentGreen,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 15,
                          color: accentBlue.withOpacity(0.97),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${program.durationWeeks} weeks',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.trending_up,
                          size: 15,
                          color: accentBlue.withOpacity(0.97),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.difficulty,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    color: cardBg,
                    icon: Icon(Icons.more_vert, color: accentGreen),
                    onSelected: (value) {
                      if (value == 'view') {
                        provider.selectProgram(program.id!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProgramDetailScreen(),
                          ),
                        );
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProgramScreen(program: program),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, provider, program);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20, color: accentBlue),
                            const SizedBox(width: 12),
                            const Text(
                              'View Details',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: accentGreen),
                            const SizedBox(width: 12),
                            const Text(
                              'Edit Program',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    provider.selectProgram(program.id!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProgramDetailScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProgramProvider provider,
    Program program,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF23252B),
        title: const Text(
          'Delete Program',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete "${program.name}"?\n\nThis will permanently remove the program and all its workouts, including calendar events.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // ✅ CRITICAL: Save navigators BEFORE any async operations
              final confirmDialogNavigator = Navigator.of(dialogContext);
              final loadingNavigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Close confirmation dialog
              confirmDialogNavigator.pop();

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => WillPopScope(
                  onWillPop: () async => false,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6DFD7D),
                      ),
                    ),
                  ),
                ),
              );

              try {
                // Perform deletion
                debugPrint('🔄 Starting deletion process...');
                await provider.deleteProgramWithCalendar(program);
                debugPrint('✅ Deletion process complete');

                // Close loading dialog using saved navigator
                loadingNavigator.pop();
                debugPrint('🔄 Loading dialog closed');

                // Show success message using saved scaffold messenger
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('${program.name} deleted successfully'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                debugPrint('❌ Error during deletion: $e');

                // Close loading using saved navigator
                loadingNavigator.pop();

                // Show error message using saved scaffold messenger
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error deleting program: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForGoal(String goal) {
    switch (goal) {
      case 'fat_loss':
        return Icons.local_fire_department;
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      default:
        return Icons.sports_gymnastics;
    }
  }
}
