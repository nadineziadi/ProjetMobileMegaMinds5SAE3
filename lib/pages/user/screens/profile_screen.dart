import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../services/avatar_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  UserProfile? _currentUser;
  bool _isEditing = false;
  
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await _userService.init();
    final user = await _userService.getCurrentUser();
    setState(() {
      _currentUser = user;
      if (_currentUser != null) {
        _nameController.text = _currentUser!.name;
        _ageController.text = _currentUser!.age.toString();
        _weightController.text = _currentUser!.weight.toString();
        _heightController.text = _currentUser!.height.toString();
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_currentUser != null) {
      final updatedUser = UserProfile(
        id: _currentUser!.id,
        name: _nameController.text,
        email: _currentUser!.email,
        password: _currentUser!.password,
        role: _currentUser!.role,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        gender: _currentUser!.gender,
        fitnessLevel: _currentUser!.fitnessLevel,
        goal: _currentUser!.goal,
        avatarUrl: _currentUser!.avatarUrl,
        createdAt: _currentUser!.createdAt,
        lastUpdated: DateTime.now(),
        weightHistory: _currentUser!.weightHistory,
        badges: _currentUser!.badges,
      );

      await _userService.updateUser(updatedUser);
      await _loadUser();
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour'),
          backgroundColor: Color(0xFFa3e635),
        ),
      );
    }
  }

  void _regenerateAvatar() {
    if (_currentUser != null) {
      print('🔄 Régénération de l\'avatar...');
      AvatarService.debugAvatarGeneration(_currentUser!);
      
      final newAvatarUrl = AvatarService.generateUserAvatar(_currentUser!);
      _updateUserAvatar(newAvatarUrl);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar régénéré avec les caractéristiques correctes'),
          backgroundColor: Color(0xFFa3e635),
        ),
      );
    }
  }

  Widget _buildAvatar() {
    if (_currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty) {
      print('🖼️ Chargement avatar: ${_currentUser!.avatarUrl}');
      
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1a1a1a),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: _currentUser!.avatarUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildLoadingAvatar(),
            errorWidget: (context, url, error) {
              print('❌ Erreur chargement avatar: $error');
              _regenerateSimpleAvatar();
              return _buildLoadingAvatar();
            },
          ),
        ),
      );
    }
    return _buildFallbackAvatar();
  }

  void _regenerateSimpleAvatar() {
    if (_currentUser != null) {
      final simpleAvatar = AvatarService.generateFallbackAvatar(_currentUser!.email);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateUserAvatar(simpleAvatar);
      });
    }
  }

  Future<void> _updateUserAvatar(String avatarUrl) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(avatarUrl: avatarUrl);
      await _userService.updateUser(updatedUser);
      setState(() {
        _currentUser = updatedUser;
      });
      print('🔄 Avatar mis à jour');
    }
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2d2d2d),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFa3e635),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2d2d2d),
        border: Border.all(
          color: const Color(0xFF1a1a1a),
          width: 4,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 50,
          color: const Color(0xFFa3e635),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFa3e635), Color(0xFF22c55e)],
                      ),
                    ),
                  ),
                  
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  Positioned(
                    top: 16,
                    right: 80,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: _regenerateAvatar,
                    ),
                  ),
                  
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        if (_isEditing) {
                          _saveProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                    ),
                  ),
                  
                  Positioned(
                    bottom: -60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildAvatar(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 70),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _isEditing
                        ? TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF2d2d2d),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          )
                        : Text(
                            _currentUser!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(height: 8),
                    Text(
                      _currentUser!.email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildInfoRow('Genre', _currentUser!.gender),
                    _buildInfoRow('Objectif', _getGoalText()),
                    _buildInfoRow('Niveau', _getFitnessLevelText()),
                    
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Caractéristiques physiques'),
                    const SizedBox(height: 16),
                    
                    _buildEditableField(
                      label: 'Âge',
                      controller: _ageController,
                      icon: Icons.cake,
                      suffix: 'ans',
                    ),
                    const SizedBox(height: 12),
                    
                    _buildEditableField(
                      label: 'Poids',
                      controller: _weightController,
                      icon: Icons.monitor_weight,
                      suffix: 'kg',
                    ),
                    const SizedBox(height: 12),
                    
                    _buildEditableField(
                      label: 'Taille',
                      controller: _heightController,
                      icon: Icons.height,
                      suffix: 'cm',
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _currentUser!.bmiColor.withOpacity(0.3),
                            _currentUser!.bmiColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'INDICE DE MASSE CORPORELLE',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentUser!.bmi.toStringAsFixed(1),
                                style: TextStyle(
                                  color: _currentUser!.bmiColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _currentUser!.bmiCategory,
                                style: TextStyle(
                                  color: _currentUser!.bmiColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.fitness_center,
                            color: _currentUser!.bmiColor,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                _isEditing
                    ? TextField(
                        controller: controller,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        '${controller.text} $suffix',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGoalText() {
    switch (_currentUser!.goal) {
      case 'weight_loss': return 'Perte de poids';
      case 'muscle_gain': return 'Prise de muscle';
      case 'endurance': return 'Endurance';
      default: return 'Bien-être';
    }
  }

  String _getFitnessLevelText() {
    switch (_currentUser!.fitnessLevel) {
      case 'beginner': return 'Débutant';
      case 'intermediate': return 'Intermédiaire';
      case 'advanced': return 'Avancé';
      default: return 'Standard';
    }
  }
}