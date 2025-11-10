    import 'package:flutter/material.dart';
    import '../services/user_service.dart';

    class RegisterScreen3 extends StatefulWidget {
    final Map<String, dynamic> userData;

    const RegisterScreen3({Key? key, required this.userData}) : super(key: key);

    @override
    State<RegisterScreen3> createState() => _RegisterScreen3State();
    }

    class _RegisterScreen3State extends State<RegisterScreen3> {
    String _selectedGoal = 'weight_loss';
    final _userService = UserService();
    bool _isLoading = false;

    Future<void> _completeRegistration() async {
        setState(() => _isLoading = true);

        try {
        await _userService.init();
        await _userService.createUser(
            name: '${widget.userData['firstName']} ${widget.userData['lastName']}',
            email: widget.userData['email'],
            password: widget.userData['password'],
            age: widget.userData['age'],
            weight: widget.userData['weight'],
            height: widget.userData['height'],
            gender: widget.userData['gender'],
            fitnessLevel: widget.userData['fitnessLevel'],
            goal: _selectedGoal,
        );

        Navigator.pushNamedAndRemoveUntil(
    context,
    '/dashboard',
    (route) => false,
    );
        } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d), Color(0xFF000000)],
            ),
            ),
            child: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                children: [
                    const SizedBox(height: 40),
                    const Text('🎯', style: TextStyle(fontSize: 70)),
                    const SizedBox(height: 16),
                    const Text(
                    'Your Fitness Goal',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                    ),
                    ),
                    const Text(
                    'What do you want to achieve?',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    
                    // Goal Options
                    _buildGoalOption(
                    emoji: '🔥',
                    title: 'Perte de poids',
                    description: 'Brûler des calories et perdre du gras',
                    value: 'weight_loss',
                    ),
                    const SizedBox(height: 12),
                    
                    _buildGoalOption(
                    emoji: '💪',
                    title: 'Prise de masse',
                    description: 'Développer la masse musculaire',
                    value: 'muscle_gain',
                    ),
                    const SizedBox(height: 12),
                    
                    _buildGoalOption(
                    emoji: '⚖️',
                    title: 'Maintien',
                    description: 'Garder ma forme actuelle',
                    value: 'maintenance',
                    ),
                    const SizedBox(height: 12),
                    
                    _buildGoalOption(
                    emoji: '🏃',
                    title: 'Endurance',
                    description: 'Améliorer ma condition cardiovasculaire',
                    value: 'endurance',
                    ),
                    const SizedBox(height: 32),
                    
                    // Complete Registration Button
                    SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                        onPressed: _isLoading ? null : _completeRegistration,
                        style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFa3e635),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                        ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Complete Registration',
                                style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                    ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Back Button
                    SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2d2d2d)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                        ),
                        ),
                    ),
                    ),
                ],
                ),
            ),
            ),
        ),
        );
    }

    Widget _buildGoalOption({
        required String emoji,
        required String title,
        required String description,
        required String value,
    }) {
        final isSelected = _selectedGoal == value;
        return InkWell(
        onTap: () => setState(() => _selectedGoal = value),
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFa3e635), Color(0xFF22c55e)],
                    )
                : null,
            color: isSelected ? null : const Color(0xFF2d2d2d),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? Colors.transparent : const Color(0xFF3d3d3d),
                width: 1,
            ),
            ),
            child: Row(
            children: [
                Text(emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                        title,
                        style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        description,
                        style: TextStyle(
                        color: isSelected ? Colors.black87 : Colors.grey,
                        fontSize: 13,
                        ),
                    ),
                    ],
                ),
                ),
                if (isSelected)
                const Icon(Icons.check_circle, color: Colors.black),
            ],
            ),
        ),
        );
    }
    }