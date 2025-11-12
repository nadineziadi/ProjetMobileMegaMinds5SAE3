import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Initializing app...');
      
      // Initialiser UserService avec timeout
      final userService = UserService();
      await userService.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ UserService init timeout - continuing anyway');
        },
      );
      
      print('✅ UserService initialized');
      
      // Attendre 1 seconde pour l'effet splash
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérifier si l'utilisateur est connecté
      bool isLoggedIn = false;
      try {
        isLoggedIn = await userService.isLoggedIn().timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        );
      } catch (e) {
        print('⚠️ Error checking login status: $e');
        isLoggedIn = false;
      }
      
      print('👤 User logged in: $isLoggedIn');
      
      if (!mounted) return;
      
      // Navigation
      if (isLoggedIn) {
        print('📍 Navigating to dashboard');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        print('📍 Navigating to login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('❌ Error during initialization: $e');
      
      // En cas d'erreur, aller vers login après 1 seconde
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        print('📍 Error recovery - navigating to login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFa3e635).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 80,
                  color: Color(0xFFa3e635),
                ),
              ),
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'GYMINI',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tagline
              const Text(
                'Your Personal Fitness Tracker',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFa3e635)),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Chargement...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}