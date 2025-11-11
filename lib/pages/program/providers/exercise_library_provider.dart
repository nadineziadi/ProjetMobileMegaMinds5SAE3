// lib/providers/exercise_library_provider.dart
import 'package:flutter/material.dart';
import '../models/exercise_library.dart';
import '../services/database_helper.dart';
import '../services/exercise_library_service.dart'; // ✅ ADD THIS IMPORT

class ExerciseLibraryProvider extends ChangeNotifier {
  List<ExerciseLibrary> _exercises = [];
  List<ExerciseLibrary> _filteredExercises = [];
  ExerciseFilter _currentFilter = ExerciseFilter();
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<ExerciseLibrary> get exercises => _filteredExercises;
  List<ExerciseLibrary> get allExercises => _exercises;
  ExerciseFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  int get totalExercises => _exercises.length;
  int get favoriteCount => _exercises.where((e) => e.isFavorite).length;

  // Load all exercises from database
  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await DatabaseHelper.instance.getAllExercises();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search exercises
  void searchExercises(String query) {
    _searchQuery = query;
    _currentFilter = _currentFilter.copyWith(searchQuery: query);
    _applyFilter();
  }

  // Apply filter
  void applyFilter(ExerciseFilter filter) {
    _currentFilter = filter;
    _applyFilter();
  }

  // Internal filter application
  void _applyFilter() {
    if (_searchQuery.isEmpty && !_currentFilter.hasActiveFilters) {
      _filteredExercises = List.from(_exercises);
      notifyListeners();
      return;
    }

    _filteredExercises = _exercises.where((exercise) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = exercise.name.toLowerCase().contains(query);
        final matchesDescription = exercise.description.toLowerCase().contains(query);
        final matchesMuscles = exercise.muscleGroups.any(
          (muscle) => muscle.toLowerCase().contains(query),
        );
        if (!matchesName && !matchesDescription && !matchesMuscles) {
          return false;
        }
      }

      // Category filter
      if (_currentFilter.category != null &&
          exercise.category != _currentFilter.category) {
        return false;
      }

      // Difficulty filter
      if (_currentFilter.difficulty != null &&
          exercise.difficulty != _currentFilter.difficulty) {
        return false;
      }

      // Equipment filter (contains any)
      if (_currentFilter.equipment != null &&
          _currentFilter.equipment!.isNotEmpty) {
        final hasEquipment = exercise.equipment.any(
          (eq) => _currentFilter.equipment!.contains(eq),
        );
        if (!hasEquipment) return false;
      }

      // Muscle groups filter (contains any)
      if (_currentFilter.muscleGroups != null &&
          _currentFilter.muscleGroups!.isNotEmpty) {
        final hasMuscle = exercise.muscleGroups.any(
          (mg) => _currentFilter.muscleGroups!.contains(mg),
        );
        if (!hasMuscle) return false;
      }

      // Favorites only
      if (_currentFilter.favoritesOnly == true && !exercise.isFavorite) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Clear filter
  void clearFilter() {
    _currentFilter = ExerciseFilter();
    _searchQuery = '';
    _applyFilter();
  }

  // Toggle favorite
  Future<void> toggleFavorite(int exerciseId) async {
    final index = _exercises.indexWhere((e) => e.id == exerciseId);
    if (index == -1) return;

    final exercise = _exercises[index];
    final newFavoriteStatus = !exercise.isFavorite;

    try {
      await DatabaseHelper.instance.toggleExerciseFavorite(
        exerciseId,
        newFavoriteStatus,
      );

      _exercises[index] = exercise.copyWith(isFavorite: newFavoriteStatus);
      _applyFilter();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Get exercise by ID
  ExerciseLibrary? getExerciseById(int id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get exercises by category
  List<ExerciseLibrary> getExercisesByCategory(String category) {
    return _exercises.where((e) => e.category == category).toList();
  }

  // Get favorite exercises
  List<ExerciseLibrary> getFavoriteExercises() {
    return _exercises.where((e) => e.isFavorite).toList();
  }

  // Get categories with counts
  Map<String, int> getCategoryCounts() {
    final Map<String, int> counts = {};
    for (var exercise in _exercises) {
      counts[exercise.category] = (counts[exercise.category] ?? 0) + 1;
    }
    return counts;
  }

  // Get difficulty counts
  Map<String, int> getDifficultyCounts() {
    final Map<String, int> counts = {};
    for (var exercise in _exercises) {
      counts[exercise.difficulty] = (counts[exercise.difficulty] ?? 0) + 1;
    }
    return counts;
  }

  // Add custom exercise
  Future<void> addExercise(ExerciseLibrary exercise) async {
    try {
      final id = await DatabaseHelper.instance.insertExercise(exercise);
      final newExercise = exercise.copyWith(id: id);
      _exercises.add(newExercise);
      _applyFilter();
    } catch (e) {
      debugPrint('Error adding exercise: $e');
      rethrow;
    }
  }

  // Update exercise
  Future<void> updateExercise(ExerciseLibrary exercise) async {
    try {
      await DatabaseHelper.instance.updateExercise(exercise);
      final index = _exercises.indexWhere((e) => e.id == exercise.id);
      if (index != -1) {
        _exercises[index] = exercise;
        _applyFilter();
      }
    } catch (e) {
      debugPrint('Error updating exercise: $e');
      rethrow;
    }
  }

  // Delete exercise
  Future<void> deleteExercise(int exerciseId) async {
    try {
      await DatabaseHelper.instance.deleteExercise(exerciseId);
      _exercises.removeWhere((e) => e.id == exerciseId);
      _applyFilter();
    } catch (e) {
      debugPrint('Error deleting exercise: $e');
      rethrow;
    }
  }

  // ✅ FIXED: Seed database with default exercises
  Future<void> seedDefaultExercises() async {
    if (_exercises.isNotEmpty) return;

    try {
      final seedExercises = ExerciseLibraryService.getSeedExercises(); // ✅ NOW USES THE SERVICE
      for (var exercise in seedExercises) {
        await DatabaseHelper.instance.insertExercise(exercise);
      }
      await loadExercises();
      debugPrint('✅ Successfully seeded ${seedExercises.length} exercises');
    } catch (e) {
      debugPrint('❌ Error seeding exercises: $e');
    }
  }
}