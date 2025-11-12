// MAIN.DART - Version finale intégrée
// ============================================

import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

// Import des services
import 'pages/user/services/user_service.dart';

// Import screens
import 'pages/user/screens/splash_screen.dart';
import 'pages/user/screens/login_screen.dart';
import 'pages/user/screens/register_screen_1.dart';
import 'pages/user/screens/register_screen_2.dart';
import 'pages/user/screens/register_screen_3.dart';
import 'pages/user/screens/dashboard_screen.dart';
import 'pages/user/screens/admin_dashboard_screen.dart';
import 'pages/user/screens/profile_screen.dart';
import 'pages/user/screens/settings_screen.dart';
import 'pages/user/screens/weather_screen.dart';

// Import module pages
import 'pages/user/dashboard_page.dart';
import 'pages/workout/workouts_page.dart';
import 'pages/nutrition/nutrition_page.dart';
import 'pages/program/programs_page.dart';
import 'pages/mental health/mental_health_page.dart';
import 'pages/supplements/supplements_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 Starting GYMINI App...');
  
  // ✅ INITIALISATION SQLITE POUR DESKTOP (Version améliorée)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('🖥️ SQLite FFI initialized for Desktop');
  }
  
  // Initialiser le UserService
  try {
    final userService = UserService();
    await userService.init();
  } catch (e) {
    print('❌ Error initializing UserService: $e');
  }
  
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const GyminiApp(),
    ),
  );
}

class GyminiApp extends StatelessWidget {
  const GyminiApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('📱 Building GyminiApp...');
    
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      title: 'GYMINI - FitLife Tracker',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFa3e635),
        scaffoldBackgroundColor: const Color(0xFF1a1a1a),
        fontFamily: 'System',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFa3e635),
          secondary: Color(0xFFC7F000),
        ),
      ),
      
      // ✅ LOGIN COMME PAGE PRINCIPALE
      home: const LoginScreen(),
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen1(),
        '/register2': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RegisterScreen2(previousData: args);
        },
        '/register3': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RegisterScreen3(userData: args);
        },
        '/dashboard': (context) => const HomeTabs(),
        '/oldDashboard': (context) => const DashboardScreen(),
        '/adminDashboard': (context) => const AdminDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/weather': (context) => const WeatherScreen(),
      },
      
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}

// ✅ HOMETABS AMÉLIORÉ (combinaison des deux versions)
class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const WorkoutsPage(),
    const NutritionPage(),
    const ProgramsPage(),
    const MentalHealthPage(),
    const SupplementsPage(),
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.fitness_center_rounded,
    Icons.restaurant_rounded,
    Icons.list_alt_rounded,
    Icons.self_improvement_rounded,
    Icons.local_hospital_rounded,
  ];

  final List<String> _labels = [
    'Dashboard',
    'Workouts',
    'Nutrition',
    'Programs',
    'Mental Health',
    'Supplements',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF32383E),
              Color(0xFF17191C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2124),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFC7F000),
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: _icons.asMap().entries.map((entry) {
              int index = entry.key;
              IconData icon = entry.value;
              bool isSelected = _currentIndex == index;
              
              return BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFC7F000).withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: isSelected ? 28 : 24,
                  ),
                ),
                label: _labels[index],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}