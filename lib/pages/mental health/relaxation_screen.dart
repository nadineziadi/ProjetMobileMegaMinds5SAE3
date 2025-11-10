import 'package:flutter/material.dart';
import 'dart:async';

class RelaxationScreen extends StatefulWidget {
  const RelaxationScreen({Key? key}) : super(key: key);

  @override
  State<RelaxationScreen> createState() => _RelaxationScreenState();
}

class _RelaxationScreenState extends State<RelaxationScreen> {
  int _selectedCategory = 0;
  bool _isPlaying = false;
  int _currentSeconds = 0;
  int _totalSeconds = 300; // 5 minutes
  Timer? _timer;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.air, 'label': 'Breathing', 'color': Color(0xFF7FDBDA)},
    {'icon': Icons.self_improvement, 'label': 'Meditation', 'color': Color(0xFFB8B5FF)},
    {'icon': Icons.music_note, 'label': 'Music', 'color': Color(0xFFFFB6C1)},
    {'icon': Icons.spa, 'label': 'Yoga', 'color': Color(0xFF90EE90)},
  ];

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Deep Breathing',
      'subtitle': 'Calm your mind',
      'duration': '5 min',
      'image': Icons.air,
      'color': Color(0xFF7FDBDA),
    },
    {
      'title': 'Body Scan',
      'subtitle': 'Release tension',
      'duration': '10 min',
      'image': Icons.person_outline,
      'color': Color(0xFFB8B5FF),
    },
    {
      'title': 'Guided Meditation',
      'subtitle': 'Inner peace',
      'duration': '15 min',
      'image': Icons.self_improvement,
      'color': Color(0xFFFFB6C1),
    },
  ];

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
      ),
      body: Column(
        children: [
          // Category Tabs
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
                  onTap: () {
                    setState(() {
                      _selectedCategory = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category['color']
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? Colors.white : Colors.white70,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
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

          // Exercises List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                return _buildExerciseCard(_exercises[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return GestureDetector(
      onTap: () {
        _showExercisePlayer(exercise);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              exercise['color'].withOpacity(0.3),
              exercise['color'].withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: exercise['color'],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                exercise['image'],
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise['subtitle'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: exercise['color'],
                  size: 40,
                ),
                const SizedBox(height: 4),
                Text(
                  exercise['duration'],
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

  void _showExercisePlayer(Map<String, dynamic> exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  exercise['color'].withOpacity(0.8),
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
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    exercise['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    exercise['subtitle'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(),

                  // Animation Circle
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Icon(
                        exercise['image'],
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Timer
                  Text(
                    _formatTime(_currentSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        iconSize: 40,
                        onPressed: () {
                          setModalState(() {
                            _currentSeconds = (_currentSeconds - 10).clamp(0, _totalSeconds);
                          });
                        },
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _isPlaying = !_isPlaying;
                            if (_isPlaying) {
                              _startTimer(setModalState);
                            } else {
                              _stopTimer();
                            }
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 48,
                            color: exercise['color'],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        iconSize: 40,
                        onPressed: () {
                          setModalState(() {
                            _currentSeconds = (_currentSeconds + 10).clamp(0, _totalSeconds);
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) {
      _stopTimer();
      setState(() {
        _isPlaying = false;
        _currentSeconds = 0;
      });
    });
  }

  void _startTimer(StateSetter setModalState) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds >= _totalSeconds) {
        _stopTimer();
        setModalState(() {
          _isPlaying = false;
        });
      } else {
        setModalState(() {
          _currentSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}