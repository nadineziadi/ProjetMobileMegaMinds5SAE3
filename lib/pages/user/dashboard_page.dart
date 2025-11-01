import 'package:flutter/cupertino.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C), // ✅ Dark background
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dashboard'),
        backgroundColor: Color(0xFF32383E), // slightly different for the nav bar
      ),
      child: const Center(
        child: Text(
          'Welcome to GYMINI Tracker 💪',
          style: TextStyle(
            fontSize: 22,
            color: CupertinoColors.white, // readable on dark background
          ),
        ),
      ),
    );
  }
}
