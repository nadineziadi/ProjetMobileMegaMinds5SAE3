import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class UserService {
  static const String _usersBoxName = 'users';
  static const String _preferencesBoxName = 'preferences';
  static const String _currentUserIdKey = 'current_user_id';
  
  Box<UserProfile>? _usersBox;
  Box<dynamic>? _preferencesBox; // Box séparée pour les préférences
  static bool _adaptersRegistered = false;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!_adaptersRegistered) {
      Hive.registerAdapter(UserProfileAdapter());
      Hive.registerAdapter(WeightEntryAdapter());
      _adaptersRegistered = true;
    }
    _usersBox = await Hive.openBox<UserProfile>(_usersBoxName);
    _preferencesBox = await Hive.openBox(_preferencesBoxName);
  }

  Future<UserProfile> createUser({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String fitnessLevel,
    required String goal,
  }) async {
    final user = UserProfile(
      id: const Uuid().v4(),
      name: name,
      email: email,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      fitnessLevel: fitnessLevel,
      goal: goal,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      weightHistory: [
        WeightEntry(date: DateTime.now(), weight: weight)
      ],
      badges: [],
    );

    // Stocker l'utilisateur dans la box des utilisateurs
    await _usersBox!.put(user.id, user);
    
    // Stocker l'ID dans la box des préférences
    await _preferencesBox!.put(_currentUserIdKey, user.id);
    
    return user;
  }

  Future<UserProfile?> login(String email, String password) async {
    final users = _usersBox!.values.where((user) => user.email == email);
    if (users.isNotEmpty) {
      final user = users.first;
      // Stocker l'ID dans la box des préférences
      await _preferencesBox!.put(_currentUserIdKey, user.id);
      return user;
    }
    return null;
  }

  UserProfile? getCurrentUser() {
    final currentUserId = _preferencesBox!.get(_currentUserIdKey);
    if (currentUserId != null) {
      return _usersBox!.get(currentUserId);
    }
    return null;
  }

  Future<void> updateUser(UserProfile user) async {
    user.lastUpdated = DateTime.now();
    await _usersBox!.put(user.id, user);
  }

  Future<void> addWeightEntry(double weight) async {
    final user = getCurrentUser();
    if (user != null) {
      user.weight = weight;
      user.weightHistory.add(WeightEntry(date: DateTime.now(), weight: weight));
      await updateUser(user);
    }
  }

  Future<void> addBadge(String badge) async {
    final user = getCurrentUser();
    if (user != null && !user.badges.contains(badge)) {
      user.badges.add(badge);
      await updateUser(user);
    }
  }

  Future<void> logout() async {
    await _preferencesBox!.delete(_currentUserIdKey);
  }

  Future<String> generateAvatar(String name) async {
    final style = 'avataaars';
    final seed = name.replaceAll(' ', '');
    return 'https://api.dicebear.com/7.x/$style/svg?seed=$seed';
  }

  // Fermer les boxes quand vous n'en avez plus besoin
  Future<void> close() async {
    await _usersBox?.close();
    await _preferencesBox?.close();
  }
}