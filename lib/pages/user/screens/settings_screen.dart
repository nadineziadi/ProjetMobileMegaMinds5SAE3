import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatelessWidget {
  final _userService = UserService();

  SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsSection(
            title: 'Account',
            items: [
              _buildSettingsItem(
                context,
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: const Color(0xFFa3e635),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSettingsSection(
            title: 'Help',
            items: [
              _buildSettingsItem(
                context,
                icon: Icons.help,
                title: 'Help Center',
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: Icons.feedback,
                title: 'Send Feedback',
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: Icons.description,
                title: 'Terms & Conditions',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSettingsSection(
            title: 'Danger Zone',
            items: [
              _buildSettingsItem(
                context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2d2d2d),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await _userService.init();
    await _userService.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte? Cette action est irréversible.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete account logic here
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}