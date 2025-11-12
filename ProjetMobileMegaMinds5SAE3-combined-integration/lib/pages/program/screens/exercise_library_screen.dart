// lib/screens/exercise_library_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_library_provider.dart';
import '../models/exercise_library.dart';
import '../services/exercise_library_service.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedDifficulty = 'all';
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ExerciseLibraryProvider>().loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        elevation: 0,
        iconTheme: const IconThemeData(color: accentGreen),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accentBlue, accentGreen],
          ).createShader(bounds),
          child: const Text(
            'Exercise Library',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
        ),
        actions: [
          Consumer<ExerciseLibraryProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                  color: _showFavoritesOnly ? Colors.red : accentGreen,
                ),
                onPressed: () {
                  setState(() => _showFavoritesOnly = !_showFavoritesOnly);
                  _applyFilters();
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: accentGreen),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Consumer<ExerciseLibraryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6DFD7D)),
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: accentGreen),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchExercises('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    provider.searchExercises(value);
                  },
                ),
              ),

              // Filter Chips
              _buildFilterChips(provider, accentGreen, accentBlue),

              // Exercise Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.exercises.length} exercises',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    if (provider.currentFilter.hasActiveFilters ||
                        _searchController.text.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedCategory = 'all';
                            _selectedDifficulty = 'all';
                            _showFavoritesOnly = false;
                          });
                          provider.clearFilter();
                        },
                        icon: Icon(Icons.clear, size: 16, color: accentGreen),
                        label: Text(
                          'Clear filters',
                          style: TextStyle(color: accentGreen),
                        ),
                      ),
                  ],
                ),
              ),

              // Exercise List
              Expanded(
                child: provider.exercises.isEmpty
                    ? _buildEmptyState(accentGreen)
                    : RefreshIndicator(
                        color: accentGreen,
                        onRefresh: () => provider.loadExercises(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: provider.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = provider.exercises[index];
                            return _ExerciseCard(
                              exercise: exercise,
                              accentGreen: accentGreen,
                              accentBlue: accentBlue,
                              cardBg: cardBg,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExerciseDetailScreen(
                                      exercise: exercise,
                                    ),
                                  ),
                                );
                              },
                              onFavoriteToggle: () {
                                provider.toggleFavorite(exercise.id!);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(
    ExerciseLibraryProvider provider,
    Color accentGreen,
    Color accentBlue,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: _selectedCategory == 'all',
            color: accentGreen,
            onTap: () {
              setState(() => _selectedCategory = 'all');
              _applyFilters();
            },
          ),
          _CategoryChip(
            label: 'Chest',
            isSelected: _selectedCategory == 'chest',
            color: accentBlue,
            icon: Icons.fitness_center,
            onTap: () {
              setState(() => _selectedCategory = 'chest');
              _applyFilters();
            },
          ),
          _CategoryChip(
            label: 'Back',
            isSelected: _selectedCategory == 'back',
            color: accentBlue,
            icon: Icons.accessibility_new,
            onTap: () {
              setState(() => _selectedCategory = 'back');
              _applyFilters();
            },
          ),
          _CategoryChip(
            label: 'Legs',
            isSelected: _selectedCategory == 'legs',
            color: accentBlue,
            icon: Icons.directions_run,
            onTap: () {
              setState(() => _selectedCategory = 'legs');
              _applyFilters();
            },
          ),
          _CategoryChip(
            label: 'Shoulders',
            isSelected: _selectedCategory == 'shoulders',
            color: accentBlue,
            icon: Icons.sports_martial_arts,
            onTap: () {
              setState(() => _selectedCategory = 'shoulders');
              _applyFilters();
            },
          ),
          _CategoryChip(
            label: 'Arms',
            isSelected: _selectedCategory == 'arms',
            color: accentBlue,
            icon: Icons.sports_handball,
            onTap: () {
              setState(() => _selectedCategory = 'arms');
              _applyFilters();
            },
          ),
          _CategoryChip(
            label: 'Core',
            isSelected: _selectedCategory == 'core',
            color: accentBlue,
            icon: Icons.auto_awesome,
            onTap: () {
              setState(() => _selectedCategory = 'core');
              _applyFilters();
            },
          ),
          _CategoryChip(
            label: 'Cardio',
            isSelected: _selectedCategory == 'cardio',
            color: accentBlue,
            icon: Icons.favorite,
            onTap: () {
              setState(() => _selectedCategory = 'cardio');
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    final provider = context.read<ExerciseLibraryProvider>();
    provider.applyFilter(
      ExerciseFilter(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        difficulty: _selectedDifficulty == 'all' ? null : _selectedDifficulty,
        favoritesOnly: _showFavoritesOnly,
        searchQuery: _searchController.text,
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    const cardBg = Color(0xFF23252B);
    const accentGreen = Color(0xFF6DFD7D);
    const accentBlue = Color(0xFF4886FE);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Exercises',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Difficulty Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentBlue,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildDifficultyChip(
                    'All',
                    'all',
                    accentGreen,
                    setModalState,
                  ),
                  _buildDifficultyChip(
                    'Beginner',
                    'beginner',
                    Colors.green,
                    setModalState,
                  ),
                  _buildDifficultyChip(
                    'Intermediate',
                    'intermediate',
                    Colors.orange,
                    setModalState,
                  ),
                  _buildDifficultyChip(
                    'Advanced',
                    'advanced',
                    Colors.red,
                    setModalState,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: const Color(0xFF181A20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(
    String label,
    String value,
    Color color,
    StateSetter setModalState,
  ) {
    final isSelected = _selectedDifficulty == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          setState(() {
            _selectedDifficulty = value;
          });
        });
      },
      selectedColor: color,
      backgroundColor: Colors.grey[800],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState(Color accentGreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : color),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: color,
        backgroundColor: Colors.grey[800],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseLibrary exercise;
  final Color accentGreen;
  final Color accentBlue;
  final Color cardBg;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _ExerciseCard({
    required this.exercise,
    required this.accentGreen,
    required this.accentBlue,
    required this.cardBg,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentGreen.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: _getCategoryColor(exercise.category).withOpacity(0.2),
          child: Icon(
            _getCategoryIcon(exercise.category),
            color: _getCategoryColor(exercise.category),
            size: 26,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: exercise.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                _DifficultyBadge(difficulty: exercise.difficulty),
                const SizedBox(width: 8),
                Icon(Icons.category, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  exercise.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              exercise.muscleGroups
                  .take(2)
                  .map((m) => ExerciseLibraryService.getMuscleGroupName(m))
                  .join(', '),
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: accentBlue,
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'chest':
        return Colors.red;
      case 'back':
        return Colors.blue;
      case 'legs':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.purple;
      case 'core':
        return Colors.amber;
      case 'cardio':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.accessibility_new;
      case 'legs':
        return Icons.directions_run;
      case 'shoulders':
        return Icons.sports_martial_arts;
      case 'arms':
        return Icons.sports_handball;
      case 'core':
        return Icons.auto_awesome;
      case 'cardio':
        return Icons.favorite;
      default:
        return Icons.sports_gymnastics;
    }
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}