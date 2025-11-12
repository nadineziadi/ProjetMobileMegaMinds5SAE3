// lib/screens/exercise_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ ADD THIS
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/exercise_library.dart';
import '../providers/exercise_library_provider.dart';
import '../services/exercise_library_service.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseLibrary exercise;

  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

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
        title: Text(
          exercise.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<ExerciseLibraryProvider>(
            builder: (context, provider, _) {
              final isFavorite = provider
                  .getExerciseById(exercise.id!)
                  ?.isFavorite ?? exercise.isFavorite;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : accentGreen,
                ),
                onPressed: () {
                  provider.toggleFavorite(exercise.id!);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail / Placeholder
            _buildVideoSection(context, accentGreen, accentBlue, cardBg),
            const SizedBox(height: 24),

            // Quick Info Cards
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.category,
                    label: 'Category',
                    value: exercise.category.toUpperCase(),
                    color: accentBlue,
                    cardBg: cardBg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.speed,
                    label: 'Difficulty',
                    value: exercise.difficulty.toUpperCase(),
                    color: _getDifficultyColor(exercise.difficulty),
                    cardBg: cardBg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            _SectionHeader(title: 'About', color: accentGreen),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                exercise.description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[300],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Muscle Groups
            _SectionHeader(title: 'Target Muscles', color: accentBlue),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.muscleGroups.map((muscle) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: accentBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ExerciseLibraryService.getMuscleGroupName(muscle),
                        style: TextStyle(
                          color: accentBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Equipment
            _SectionHeader(title: 'Equipment Needed', color: accentGreen),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.equipment.map((equip) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.build_circle,
                        size: 16,
                        color: accentGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ExerciseLibraryService.getEquipmentName(equip),
                        style: TextStyle(
                          color: accentGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Instructions
            _SectionHeader(title: 'How To Perform', color: accentBlue),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exercise.instructions.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: accentBlue.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: accentBlue, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: accentBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tips
            if (exercise.tips.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(title: 'Pro Tips', color: accentGreen),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exercise.tips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 18,
                            color: accentGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Common Mistakes
            if (exercise.commonMistakes.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(title: 'Common Mistakes', color: Colors.red),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exercise.commonMistakes.map((mistake) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 18,
                            color: Colors.red[300],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              mistake,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(
    BuildContext context,
    Color accentGreen,
    Color accentBlue,
    Color cardBg,
  ) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Placeholder or thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: accentGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Video Demonstration',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Play button overlay
          if (exercise.videoUrl != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openVideo(context, exercise.videoUrl!),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentGreen.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 32,
                        color: Color(0xFF181A20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ FIXED: Better video opening with error handling
  Future<void> _openVideo(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Try to launch with external application first
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // If that fails, try platform default
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      
      if (!launched) {
        // Show error to user with copy option
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open video. Please install YouTube app or a browser.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Copy URL',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video URL copied to clipboard'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening video: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color cardBg;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}