import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../services/workout_database.dart';
import 'workout_form_screen.dart';
import 'workout_detail_screen.dart';
import '../widgets/workout_recommendation_card.dart';
import '../widgets/statistics_bottom_sheet.dart';
import '../widgets/workout_list_item.dart';
import '../utils/workout_utils.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Workout>> _workoutsFuture;
  late AnimationController _fabController;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  DateTimeRange? _dateRange;
  
  final int _itemsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _refreshWorkouts();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshWorkouts() {
    setState(() {
      _workoutsFuture = WorkoutDatabase.instance.readAll();
      _currentPage = 0;
    });
  }

  List<Workout> _filterWorkouts(List<Workout> workouts) {
    var filtered = workouts;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((w) =>
          w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.type.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Type filter
    if (_selectedFilter != 'Tous') {
      filtered = filtered.where((w) => w.type == _selectedFilter).toList();
    }

    // Date range filter
    if (_dateRange != null) {
      filtered = filtered.where((w) =>
          w.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
          w.date.isBefore(_dateRange!.end.add(const Duration(days: 1)))).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  List<Workout> _paginateWorkouts(List<Workout> workouts) {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, workouts.length);
    
    if (start >= workouts.length) return [];
    return workouts.sublist(start, end);
  }

  void _showStatistics(List<Workout> allWorkouts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatisticsBottomSheet(workouts: allWorkouts),
    );
  }

  void _showRecommendationPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF353A40), Color(0xFF121416)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC7F000), Color(0xFFA8D000)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Recommandation AI",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: WorkoutRecommendationCard(
                    onWorkoutCreated: () {
                      Navigator.pop(context);
                      _refreshWorkouts();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC7F000),
              surface: Color(0xFF1E2124),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _currentPage = 0;
      });
    }
  }

  void _deleteWorkout(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2124),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                "Supprimer ?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          "Cette action est irréversible. L'entraînement sera définitivement supprimé.",
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await WorkoutDatabase.instance.delete(id);
      _refreshWorkouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Entraînement supprimé avec succès",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E2124),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            elevation: 8,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF353A40), Color(0xFF121416)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Workout>>(
            future: _workoutsFuture,
            builder: (context, snapshot) {
              final allWorkouts = snapshot.data ?? [];
              final filteredWorkouts = _filterWorkouts(allWorkouts);
              final paginatedWorkouts = _paginateWorkouts(filteredWorkouts);
              final totalPages = (filteredWorkouts.length / _itemsPerPage).ceil();

              return CustomScrollView(
                slivers: [
                  // Header with Stats Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFC7F000), Color(0xFFA8D000)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFC7F000).withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mes Entraînements",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1,
                                        height: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Restez motivé • Progressez chaque jour",
                                      style: TextStyle(
                                        color: Color(0xFF9E9E9E),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showStatistics(allWorkouts),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC7F000).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFC7F000).withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart_rounded,
                                    color: Color(0xFFC7F000),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2124),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _currentPage = 0;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Rechercher un entraînement...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFFC7F000),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                        _currentPage = 0;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildFilterChip('Tous'),
                          _buildFilterChip('Cardio'),
                          _buildFilterChip('Force'),
                          _buildFilterChip('Yoga'),
                          _buildFilterChip('HIIT'),
                          _buildFilterChip('Étirement'),
                          _buildFilterChip('CrossFit'),
                          _buildFilterChip('Natation'),
                          _buildFilterChip('Course'),
                          _buildFilterChip('Cyclisme'),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showDateRangePicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _dateRange != null
                                    ? const Color(0xFFC7F000).withOpacity(0.15)
                                    : const Color(0xFF1E2124),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _dateRange != null
                                      ? const Color(0xFFC7F000).withOpacity(0.5)
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: _dateRange != null
                                        ? const Color(0xFFC7F000)
                                        : Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _dateRange != null ? 'Filtré' : 'Dates',
                                    style: TextStyle(
                                      color: _dateRange != null
                                          ? const Color(0xFFC7F000)
                                          : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (_dateRange != null) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _dateRange = null;
                                          _currentPage = 0;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Color(0xFFC7F000),
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Results count
                  if (snapshot.connectionState == ConnectionState.done)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Text(
                          "${filteredWorkouts.length} résultat${filteredWorkouts.length > 1 ? 's' : ''}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Content
                  if (snapshot.connectionState == ConnectionState.waiting)
                    SliverToBoxAdapter(
                      child: _buildLoadingState(),
                    )
                  else if (snapshot.hasError)
                    SliverToBoxAdapter(
                      child: _buildErrorState(snapshot),
                    )
                  else if (filteredWorkouts.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final workout = paginatedWorkouts[index];
                            return WorkoutListItem(
                              workout: workout,
                              index: index,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkoutDetailScreen(workout: workout),
                                  ),
                                );
                                _refreshWorkouts();
                              },
                              onDelete: () => _deleteWorkout(workout.id!),
                            );
                          },
                          childCount: paginatedWorkouts.length,
                        ),
                      ),
                    ),

                  // Pagination Controls
                  if (filteredWorkouts.isNotEmpty && totalPages > 1)
                    SliverToBoxAdapter(
                      child: _buildPaginationControls(totalPages),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _fabController,
            child: FloatingActionButton(
              heroTag: 'ai_fab',
              onPressed: _showRecommendationPopup,
              backgroundColor: const Color(0xFF1E2124),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC7F000), Color(0xFFA8D000)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ScaleTransition(
            scale: _fabController,
            child: FloatingActionButton(
              heroTag: 'add_fab',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutFormScreen()),
                );
                _refreshWorkouts();
              },
              backgroundColor: const Color(0xFFC7F000),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final color = label == 'Tous' ? const Color(0xFFC7F000) : WorkoutUtils.getWorkoutColor(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _currentPage = 0;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF1E2124),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFC7F000).withOpacity(0.2),
                  const Color(0xFFC7F000).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFFC7F000),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Chargement...",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AsyncSnapshot<List<Workout>> snapshot) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              "Une erreur est survenue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${snapshot.error}",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFC7F000).withOpacity(0.15),
                  const Color(0xFFC7F000).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty || _selectedFilter != 'Tous' || _dateRange != null
                  ? Icons.search_off
                  : Icons.fitness_center,
              color: const Color(0xFFC7F000),
              size: 90,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'Tous' || _dateRange != null
                ? "Aucun résultat"
                : "Aucun entraînement",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'Tous' || _dateRange != null
                  ? "Aucun entraînement ne correspond\nà vos critères de recherche"
                  : "Commencez votre parcours fitness\nen ajoutant votre premier entraînement",
              style: const TextStyle(
                color: Color(0xFF7E7E7E),
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2124),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: _currentPage > 0
                  ? const Color(0xFFC7F000)
                  : Colors.white30,
            ),
          ),
          Text(
            "Page ${_currentPage + 1} sur $totalPages",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: _currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: _currentPage < totalPages - 1
                  ? const Color(0xFFC7F000)
                  : Colors.white30,
            ),
          ),
        ],
      ),
    );
  }
}