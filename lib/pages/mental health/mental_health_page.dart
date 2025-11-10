import 'package:flutter/material.dart';

// Import all your mental health screens
import 'home_screen.dart';
import 'mental_health_dashboard.dart';
import 'mood_tracker_screen.dart';
import 'motivation_screen.dart';
import 'onboarding_screen.dart';
import 'relaxation_screen.dart';
import 'wellness_hub_screen.dart';

class MentalHealthPage extends StatefulWidget {
  const MentalHealthPage({super.key});

  @override
  State<MentalHealthPage> createState() => _MentalHealthPageState();
}

class _MentalHealthPageState extends State<MentalHealthPage> {
  int _currentIndex = 0;

  // List of all your mental health screens
  final List<Widget> _screens = [
    const MentalHealthHomeScreen(),
    const MoodTrackerScreen(),
    const RelaxationScreen(),
    const MotivationScreen(),
    const WellnessHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: const Text('Mental Health'),
        backgroundColor: const Color(0xFF32383E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              // Navigate to dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MentalHealthDashboard(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2124),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFC7F000),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mood_rounded),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.spa_rounded),
              label: 'Relax',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.electric_bolt_rounded),
              label: 'Motivate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_rounded),
              label: 'Wellness',
            ),
          ],
        ),
      ),
    );
  }
}

// Si vous n'avez pas encore créé MentalHealthHomeScreen, voici un exemple:
class MentalHealthHomeScreen extends StatelessWidget {
  const MentalHealthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickAccessCard( houssem
          context,
          'Daily Check-in',
          'Track your mood',
          Icons.favorite_rounded,
          Colors.pink,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildQuickAccessCard(
          context,
          'Relaxation',
          'Breathing exercises',
          Icons.air_rounded,
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RelaxationScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildQuickAccessCard(
          context,
          'Motivation',
          'Daily inspiration',
          Icons.emoji_events_rounded,
          Colors.amber,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MotivationScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildQuickAccessCard(
          context,
          'Wellness Hub',
          'Resources & tips',
          Icons.health_and_safety_rounded,
          Colors.green,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WellnessHubScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2124),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}