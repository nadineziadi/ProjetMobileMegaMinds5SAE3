import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'pages/program/services/notification_service.dart';

// Import your real module pages here
import 'pages/user/dashboard_page.dart';
import 'pages/workout/workouts_page.dart';
import 'pages/nutrition/nutrition_page.dart';
import 'pages/program/programs_page.dart';
import 'pages/mental health/mental_health_page.dart';
import 'pages/supplements/supplements_page.dart';

// Import your providers
import 'pages/program/providers/program_provider.dart';
import 'pages/program/providers/statistics_provider.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService.initialize();
  runApp(
    DevicePreview(
      enabled: true, // or !kReleaseMode if you import foundation
      builder: (context) => const FitLifeApp(),
    ),
  );
}

class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgramProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitLife Tracker',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeTabs(),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This allows the body to extend behind the navbar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF32383E), Color(0xFF17191C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16), // Add margin for floating effect
        decoration: BoxDecoration(
          color: const Color(0xFF1E2124),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: BorderRadius.circular(24), // Full circular border
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
            items: _icons.map((icon) {
              int index = _icons.indexOf(icon);
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
                  child: Icon(icon, size: isSelected ? 28 : 24),
                ),
                label: '',
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
