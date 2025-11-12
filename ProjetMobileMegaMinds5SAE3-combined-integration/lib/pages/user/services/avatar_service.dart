import '../models/user_model.dart';

class AvatarService {
  static const String _baseUrl = 'https://api.dicebear.com/9.x';
  
  /// Génère un avatar qui correspond VRAIMENT aux caractéristiques
  static String generateUserAvatar(UserProfile user) {
    final seed = user.email.isNotEmpty ? user.email : user.name;
    
    // Style selon le genre - CORRIGÉ
    final style = user.gender.toLowerCase() == 'female' ? 'lorelei' : 'micah';
    
    // Paramètres de base
    final params = {
      'seed': seed,
      'backgroundColor': _getBackgroundColorByBMI(user.bmi),
      'radius': '50',
      'size': '200',
    };

    // 🔹 PARAMÈTRES SPÉCIFIQUES AU STYLE - CORRIGÉ
    if (style == 'lorelei') {
      // STYLE FÉMININ
      params.addAll({
        'hair': _getValidFemaleHair(user.goal),
        'hairColor': _getValidHairColor(user.age),
        'accessories': _getValidAccessories(user.fitnessLevel),
        'clothing': _getValidClothing(user.fitnessLevel),
      });
    } else {
      // STYLE MASCULIN
      params.addAll({
        'hair': _getValidMaleHair(user.goal),
        'hairColor': _getValidHairColor(user.age),
        'facialHair': _getValidFacialHair(user.age, user.bmi),
        'accessories': _getValidAccessories(user.fitnessLevel),
        'clothing': _getValidClothing(user.fitnessLevel),
      });
    }

    final queryParams = params.entries
        .where((entry) => entry.value.isNotEmpty && entry.value != 'null')
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');

    final url = '$_baseUrl/$style/png?$queryParams';
    print('🎨 Avatar CORRECT généré pour ${user.name}');
    print('   → Genre: ${user.gender}, Âge: ${user.age}, Objectif: ${user.goal}');
    print('   → URL: $url');
    return url;
  }

  // 🔹 COIFFURE FÉMININE CORRECTE
  static String _getValidFemaleHair(String goal) {
    switch (goal) {
      case 'weight_loss': return 'long';
      case 'muscle_gain': return 'bob';
      case 'endurance': return 'ponytail';
      default: return 'curly';
    }
  }

  // 🔹 COIFFURE MASCULINE CORRECTE
  static String _getValidMaleHair(String goal) {
    switch (goal) {
      case 'weight_loss': return 'short';
      case 'muscle_gain': return 'pomp';
      case 'endurance': return 'fohawk';
      default: return 'classic';
    }
  }

  // 🔹 BARBE CORRECTE (uniquement hommes +25 ans)
  static String _getValidFacialHair(int age, double bmi) {
    if (age < 25) return '';
    
    if (bmi < 18.5) return 'scruff';
    if (bmi < 25) return 'beardMedium';
    if (bmi < 30) return 'beardLight';
    return 'beardMagestic';
  }

  // 🔹 COULEUR DE CHEVEUX RÉALISTE
  static String _getValidHairColor(int age) {
    if (age < 20) return '0e0e0e';
    if (age < 35) return '2c1b1b';
    if (age < 50) return 'a78b6f';
    return 'd4d4d4';
  }

  // 🔹 ACCESSOIRES CORRESPONDANTS
  static String _getValidAccessories(String fitnessLevel) {
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner': return '';
      case 'intermediate': return 'round';
      case 'advanced': return 'sunglasses';
      default: return '';
    }
  }

  // 🔹 VÊTEMENTS CORRESPONDANTS
  static String _getValidClothing(String fitnessLevel) {
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner': return 'shirt';
      case 'intermediate': return 'hoodie';
      case 'advanced': return 'tankTop';
      default: return 'shirt';
    }
  }

  // 🔹 COULEUR DE FOND SELON L'IMC
  static String _getBackgroundColorByBMI(double bmi) {
    if (bmi < 18.5) return 'ffeb3b';
    if (bmi < 25) return '4caf50';
    if (bmi < 30) return 'ff9800';
    return 'f44336';
  }

  /// 🔹 VERSION SIMPLE POUR TESTS
  static String generateSimpleAvatar(UserProfile user) {
    final seed = Uri.encodeComponent(user.email);
    final style = user.gender.toLowerCase() == 'female' ? 'lorelei' : 'micah';
    
    return 'https://api.dicebear.com/9.x/$style/png?seed=$seed&size=200&radius=50';
  }

  /// 🔹 VERSION DE SECOURS
  static String generateFallbackAvatar(String email) {
    final seed = Uri.encodeComponent(email);
    return 'https://api.dicebear.com/9.x/avataaars/png?seed=$seed&size=200&radius=50';
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