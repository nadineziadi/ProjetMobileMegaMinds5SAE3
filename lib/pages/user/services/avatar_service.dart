import '../models/user_model.dart';

class AvatarService {
  static const String _baseUrl = 'https://api.dicebear.com/9.x';
  
  /// Génère un avatar qui correspond aux caractéristiques de l'utilisateur
  /// ⚠️ IMPORTANT: Lorelei et Micah ne supportent PAS les paramètres de customisation
  /// Seuls seed, size, radius, backgroundColor et flip sont supportés
  static String generateUserAvatar(UserProfile user) {
    // Créer un seed unique basé sur les caractéristiques
    final seed = _createSeedFromCharacteristics(user);
    
    // Style selon le genre
    final style = user.gender.toLowerCase() == 'female' ? 'lorelei' : 'micah';
    
    // UNIQUEMENT les paramètres supportés par Lorelei et Micah
    final params = <String, String>{
      'seed': seed,
      'size': '200',
      'radius': '50',
      'backgroundColor': _getBackgroundColorByBMI(user.bmi),
    };

    final queryParams = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');

    final url = '$_baseUrl/$style/png?$queryParams';
    print('🎨 Avatar généré pour ${user.name} ($style)');
    print('   → Seed: $seed');
    print('   → URL: $url');
    return url;
  }
  
  /// Crée un seed unique basé sur les caractéristiques de l'utilisateur
  /// Cela garantit que les avatars varient selon les profils
  static String _createSeedFromCharacteristics(UserProfile user) {
    // Combiner plusieurs caractéristiques pour créer un seed unique
    final characteristics = [
      user.email,
      user.gender,
      user.age.toString(),
      user.goal,
      user.fitnessLevel,
      user.bmi.toStringAsFixed(0),
    ].join('-');
    
    return Uri.encodeComponent(characteristics);
  }

    
  /// 🔹 COULEUR DE FOND SELON L'IMC
  static String _getBackgroundColorByBMI(double bmi) {
    if (bmi < 18.5) return 'ffeb3b'; // Jaune (sous-poids)
    if (bmi < 25) return '4caf50';   // Vert (normal)
    if (bmi < 30) return 'ff9800';   // Orange (surpoids)
    return 'f44336';                  // Rouge (obésité)
  }

  /// 🔹 VERSION ALTERNATIVE AVEC AVATAAARS (plus de customisation)
  /// Si vous voulez plus de contrôle, utilisez le style 'avataaars'
  static String generateCustomizableAvatar(UserProfile user) {
    final seed = user.email;
    
    // Avataaars supporte beaucoup plus d'options
    final params = <String, String>{
      'seed': seed,
      'size': '200',
      'radius': '50',
      'backgroundColor': _getBackgroundColorByBMI(user.bmi),
      'skinColor': _getSkinToneByAge(user.age),
    };

    final queryParams = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');

    return '$_baseUrl/avataaars/png?$queryParams';
  }
  
  static String _getSkinToneByAge(int age) {
    if (age < 20) return 'ffdbb4';
    if (age < 40) return 'edb98a';
    if (age < 60) return 'd08b5b';
    return 'ae5d29';
  }

  /// 🔹 VERSION SIMPLE POUR TESTS
  static String generateSimpleAvatar(UserProfile user) {
    final seed = Uri.encodeComponent(user.email);
    final style = user.gender.toLowerCase() == 'female' ? 'lorelei' : 'micah';
    
    return 'https://api.dicebear.com/9.x/$style/png?seed=$seed&size=200&radius=50&backgroundColor=${_getBackgroundColorByBMI(user.bmi)}';
  }

  /// 🔹 VERSION DE SECOURS
  static String generateFallbackAvatar(String email) {
    final seed = Uri.encodeComponent(email);
    return 'https://api.dicebear.com/9.x/bottts/png?seed=$seed&size=200&radius=50';
  }

  /// 🔹 TEST DE GÉNÉRATION D'AVATAR
  static void debugAvatarGeneration(UserProfile user) {
    print('\n=== DEBUG AVATAR ===');
    print('Utilisateur: ${user.name}');
    print('Genre: ${user.gender}');
    print('Âge: ${user.age}');
    print('Objectif: ${user.goal}');
    print('Niveau: ${user.fitnessLevel}');
    print('IMC: ${user.bmi.toStringAsFixed(1)}');
    
    final avatarUrl = generateUserAvatar(user);
    print('Avatar généré: $avatarUrl');
    print('====================\n');
  }
}