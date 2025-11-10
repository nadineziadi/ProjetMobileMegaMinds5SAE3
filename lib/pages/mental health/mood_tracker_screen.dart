// import 'package:flutter/material.dart';

// class MoodTrackerScreen extends StatefulWidget {
//   const MoodTrackerScreen({Key? key}) : super(key: key);

//   @override
//   State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
// }

// class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
//   int? _selectedMoodIndex;
//   final TextEditingController _noteController = TextEditingController();

//   final List<Map<String, dynamic>> _moods = [
//     {'emoji': '😊', 'label': 'Happy', 'color': Color(0xFFFFD700)},
//     {'emoji': '😰', 'label': 'Stressed', 'color': Color(0xFFFF6B6B)},
//     {'emoji': '😴', 'label': 'Tired', 'color': Color(0xFF9B9B9B)},
//     {'emoji': '💪', 'label': 'Motivated', 'color': Color(0xFF4CAF50)},
//     {'emoji': '😐', 'label': 'Neutral', 'color': Color(0xFF87CEEB)},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E1E1E),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Mood Tracker',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Question
//             const Text(
//               'How are you feeling today?',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               'Select your current mood',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),

//             const SizedBox(height: 32),

//             // Mood Selection
//             Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               children: List.generate(_moods.length, (index) {
//                 final mood = _moods[index];
//                 final isSelected = _selectedMoodIndex == index;

//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _selectedMoodIndex = index;
//                     });
//                   },
//                   child: Container(
//                     width: (MediaQuery.of(context).size.width - 64) / 3,
//                     padding: const EdgeInsets.symmetric(vertical: 20),
//                     decoration: BoxDecoration(
//                       color: isSelected 
//                           ? mood['color'].withOpacity(0.3)
//                           : const Color(0xFF2A2A2A),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: isSelected 
//                             ? mood['color']
//                             : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           mood['emoji'],
//                           style: const TextStyle(fontSize: 40),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           mood['label'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),

//             const SizedBox(height: 32),

//             // Note Section
//             const Text(
//               'Add a note (optional)',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             const SizedBox(height: 12),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A2A2A),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: TextField(
//                 controller: _noteController,
//                 maxLines: 4,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: const InputDecoration(
//                   hintText: 'What\'s on your mind?',
//                   hintStyle: TextStyle(color: Colors.white54),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // Weekly Mood Chart
//             const Text(
//               'Your mood this week',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             const SizedBox(height: 16),

//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A2A2A),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildDayMood('Mon', '😊', 0.8),
//                       _buildDayMood('Tue', '😰', 0.4),
//                       _buildDayMood('Wed', '💪', 0.9),
//                       _buildDayMood('Thu', '😴', 0.5),
//                       _buildDayMood('Fri', '😊', 0.85),
//                       _buildDayMood('Sat', '😐', 0.6),
//                       _buildDayMood('Sun', '?', 0.0),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),

//             // Save Button
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: _selectedMoodIndex != null
//                     ? () {
//                         // Save mood logic
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Mood saved successfully!'),
//                             backgroundColor: Color(0xFF4CAF50),
//                           ),
//                         );
//                         Navigator.pop(context);
//                       }
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFD4FF00),
//                   foregroundColor: Colors.black,
//                   disabledBackgroundColor: Colors.grey[800],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 child: const Text(
//                   'Save Mood',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDayMood(String day, String emoji, double intensity) {
//     return Column(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: intensity > 0 
//                 ? Color(0xFFD4FF00).withOpacity(intensity)
//                 : Colors.grey[800],
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Text(
//               emoji,
//               style: const TextStyle(fontSize: 20),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           day,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _noteController.dispose();
//     super.dispose();
//   }
// }
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
      intensity: 4, // Could be enhanced with a slider
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    final success = await _service.saveMoodEntry(entry);
    
    setState(() => _isSaving = false);

    if (success && mounted) {
      _showMessage('Mood saved successfully!', const Color(0xFF4CAF50));
      
      // Reload week moods
      await _loadWeekMoods();
      
      // Clear form
      setState(() {
        _selectedMoodIndex = null;
        _noteController.clear();
      });
      
      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      _showMessage('Failed to save mood', Colors.red);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
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

            // Mood Selection Grid
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
                        color: isSelected 
                            ? mood['color']
                            : Colors.transparent,
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
                          style: TextStyle(
                            fontSize: isSelected ? 44 : 40,
                          ),
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

            // Note Section
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

            const SizedBox(height: 32),

            // Weekly Mood Chart
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
                  Text(
                    '${_weekMoods.length} entries',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4FF00),
                    ),
                  )
                : _buildWeekMoodChart(),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
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
                    : const Text(
                        'Save Mood',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
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

    // Get last 7 days
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final dayMood = _weekMoods.firstWhere(
                (mood) =>
                    mood.date.year == day.year &&
                    mood.date.month == day.month &&
                    mood.date.day == day.day,
                orElse: () => MoodEntry(
                  date: day,
                  mood: 'none',
                  intensity: 0,
                ),
              );

              return _buildDayMood(
                _getDayLabel(day),
                _getMoodEmoji(dayMood.mood),
                dayMood.intensity / 5.0,
              );
            }).toList(),
          ),
        ],
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

  Widget _buildDayMood(String day, String emoji, double intensity) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: intensity > 0 
                ? Color(0xFFD4FF00).withOpacity(intensity)
                : Colors.grey[800],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
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