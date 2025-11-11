// import 'package:flutter/material.dart';

// class MentalHealthHomeScreen extends StatefulWidget {
//   const MentalHealthHomeScreen({Key? key}) : super(key: key);

//   @override
//   State<MentalHealthHomeScreen> createState() => _MentalHealthHomeScreenState();
// }

// class _MentalHealthHomeScreenState extends State<MentalHealthHomeScreen> {
//   int _selectedMoodIndex = -1;
//   int _currentNavIndex = 0;

//   final List<Map<String, dynamic>> _moods = [
//     {'emoji': '😊', 'color': Color(0xFFFF69B4), 'label': 'Happy'},
//     {'emoji': '😌', 'color': Color(0xFFB8B5FF), 'label': 'Calm'},
//     {'emoji': '😄', 'color': Color(0xFFFFA500), 'label': 'Excited'},
//     {'emoji': '😐', 'color': Color(0xFF87CEEB), 'label': 'Neutral'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header avec profil et notifications
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Icon(Icons.menu, color: Colors.white, size: 28),
//                     Stack(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2A2A2A),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(
//                             Icons.notifications_outlined,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                         Positioned(
//                           right: 6,
//                           top: 6,
//                           child: Container(
//                             width: 10,
//                             height: 10,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFD4FF00),
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 24),

//                 // Welcome Message
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 24,
//                       backgroundColor: Colors.grey[800],
//                       child: const Icon(Icons.person, color: Colors.white),
//                     ),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Text(
//                         'Welcome back, Sarina!',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // Question "How are you feeling today?"
//                 const Text(
//                   'How are you feeling today ?',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Mood Selector
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: List.generate(_moods.length, (index) {
//                     final mood = _moods[index];
//                     final isSelected = _selectedMoodIndex == index;
                    
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedMoodIndex = index;
//                         });
//                       },
//                       child: Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: mood['color'],
//                           shape: BoxShape.circle,
//                           border: isSelected
//                               ? Border.all(color: Colors.white, width: 3)
//                               : null,
//                         ),
//                         child: Center(
//                           child: Text(
//                             mood['emoji'],
//                             style: const TextStyle(fontSize: 32),
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),

//                 const SizedBox(height: 32),

//                 // Section "Today's Task"
//                 const Text(
//                   "Today's Task",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Peer Group Meetup Card
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF0F5),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Peer Group Meetup',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Let's open up to the thing that matters among the people",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             ElevatedButton(
//                               onPressed: () {},
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.pink[400],
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 8,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                               child: const Text('Join Now'),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Image.asset(
//                         'assets/images/peer_group_icon.png',
//                         width: 60,
//                         height: 60,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: Colors.pink[200],
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.groups,
//                               color: Colors.white,
//                               size: 32,
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Meditation Card
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF6B5B4F),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Meditation',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFFD4A574),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               children: const [
//                                 Text(
//                                   '06:00 PM',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Icon(
//                                   Icons.alarm,
//                                   color: Colors.white70,
//                                   size: 16,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Image.asset(
//                         'assets/images/lotus_icon.png',
//                         width: 60,
//                         height: 60,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: 60,
//                             height: 60,
//                             child: const Icon(
//                               Icons.spa,
//                               color: Color(0xFFD4A574),
//                               size: 40,
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavBar(),
//     );
//   }

//   Widget _buildBottomNavBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF2A2A2A),
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(Icons.home_outlined, 0),
//               _buildNavItem(Icons.explore_outlined, 1),
//               _buildNavItem(Icons.circle_outlined, 2),
//               _buildNavItem(Icons.calendar_today_outlined, 3, 
//                 isHighlighted: true),
//               _buildNavItem(Icons.account_circle_outlined, 4),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, int index, {bool isHighlighted = false}) {
//     final isSelected = _currentNavIndex == index;
    
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _currentNavIndex = index;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isHighlighted 
//               ? const Color(0xFFD4FF00) 
//               : (isSelected ? Colors.white24 : Colors.transparent),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           icon,
//           color: isHighlighted ? Colors.black : Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }
// lib/pages/mental_health/home_screen.dart

