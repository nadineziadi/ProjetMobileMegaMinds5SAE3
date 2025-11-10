# Module Mental Health - Documentation

## 📋 Vue d'ensemble

Le module **Mental Health** offre un espace dédié au bien-être émotionnel et mental des utilisateurs avec :
- Suivi quotidien de l'humeur (Mood Tracker)
- Exercices de relaxation guidés
- Citations motivantes personnalisées
- Tableau de bord statistiques
- Hub communautaire (Wellness Hub)

---

## 📁 Structure du projet

```
lib/pages/mental_health/
├── onboarding_screen.dart              # Écran d'accueil "It's Ok Not To Be OKAY"
├── home_screen.dart                    # Dashboard principal
├── wellness_hub_screen.dart            # Forum de discussion
├── mental_health_dashboard.dart        # Statistiques détaillées
├── mood_tracker_screen.dart            # Suivi de l'humeur
├── relaxation_screen.dart              # Exercices de relaxation
├── motivation_screen.dart              # Citations inspirantes
├── mental_health_routes.dart           # Configuration des routes
├── models/
│   └── mental_health_models.dart       # Modèles de données
├── services/
│   └── mental_health_service.dart      # Service API et logique métier
└── widgets/
    ├── custom_bottom_nav.dart          # Barre de navigation personnalisée
    ├── mood_card.dart                  # Cartes d'humeur
    ├── task_card.dart                  # Cartes de tâches
    └── stat_card.dart                  # Cartes de statistiques
```

---

## 🚀 Installation

### 1. Dépendances à ajouter dans `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # Appels API
  sqflite: ^2.3.0           # Base de données locale
  shared_preferences: ^2.2.2 # Stockage local
  fl_chart: ^0.65.0         # Graphiques (optionnel)
  intl: ^0.18.1             # Formatage dates
```

### 2. Installer les packages

```bash
flutter pub get
```

---

## 🎨 Assets nécessaires

Créez le dossier `assets/images/` et ajoutez les images suivantes :
- `meditation_illustration.png` - Illustration pour l'onboarding
- `peer_group_icon.png` - Icône pour les groupes
- `lotus_icon.png` - Icône méditation

Puis dans `pubspec.yaml` :

```yaml
flutter:
  assets:
    - assets/images/
```

---

## 🔧 Configuration des routes

Dans votre `main.dart`, ajoutez les routes du module :

```dart
import 'package:your_app/pages/mental_health/mental_health_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYMINI Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/mental_health_onboarding',
      routes: {
        ...MentalHealthRoutes.getRoutes(),
        // Vos autres routes...
      },
    );
  }
}
```

---

## 📱 Écrans disponibles

### 1. **Onboarding Screen**
```dart
Navigator.pushNamed(context, '/mental_health_onboarding');
```
- Premier écran d'introduction
- Message : "It's Ok Not To Be OKAY !!"
- Bouton "Let Us Help You"

### 2. **Home Screen**
```dart
Navigator.pushNamed(context, '/mental_health_home');
```
- Dashboard principal avec sélection d'humeur
- Tâches du jour (Peer Group, Meditation)
- Navigation vers les autres écrans

### 3. **Wellness Hub**
```dart
Navigator.pushNamed(context, '/wellness_hub');
```
- Forum communautaire
- Filtres par catégories (Therapy, Relationship, Self-Care)
- Posts avec likes et commentaires

### 4. **Mental Health Dashboard**
```dart
Navigator.pushNamed(context, '/mental_health_dashboard');
```
- Score de santé mentale (%)
- Statistiques : calories, nutrition, sommeil, rythme cardiaque
- Sélection période (Daily/Weekly/Monthly)

### 5. **Mood Tracker**
```dart
Navigator.pushNamed(context, '/mood_tracker');
```
- Sélection d'humeur quotidienne
- Ajout de notes optionnelles
- Graphique hebdomadaire

### 6. **Relaxation Screen**
```dart
Navigator.pushNamed(context, '/relaxation');
```
- Catégories : Breathing, Meditation, Music, Yoga
- Lecteur avec timer
- Contrôles play/pause

### 7. **Motivation Screen**
```dart
Navigator.pushNamed(context, '/motivation');
```
- Citations inspirantes quotidiennes
- Génération de nouvelles citations
- Partage et sauvegarde

---

## 🎯 Fonctionnalités clés

### Mood Intelligence System
```dart
final service = MentalHealthService();
final recommendation = service.recommendExercise('stressed');
// Retourne automatiquement un exercice de respiration
```

### Smart Relaxation Recommendation
- **Stressé** → Respiration guidée
- **Fatigué** → Méditation audio
- **Motivé** → Citation inspirante

---

## 🔌 Intégration API

### ZenQuotes API (Citations)
```dart
final service = MentalHealthService();
final quote = await service.fetchDailyQuote();
print('${quote?.text} - ${quote?.author}');
```

### Google Fit / Health Connect (À implémenter)
```dart
// TODO: Ajouter les packages health ou google_fit
// Synchronisation automatique des données d'activité physique
```

---

## 💾 Stockage local

Les données sont stockées localement avec :
- **sqflite** pour l'historique des humeurs
- **shared_preferences** pour les préférences utilisateur

Exemple d'utilisation :
```dart
final service = MentalHealthService();

