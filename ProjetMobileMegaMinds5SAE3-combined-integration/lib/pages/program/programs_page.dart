import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For HomeScreen and Material widgets
import '/pages/program/screens/home_screen.dart';    // Adjust this path as needed

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // If your UI is fully Material-themed, you can even remove CupertinoPageScaffold and use HomeScreen directly:
    return const HomeScreen();
    
    // Alternatively, if you want to keep Cupertino nav styling, wrap HomeScreen:
    /*
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Programs'),
        backgroundColor: Color(0xFF32383E),
      ),
      child: const HomeScreen(),  // Shows your complete logic/UI
    );
    */
  }
}
