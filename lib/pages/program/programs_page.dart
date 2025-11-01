import 'package:flutter/cupertino.dart';

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C), 
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Programs'),
        backgroundColor: Color(0xFF32383E), 
      ),
      child: const Center(
        child: Text(
          'Welcome to Programs',
          style: TextStyle(
            fontSize: 22,
            color: CupertinoColors.white, 
          ),
        ),
      ),
    );
  }
}