// Sauvegarder une humeur
final entry = MoodEntry(
  id: 'mood_1',
  date: DateTime.now(),
  mood: 'happy',
  intensity: 4,
  note: 'Great day!',
);
await service.saveMoodEntry(entry);

// Récupérer l'historique
final history = await service.getMoodHistory(days: 7);
```

---

## 🎨 Personnalisation des couleurs

Palette du module :
```dart
// Couleurs principales
const Color primaryGreen = Color(0xFFD4FF00);    // Vert néon
const Color darkBackground = Color(0xFF1E1E1E);  // Fond sombre
const Color cardBackground = Color(0xFF2A2A2A);  // Cartes
const Color tealAccent = Color(0xFF7FDBDA);      // Accent bleu-vert

// Couleurs d'humeur
const Color happyColor = Color(0xFFFFD700);      // Jaune
const Color stressedColor = Color(0xFFFF6B6B);   // Rouge
const Color tiredColor = Color(0xFF9B9B9B);      // Gris
const Color motivatedColor = Color(0xFF4CAF50);  // Vert
const Color neutralColor = Color(0xFF87CEEB);    // Bleu clair
```

---

## 📊 Modèles de données

Tous les modèles sont dans `models/mental_health_models.dart` :
- `MoodEntry` - Entrée d'humeur
- `RelaxationExercise` - Exercice de relaxation
- `Quote` - Citation inspirante
- `WellnessPost` - Post du forum
- `MentalHealthStats` - Statistiques de santé

---

## 🧪 Tests

Pour tester le module :

```dart
void main() {
  testWidgets('Onboarding screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: OnboardingScreen(),
    ));
    
    expect(find.text("It's Ok Not To Be\nOKAY !!"), findsOneWidget);
    expect(find.text('Let Us Help You'), findsOneWidget);
  });
}
```

---

## 📝 TODO / Améliorations futures

- [ ] Intégration Google Fit API
- [ ] Notifications push pour rappels
- [ ] Export PDF des statistiques
- [ ] Mode sombre/clair personnalisable
- [ ] Support multilingue (i18n)
- [ ] Audio pour méditations guidées
- [ ] Authentification utilisateur
- [ ] Synchronisation cloud

---

## 🤝 Support

Pour toute question ou problème :
- Email : support@yourapp.com
- Documentation API : https://zenquotes.io/api

---

## 📄 Licence

Ce module est sous licence MIT. Libre d'utilisation et de modification.

---

**Développé avec ❤️ pour GYMINI Tracker**