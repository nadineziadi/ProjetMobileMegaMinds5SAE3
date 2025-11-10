import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/program_provider.dart';
import 'programs_list_screen.dart';
import 'statistics_screen.dart';
import 'calendar_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProgramProvider>().loadPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Modern palette
    const background = Color(0xFF181A20);
    const cardColor = Color(0xFF23252B);
    const accentBlue = Color(0xFF4886FE);
    const accentGreen = Color(0xFF6DFD7D);
    const headerGradientStart = Color(0xFF22264B);
    const headerGradientEnd = Color(0xFF20894D);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accentBlue, accentGreen],
          ).createShader(bounds),
          child: const Text(
            'Fitness Programs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), // less bottom padding here
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [headerGradientStart, headerGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.09),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Icon(Icons.fitness_center,
                        size: 60, color: accentGreen),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track, adapt, and succeed with tailored programs just for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Primary Action Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProgramsListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: background,
                elevation: 3,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.format_list_bulleted, size: 26),
              label: const Text('Browse Programs'),
            ),
            const SizedBox(height: 18),

            // Secondary Buttons
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StatisticsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: accentBlue,
                side: BorderSide(color: accentBlue, width: 2),
                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.bar_chart, color: accentBlue, size: 24),
              label: const Text('View Statistics'),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarSettingsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: accentGreen,
                side: BorderSide(color: accentGreen, width: 2),
                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.calendar_month, color: accentGreen, size: 24),
              label: const Text('Calendar & Reminders'),
            ),
            const SizedBox(height: 32),

            // Quick Features section
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[900]!, width: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _featureRow(
                    context,
                    icon: Icons.auto_awesome,
                    color: accentGreen,
                    label: 'Create custom programs tailored to you.',
                  ),
                  const SizedBox(height: 16),
                  _featureRow(
                    context,
                    icon: Icons.psychology,
                    color: accentBlue,
                    label: 'Smart adaptation based on your progress.',
                  ),
                  const SizedBox(height: 16),
                  _featureRow(
                    context,
                    icon: Icons.insights,
                    color: Colors.amber,
                    label: 'Track your full fitness journey and streaks.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12), // less final space
          ],
        ),
      ),
    );
  }

  Widget _featureRow(BuildContext context, {required IconData icon, required Color color, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 25),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[100], fontSize: 15.5),
          ),
        ),
      ],
    );
  }
}
