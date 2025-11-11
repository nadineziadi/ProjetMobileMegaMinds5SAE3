// lib/pages/mental_health/relaxation_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../models/mental_health_models.dart';
import '../../services/mental_health_service.dart';

class RelaxationScreen extends StatefulWidget {
  const RelaxationScreen({Key? key}) : super(key: key);

  @override
  State<RelaxationScreen> createState() => _RelaxationScreenState();
}

class _RelaxationScreenState extends State<RelaxationScreen> with TickerProviderStateMixin {
  int _selectedCategory = 0;
  final MentalHealthService _service = MentalHealthService();
  
  List<RelaxationExercise> _allExercises = [];
  List<RelaxationExercise> _filteredExercises = [];
  MoodEntry? _lastMood;
  RelaxationExercise? _recommendedExercise;
  bool _isLoading = true;
  int _completedToday = 0;
  int _totalCompleted = 0;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // 🎵 PLAYLISTS RÉELLES POUR CHAQUE CATÉGORIE
  final Map<String, List<Map<String, String>>> _musicPlaylists = {
    'relaxation': [
      {
        'title': 'Peaceful Piano',
        'artist': 'Spotify',
        'url': 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
        'platform': 'Spotify'
      },
      {
        'title': 'Deep Sleep',
        'artist': 'YouTube',
        'url': 'https://www.youtube.com/watch?v=1ZYbU82GVz4',
        'platform': 'YouTube'
      },
      {
        'title': 'Calm Meditation',
        'artist': 'Apple Music',
        'url': 'https://music.apple.com/us/playlist/peaceful-meditation/pl.7cbbdba6d6b14c9f',
        'platform': 'Apple Music'
      },
    ],
    'stress': [
      {
        'title': 'Stress Relief',
        'artist': 'Spotify',
        'url': 'https://open.spotify.com/playlist/37i9dQZF1DX3Ogo9pFvBkY',
        'platform': 'Spotify'
      },
      {
        'title': 'Anxiety Relief Music',
        'artist': 'YouTube',
        'url': 'https://www.youtube.com/watch?v=Z2iZfGzLmuk',
        'platform': 'YouTube'
      },
    ],
    'focus': [
      {
        'title': 'Deep Focus',
        'artist': 'Spotify',
        'url': 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
        'platform': 'Spotify'
      },
      {
        'title': 'Concentration Music',
        'artist': 'YouTube',
        'url': 'https://www.youtube.com/watch?v=4ozyV3m4wtY',
        'platform': 'YouTube'
      },
    ],
    'sleep': [
      {
        'title': 'Sleep Meditation',
        'artist': 'Calm',
        'url': 'https://www.youtube.com/watch?v=WNpbS-iyE-8',
        'platform': 'YouTube'
      },
      {
        'title': 'Deep Sleep Sounds',
        'artist': 'Spotify',
        'url': 'https://open.spotify.com/playlist/37i9dQZF1DWZd79rJ6a7lp',
        'platform': 'Spotify'
      },
    ],
    'energy': [
      {
        'title': 'Morning Motivation',
        'artist': 'Spotify',
        'url': 'https://open.spotify.com/playlist/37i9dQZF1DXc5e2bJhV6pu',
        'platform': 'Spotify'
      },
      {
        'title': 'Positive Vibes',
        'artist': 'YouTube',
        'url': 'https://www.youtube.com/watch?v=3AtDnEC4zak',
        'platform': 'YouTube'
      },
    ]
  };

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.air, 'label': 'All', 'value': null},
    {'icon': Icons.air, 'label': 'Breathing', 'value': 'breathing', 'color': Color(0xFF7FDBDA)},
    {'icon': Icons.self_improvement, 'label': 'Meditation', 'value': 'meditation', 'color': Color(0xFFB8B5FF)},
    {'icon': Icons.music_note, 'label': 'Music', 'value': 'music', 'color': Color(0xFFFFB6C1)},
    {'icon': Icons.spa, 'label': 'Yoga', 'value': 'yoga', 'color': Color(0xFF90EE90)},
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final exercises = await _service.getRelaxationExercises();
      final moodHistory = await _service.getMoodHistory(days: 1);
      final lastMood = moodHistory.isNotEmpty ? moodHistory.first : null;
      
      RelaxationExercise? recommended;
      if (lastMood != null) {
        recommended = await _service.recommendExercise(lastMood.mood);
      }
      
      final completedExercises = exercises.where((e) => e.isCompleted).toList();
      final today = DateTime.now();
      final completedToday = completedExercises.where((e) {
        if (e.lastCompletedAt == null) return false;
        final completedDate = e.lastCompletedAt!;
        return completedDate.year == today.year &&
               completedDate.month == today.month &&
               completedDate.day == today.day;
      }).length;
      
      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _lastMood = lastMood;
        _recommendedExercise = recommended;
        _completedToday = completedToday;
        _totalCompleted = completedExercises.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading relaxation data: $e');
      setState(() => _isLoading = false);
    }
  }

  // 🎵 FONCTION POUR LANCER LA MUSIQUE SUR LA PLATEFORME
  Future<void> _launchMusic(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching music: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open music link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🎵 RECOMMANDATIONS DE MUSIQUE INTELLIGENTES BASÉES SUR L'HUMEUR
  List<Map<String, String>> _getRecommendedMusic(String mood) {
    switch (mood.toLowerCase()) {
      case 'stressed':
      case 'anxious':
        return _musicPlaylists['stress'] ?? [];
      case 'tired':
      case 'sleepy':
        return _musicPlaylists['sleep'] ?? [];
      case 'sad':
      case 'depressed':
        return _musicPlaylists['relaxation'] ?? [];
      case 'focused':
      case 'productive':
        return _musicPlaylists['focus'] ?? [];
      case 'energetic':
      case 'happy':
        return _musicPlaylists['energy'] ?? [];
      default:
        return _musicPlaylists['relaxation'] ?? [];
    }
  }

  void _filterByCategory(int index) {
    setState(() {
      _selectedCategory = index;
      final category = _categories[index]['value'];
      
      if (category == null) {
        _filteredExercises = _allExercises;
      } else {
        _filteredExercises = _allExercises
            .where((e) => e.category == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Relaxation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD4FF00), Color(0xFF7FDBDA)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.black, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_completedToday today',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFD4FF00),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(),
                    
                    if (_recommendedExercise != null && _lastMood != null)
                      _buildRecommendationCard(),
                    
                    // 🎵 SECTION MUSIQUE RECOMMANDÉE (NOUVELLE)
                    if (_lastMood != null && _selectedCategory != 3)
                      _buildMusicRecommendationSection(),
                    
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == index;

                          return GestureDetector(
                            onTap: () => _filterByCategory(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          category['color'] ?? Color(0xFFD4FF00),
                                          (category['color'] ?? Color(0xFFD4FF00)).withOpacity(0.6),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (category['color'] ?? Color(0xFFD4FF00)).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    category['icon'],
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category['label'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${_filteredExercises.length} Exercises',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _filteredExercises.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredExercises.length,
                            itemBuilder: (context, index) {
                              return _buildExerciseCard(_filteredExercises[index]);
                            },
                          ),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  // ========== FONCTIONS MANQUANTES ==========

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2D4A4A),
            Color(0xFF1E1E1E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Breathing Animation
          ScaleTransition(
            scale: _breathingAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7FDBDA),
                    Color(0xFFB8B5FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7FDBDA).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.air,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_completedToday completed today',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalCompleted total exercises',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4FF00).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_totalCompleted / 10).ceil()}',
                  style: const TextStyle(
                    color: Color(0xFFD4FF00),
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

  Widget _buildRecommendationCard() {
    final exercise = _recommendedExercise!;
    final mood = _lastMood!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(exercise.category).withOpacity(0.3),
            _getCategoryColor(exercise.category).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCategoryColor(exercise.category),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(exercise.category).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFFD4FF00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended for you',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Based on your ${mood.mood} mood',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(exercise.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(exercise.category),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      exercise.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showExercisePlayer(exercise),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getCategoryColor(exercise.category),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎵 NOUVELLE SECTION PUREMENT MUSICALE
  Widget _buildMusicRecommendationSection() {
    final recommendedMusic = _getRecommendedMusic(_lastMood!.mood);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFB6C1).withOpacity(0.3),
            Color(0xFFFFB6C1).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFFFB6C1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: Color(0xFFFFB6C1), size: 20),
              const SizedBox(width: 8),
              Text(
                'Music for ${_lastMood!.mood} mood',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendedMusic.take(2).map((music) => _buildMusicTile(music)),
        ],
      ),
    );
  }

  // 🎵 TILE DE MUSIQUE CLICKABLE
  Widget _buildMusicTile(Map<String, String> music) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFFFB6C1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.play_arrow, color: Colors.white),
      ),
      title: Text(
        music['title']!,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${music['artist']!} • ${music['platform']!}',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getPlatformColor(music['platform']!),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          music['platform']!,
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () => _launchMusic(music['url']!),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises in this category',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(RelaxationExercise exercise) {
    final color = _getCategoryColor(exercise.category);
    
    return GestureDetector(
      onTap: () => _showExercisePlayer(exercise),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: exercise.isCompleted
              ? Border.all(color: const Color(0xFFD4FF00), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(exercise.category),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                if (exercise.isCompleted)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4FF00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  if (exercise.lastCompletedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last: ${_formatDate(exercise.lastCompletedAt!)}',
                      style: TextStyle(
                        color: const Color(0xFFD4FF00).withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: color,
                  size: 40,
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.durationMinutes} min',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== FONCTIONS SUPPLEMENTAIRES ==========

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'spotify':
        return Color(0xFF1DB954);
      case 'youtube':
        return Color(0xFFFF0000);
      case 'apple music':
        return Color(0xFFFA243C);
      default:
        return Color(0xFFFFB6C1);
    }
  }

  void _showExercisePlayer(RelaxationExercise exercise) {
    // 🎵 SI C'EST UN EXERCICE DE MUSIQUE, OUVRE DIRECTEMENT LES PLAYLISTS
    if (exercise.category == 'music') {
      _showMusicSelection(exercise);
      return;
    }

    final color = _getCategoryColor(exercise.category);
    int currentSeconds = 0;
    bool isPlaying = false;
    Timer? timer;
    final totalSeconds = exercise.durationMinutes * 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          void startTimer() {
            timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (currentSeconds >= totalSeconds) {
                timer?.cancel();
                setModalState(() {
                  isPlaying = false;
                });
                _completeExercise(exercise);
              } else {
                setModalState(() {
                  currentSeconds++;
                });
              }
            });
          }

          void stopTimer() {
            timer?.cancel();
          }

          return WillPopScope(
            onWillPop: () async {
              stopTimer();
              return true;
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withOpacity(0.9),
                    const Color(0xFF1E1E1E),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            stopTimer();
                            Navigator.pop(context);
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            exercise.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    ScaleTransition(
                      scale: isPlaying
                          ? _breathingAnimation
                          : AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: isPlaying
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(exercise.category),
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: currentSeconds / totalSeconds,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(currentSeconds),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatTime(totalSeconds),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _formatTime(currentSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white),
                          iconSize: 40,
                          onPressed: () {
                            setModalState(() {
                              currentSeconds = (currentSeconds - 10).clamp(0, totalSeconds);
                            });
                          },
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              isPlaying = !isPlaying;
                              if (isPlaying) {
                                startTimer();
                              } else {
                                stopTimer();
                              }
                            });
                          },
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 50,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white),
                          iconSize: 40,
                          onPressed: () {
                            setModalState(() {
                              currentSeconds = (currentSeconds + 10).clamp(0, totalSeconds);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🎵 NOUVELLE FONCTION POUR LA SÉLECTION DE MUSIQUE
  void _showMusicSelection(RelaxationExercise exercise) {
    final recommendedMusic = _lastMood != null 
        ? _getRecommendedMusic(_lastMood!.mood)
        : _musicPlaylists['relaxation'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB6C1).withOpacity(0.9),
              const Color(0xFF1E1E1E),
            ],
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Choose Your Music',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Recommended for your ${_lastMood?.mood ?? 'current'} mood',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: recommendedMusic.length,
                  itemBuilder: (context, index) {
                    final music = recommendedMusic[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getPlatformColor(music['platform']!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.music_note, color: Colors.white),
                        ),
                        title: Text(
                          music['title']!,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${music['artist']!} • ${music['platform']!}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Icon(Icons.play_arrow, color: Colors.white),
                        onTap: () {
                          _launchMusic(music['url']!);
                          _completeExercise(exercise);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeExercise(RelaxationExercise exercise) async {
    await _service.completeExercise(exercise.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${exercise.title} completed! 🎉'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      _loadData();
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'breathing':
        return const Color(0xFF7FDBDA);
      case 'meditation':
        return const Color(0xFFB8B5FF);
      case 'music':
        return const Color(0xFFFFB6C1);
      case 'yoga':
        return const Color(0xFF90EE90);
      default:
        return const Color(0xFF87CEEB);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'breathing':
        return Icons.air;
      case 'meditation':
        return Icons.self_improvement;
      case 'music':
        return Icons.music_note;
      case 'yoga':
        return Icons.spa;
      default:
        return Icons.favorite;
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }
}