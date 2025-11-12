import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'wellness_hub_screen.dart';
import 'mental_health_dashboard.dart';
import 'mood_tracker_screen.dart';
import 'relaxation_screen.dart';
import 'motivation_screen.dart';

class MentalHealthRoutes {
  static const String onboarding = '/mental_health_onboarding';
  static const String home = '/mental_health_home';
  static const String wellnessHub = '/wellness_hub';
  static const String dashboard = '/mental_health_dashboard';
  static const String moodTracker = '/mood_tracker';
  static const String relaxation = '/relaxation';
  static const String motivation = '/motivation';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      onboarding: (context) => const OnboardingScreen(),
      home: (context) => const MentalHealthHomeScreen(),
      wellnessHub: (context) => const WellnessHubScreen(),
      dashboard: (context) => const MentalHealthDashboard(),
      moodTracker: (context) => const MoodTrackerScreen(),
      relaxation: (context) => const RelaxationScreen(),
      motivation: (context) => const MotivationScreen(),
    };
  }
}