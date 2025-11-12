// lib/pages/mental_health/mood_tracker_screen.dart

import 'package:flutter/material.dart';
import '../../models/mental_health_models.dart';
import '../../services/mental_health_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int? _selectedMoodIndex;
  final TextEditingController _noteController = TextEditingController();
  final MentalHealthService _service = MentalHealthService();
  
  List<MoodEntry> _weekMoods = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _shareToWellnessHub = false;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy', 'color': Color(0xFFFFD700)},
    {'emoji': '😰', 'label': 'Stressed', 'color': Color(0xFFFF6B6B)},
    {'emoji': '😴', 'label': 'Tired', 'color': Color(0xFF9B9B9B)},
    {'emoji': '💪', 'label': 'Motivated', 'color': Color(0xFF4CAF50)},
    {'emoji': '😐', 'label': 'Neutral', 'color': Color(0xFF87CEEB)},
    {'emoji': '😌', 'label': 'Calm', 'color': Color(0xFFB8B5FF)},
  ];

  @override
  void initState() {
    super.initState();
    _loadWeekMoods();
  }

  Future<void> _loadWeekMoods() async {
    setState(() => _isLoading = true);
    try {
      final moods = await _service.getMoodHistory(days: 7);
      setState(() {
        _weekMoods = moods;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading week moods: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMoodIndex == null) {
      _showMessage('Please select your mood first!', Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    final mood = _moods[_selectedMoodIndex!];
    final entry = MoodEntry(
      date: DateTime.now(),
      mood: mood['label'].toLowerCase(),
      intensity: 4,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    final success = await _service.saveMoodEntry(entry);

    if (success && _shareToWellnessHub && _noteController.text.isNotEmpty) {
      await _shareToHub(mood, _noteController.text);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      _showMessage('Mood saved successfully!', const Color(0xFF4CAF50));
      await _loadWeekMoods();
      setState(() {
        _selectedMoodIndex = null;
        _noteController.clear();
        _shareToWellnessHub = false;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    } else {
      _showMessage('Failed to save mood', Colors.red);
    }
  }

  Future<void> _shareToHub(Map<String, dynamic> mood, String note) async {
    try {
      final postContent = "I'm feeling ${mood['label'].toLowerCase()} today. $note";
      await _service.createWellnessPost(postContent, 'self-care');
      _showMessage('Also shared to Wellness Hub!', const Color(0xFFD4FF00));
    } catch (e) {
      print('Error sharing to hub: $e');
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mood Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your current mood',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Mood Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _moods.length,
                      itemBuilder: (context, index) {
                        final mood = _moods[index];
                        final isSelected = _selectedMoodIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMoodIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? mood['color'].withOpacity(0.3)
                                  : const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? mood['color'] : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: mood['color'].withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mood['emoji'],
                                  style: TextStyle(fontSize: isSelected ? 44 : 40),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mood['label'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Add a note (optional)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'What\'s on your mind? Share your thoughts...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Share to Wellness Hub
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _shareToWellnessHub ? const Color(0xFFD4FF00) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _shareToWellnessHub,
                            onChanged: (value) {
                              setState(() {
                                _shareToWellnessHub = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFFD4FF00),
                            checkColor: Colors.black,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.share_outlined,
                                      color: Color(0xFFD4FF00),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Share to Wellness Hub',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Let others support you in your wellness journey',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Weekly mood chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your mood this week',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isLoading && _weekMoods.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4FF00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_weekMoods.length} entries',
                              style: const TextStyle(
                                color: Color(0xFFD4FF00),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Color(0xFFD4FF00)),
                          )
                        : _buildWeekMoodChart(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Save Button
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4FF00),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Save Mood',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            if (_shareToWellnessHub) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.share, size: 20),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekMoodChart() {
    if (_weekMoods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.sentiment_satisfied_alt,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No mood entries yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your mood to see insights',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF2A2A2A),
          const Color(0xFF1E1E1E),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) {
          final dayMood = _weekMoods.firstWhere(
            (mood) =>
                mood.date.year == day.year &&
                mood.date.month == day.month &&
                mood.date.day == day.day,
            orElse: () => MoodEntry(date: day, mood: 'none', intensity: 0),
          );

          return _buildDayMood(
            _getDayLabel(day),
            _getMoodEmoji(dayMood.mood),
            dayMood.intensity / 5.0,
            day.day == now.day && day.month == now.month,
          );
        }).toList(),
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(date.weekday - 1) % 7];
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'stressed':
        return '😰';
      case 'tired':
        return '😴';
      case 'motivated':
        return '💪';
      case 'neutral':
        return '😐';
      case 'calm':
        return '😌';
      case 'excited':
        return '😄';
      default:
        return '?';
    }
  }

  Widget _buildDayMood(String day, String emoji, double intensity, bool isToday) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: intensity > 0 ? Color(0xFFD4FF00).withOpacity(intensity) : Colors.grey[800],
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: const Color(0xFFD4FF00), width: 2) : null,
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isToday ? const Color(0xFFD4FF00) : Colors.white70,
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
