import '../models/user_model.dart';
import 'database_helper.dart';
import 'avatar_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final DatabaseHelper _db = DatabaseHelper();

  Future<void> init() async {
    try {
      print('📦 Initializing UserService with SQLite...');
      await _db.database;
      print('✅ UserService initialized');
    } catch (e) {
      print('❌ Error initializing UserService: $e');
      rethrow;
    }
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
    UserRole role = UserRole.user,
  }) async {
    final userId = DateTime.now().millisecondsSinceEpoch.toString();

    // Créer l'utilisateur temporaire pour générer l'avatar
    final tempUser = UserProfile(
      id: userId,
      name: name,
      email: email,
      password: password,
      role: role,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      fitnessLevel: fitnessLevel,
      goal: goal,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      weightHistory: [WeightEntry(date: DateTime.now(), weight: weight)],
      badges: [],
    );

    // 🎨 GÉNÉRER L'AVATAR AUTOMATIQUEMENT
    String? avatarUrl;
    try {
      print('🎨 Génération de l\'avatar pour $name...');
      AvatarService.debugAvatarGeneration(tempUser);
      avatarUrl = AvatarService.generateUserAvatar(tempUser);
      print('✅ Avatar généré: $avatarUrl');
    } catch (e) {
      print('⚠️ Erreur génération avatar, utilisation avatar simple: $e');
      avatarUrl = AvatarService.generateSimpleAvatar(tempUser);
    }

    // Créer l'utilisateur final avec l'avatar
    final user = UserProfile(
      id: userId,
      name: name,
      email: email,
      password: password,
      role: role,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      fitnessLevel: fitnessLevel,
      goal: goal,
      avatarUrl: avatarUrl, // ← AVATAR AJOUTÉ
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      weightHistory: [WeightEntry(date: DateTime.now(), weight: weight)],
      badges: [],
    );

    await _db.createUser(user);
    await _db.setCurrentUserId(userId);

    print('✅ User created with avatar: ${user.email}');
    return user;
  }

  Future<UserProfile?> login(String email, String password) async {
    final user = await _db.getUserByEmail(email);

    if (user == null || user.password != password) {
      return null;
    }

    await _db.setCurrentUserId(user.id);
    print('✅ Login: ${user.email} (${user.role.name})');
    return user;
  }

  Future<UserProfile?> getCurrentUser() async {
    final userId = await _db.getCurrentUserId();
    if (userId == null) return null;
    return await _db.getUserById(userId);
  }

  Future<bool> isLoggedIn() async {
    final userId = await _db.getCurrentUserId();
    return userId != null;
  }

  Future<void> updateUser(UserProfile user) async {
    user.lastUpdated = DateTime.now();
    
    // 🔄 RÉGÉNÉRER L'AVATAR SI LES CARACTÉRISTIQUES CHANGENT
    final oldUser = await _db.getUserById(user.id);
    if (oldUser != null && _shouldUpdateAvatar(oldUser, user)) {
      try {
        print('🔄 Régénération de l\'avatar...');
        final newAvatarUrl = AvatarService.generateUserAvatar(user);
        user.avatarUrl = newAvatarUrl;
        print('✅ Avatar régénéré');
      } catch (e) {
        print('⚠️ Erreur régénération avatar: $e');
      }
    }
    
    await _db.updateUser(user);
  }

  bool _shouldUpdateAvatar(UserProfile oldUser, UserProfile newUser) {
    return oldUser.weight != newUser.weight ||
        oldUser.height != newUser.height ||
        oldUser.age != newUser.age ||
        oldUser.fitnessLevel != newUser.fitnessLevel ||
        oldUser.goal != newUser.goal;
  }

  Future<void> addWeightEntry(String userId, double weight) async {
    final entry = WeightEntry(date: DateTime.now(), weight: weight);
    await _db.addWeightEntry(userId, entry);
  }



  Future<void> addWeightToHistory(String userId, double weight) async {
  print('📊 Service: Ajout poids $weight kg pour user $userId');
  
  final entry = WeightEntry(
    date: DateTime.now(),
    weight: weight,
  );
  
  await _db.addWeightEntry(userId, entry);
  print('✅ Service: Poids ajouté');
}

  Future<void> logout() async {
    await _db.clearSession();
    print('👋 Logged out');
  }

  Future<List<UserProfile>> getAllUsersForAdmin() async {
    return await _db.getAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    await _db.deleteUser(userId);
  }

  Future<void> promoteToAdmin(String userId) async {
    final user = await _db.getUserById(userId);
    if (user != null) {
      user.role = UserRole.admin;
      await _db.updateUser(user);
      print('⬆️ Promoted: ${user.email}');
    }
  }

  // 🆕 MÉTHODE POUR RÉGÉNÉRER MANUELLEMENT L'AVATAR
  Future<void> regenerateAvatar(String userId) async {
    final user = await _db.getUserById(userId);
    if (user != null) {
      try {
        print('🔄 Régénération manuelle de l\'avatar pour ${user.name}...');
        final newAvatarUrl = AvatarService.generateUserAvatar(user);
        user.avatarUrl = newAvatarUrl;
        await _db.updateUser(user);
        print('✅ Avatar régénéré avec succès');
      } catch (e) {
        print('❌ Erreur: $e');
        throw e;
      }
    }
  }
}