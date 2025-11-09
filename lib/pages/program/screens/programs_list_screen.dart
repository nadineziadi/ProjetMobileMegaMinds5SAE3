import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/program_provider.dart';
import 'program_detail_screen.dart';
import 'program_generator_screen.dart';
import 'edit_program_screen.dart';

class ProgramsListScreen extends StatelessWidget {
  const ProgramsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Programs'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProgramGeneratorScreen(),
            ),
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
                  Icon(Icons.fitness_center, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'No programs available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProgramGeneratorScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Your First Program'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.programs.length,
            itemBuilder: (context, index) {
              final program = provider.programs[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      _getIconForGoal(program.goal),
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    program.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${program.durationWeeks} weeks'),
                        const SizedBox(width: 16),
                        Icon(Icons.trending_up, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(program.difficulty),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
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
                        _showDeleteDialog(context, provider, program.id!,
                            program.name);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 12),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Edit Program'),
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

  void _showDeleteDialog(BuildContext context, ProgramProvider provider,
      int programId, String programName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program'),
        content: Text(
          'Are you sure you want to delete "$programName"?\n\nThis will permanently remove the program and all its workouts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Delete program
              await provider.deleteProgram(programId);

              // Close loading
              if (context.mounted) Navigator.pop(context);

              // Show success message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$programName deleted successfully'),
                    backgroundColor: Colors.green,
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