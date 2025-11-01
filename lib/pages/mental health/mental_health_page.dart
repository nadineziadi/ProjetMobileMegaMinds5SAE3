import 'package:flutter/cupertino.dart';

class MentalHealthPage extends StatelessWidget {
  const MentalHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C), // ✅ Dark background
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mental Health'),
        backgroundColor: Color(0xFF32383E), // optional nav bar contrast
      ),
      child: const Center(
        child: Text(
          'Welcome to Mental Health',
          style: TextStyle(
            fontSize: 22,
            color: CupertinoColors.white, // readable on dark background
          ),
        ),
      ),
    );
  }
}
