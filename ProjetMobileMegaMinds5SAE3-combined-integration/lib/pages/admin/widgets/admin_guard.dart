import 'package:flutter/material.dart';
import '../../user/services/user_service.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  final UserService _userService = UserService();

  AdminGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1a1a1a),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        
        if (user == null || !user.isAdmin) {
          // Pas admin -> Redirection
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Accès réservé aux administrateurs'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const SizedBox.shrink();
        }

        return child;
      },
    );
  }
}