import 'package:flutter/material.dart';
import '../user/services/user_service.dart';
import 'pages/admin/supplements_list_page.dart';
import 'pages/user/user_supplements_list_page.dart';

class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  State<SupplementsPage> createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  Future<bool> _checkUserRole() async {
    try {
      final userService = UserService();
      final currentUser = await userService.getCurrentUser();
      return currentUser?.isAdmin ?? false;
    } catch (e) {
      debugPrint('Error checking user role: $e');
      return false; // Default to non-admin if error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF17191C),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC7F000),
              ),
            ),
          );
        }

        final isAdmin = snapshot.data ?? false;

        if (isAdmin) {
          return const SupplementsListPage(); // Admin version
        } else {
          return const UserSupplementsListPage(); // User version
        }
      },
    );
  }
}