import 'package:flutter/material.dart';
import '../../models/mental_health_models.dart';
import '../../services/mental_health_service.dart';
import 'mood_tracker_screen.dart';
import 'relaxation_screen.dart';

class MentalHealthHomeScreen extends StatefulWidget {
  const MentalHealthHomeScreen({Key? key}) : super(key: key);

  @override
  State<MentalHealthHomeScreen> createState() => _MentalHealthHomeScreenState();
}

class _MentalHealthHomeScreenState extends State<MentalHealthHomeScreen> with SingleTickerProviderStateMixin {
  int _selectedMoodIndex = -1;
  final MentalHealthService _service = MentalHealthService();
  
  List<DailyTask> _todayTasks = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'color': Color(0xFFFF69B4), 'label': 'Happy'},
    {'emoji': '😌', 'color': Color(0xFFB8B5FF), 'label': 'Calm'},
    {'emoji': '😄', 'color': Color(0xFFFFA500), 'label': 'Excited'},
    {'emoji': '😐', 'color': Color(0xFF87CEEB), 'label': 'Neutral'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final tasks = await _service.getTodayTasks();
      setState(() {
        _todayTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMoodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your mood first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final mood = _moods[_selectedMoodIndex];
    final entry = MoodEntry(
      date: DateTime.now(),
      mood: mood['label'].toLowerCase(),
      intensity: 4, // Default intensity
      note: null,
    );

    final success = await _service.saveMoodEntry(entry);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${mood['label']} mood saved!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate to mood tracker for more details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MoodTrackerScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFFD4FF00),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec profil et notifications
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4FF00),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Welcome Message
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFD4FF00),
                                Color(0xFFB8B5FF),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFF2A2A2A),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                'Sarina!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Question "How are you feeling today?"
                    const Text(
                      'How are you feeling today ?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood Selector avec animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_moods.length, (index) {
                        final mood = _moods[index];
                        final isSelected = _selectedMoodIndex == index;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMoodIndex = index;
                            });
                            _saveMood();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: isSelected ? 70 : 60,
                            height: isSelected ? 70 : 60,
                            decoration: BoxDecoration(
                              color: mood['color'],
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: mood['color'].withOpacity(0.5),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                mood['emoji'],
                                style: TextStyle(
                                  fontSize: isSelected ? 36 : 32,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Section "Today's Task"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Tasks",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_todayTasks.isNotEmpty)
                          Text(
                            '${_todayTasks.length} tasks',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tasks List
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4FF00),
                        ),
                      )
                    else if (_todayTasks.isEmpty)
                      _buildEmptyTasksWidget()
                    else
                      ..._todayTasks.map((task) => _buildTaskCard(task)).toList(),

                    const SizedBox(height: 16),

                    // Quick Actions
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            'Relax',
                            Icons.spa,
                            Color(0xFF7FDBDA),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RelaxationScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            'Track',
                            Icons.mood,
                            Color(0xFFFFB6C1),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MoodTrackerScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(DailyTask task) {
    Color cardColor;
    Color buttonColor;
    IconData icon;

    switch (task.type) {
      case 'meetup':
        cardColor = const Color(0xFFFFF0F5);
        buttonColor = Colors.pink[400]!;
        icon = Icons.groups;
        break;
      case 'meditation':
        cardColor = const Color(0xFF6B5B4F);
        buttonColor = const Color(0xFFD4A574);
        icon = Icons.spa;
        break;
      default:
        cardColor = const Color(0xFFE8F5E9);
        buttonColor = Colors.green[400]!;
        icon = Icons.task_alt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: task.type == 'meditation' ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: task.type == 'meditation' ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: task.type == 'meditation' ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.scheduledTime.hour.toString().padLeft(2, '0')}:${task.scheduledTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: task.type == 'meditation' ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: buttonColor,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for today',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job! Take some time to relax',
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

  Widget _buildQuickActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}