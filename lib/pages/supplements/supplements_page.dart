import 'package:flutter/cupertino.dart';

class SupplementsPage extends StatelessWidget {
  const SupplementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C), // ✅ Dark background
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Supplements'),
        backgroundColor: Color(0xFF32383E), // optional nav bar contrast
      ),
      child: const Center(
        child: Text(
          'Welcome to Supplements',
          style: TextStyle(
            fontSize: 22,
            color: CupertinoColors.white, // readable on dark background
          ),
        ),
      ),
    );
  }
}
