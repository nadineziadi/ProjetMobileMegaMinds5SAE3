import 'package:flutter/cupertino.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C), // ✅ Dark background
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Nutrition'),
        backgroundColor: Color(0xFF32383E), // optional nav bar contrast
      ),
      child: const Center(
        child: Text(
          'Welcome to Nutrition',
          style: TextStyle(
            fontSize: 22,
            color: CupertinoColors.white, // readable on dark background
          ),
        ),
      ),
    );
  }
}
