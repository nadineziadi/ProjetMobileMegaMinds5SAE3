// import 'package:flutter/material.dart';

// class MentalHealthDashboard extends StatefulWidget {
//   const MentalHealthDashboard({Key? key}) : super(key: key);

//   @override
//   State<MentalHealthDashboard> createState() => _MentalHealthDashboardState();
// }

// class _MentalHealthDashboardState extends State<MentalHealthDashboard> {
//   String _selectedPeriod = 'Daily';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E1E1E),
//         elevation: 0,
//         leading: const Icon(Icons.arrow_back, color: Colors.white),
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.notifications_outlined, color: Colors.white),
//                 onPressed: () {},
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFD4FF00),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Greeting
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Colors.grey[800],
//                   child: const Icon(Icons.person, color: Colors.white),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Hey Emily,',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Period Selector
//             Row(
//               children: [
//                 _buildPeriodButton('Daily'),
//                 const SizedBox(width: 8),
//                 _buildPeriodButton('Weekly'),
//                 const SizedBox(width: 8),
//                 _buildPeriodButton('Monthly'),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Mental Health Score Card
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2D4A4A),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Mental Health',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       // Circular Progress
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: 100,
//                             height: 100,
//                             child: CircularProgressIndicator(
//                               value: 0.9254,
//                               strokeWidth: 10,
//                               backgroundColor: Colors.white24,
//                               valueColor: const AlwaysStoppedAnimation<Color>(
//                                 Color(0xFF7FDBDA),
//                               ),
//                             ),
//                           ),
//                           const Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 '92.54%',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 'Mental',
//                                 style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 20),
//                       // Icon
//                       Expanded(
//                         child: Column(
//                           children: [
//                             const Text(
//                               'More\nPositivity',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF3D5A5A),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Icon(
//                                 Icons.self_improvement,
//                                 color: Color(0xFF7FDBDA),
//                                 size: 40,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Stats Grid
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatCard(
//                     '470',
//                     'kcal',
//                     'Calories',
//                     Icons.local_fire_department,
//                     const Color(0xFFFF6B6B),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     '618',
//                     'kcal',
//                     'Nutrition',
//                     Icons.restaurant,
//                     const Color(0xFFD4FF00),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatCard(
//                     '8h 30m',
//                     '',
//                     'Sleep\nDuration',
//                     Icons.bedtime,
//                     const Color(0xFF7B68EE),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     '70',
//                     'bpm',
//                     'Heart Rate',
//                     Icons.favorite,
//                     const Color(0xFFFF69B4),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavBar(),
//     );
//   }

//   Widget _buildPeriodButton(String period) {
//     final isSelected = _selectedPeriod == period;
    
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedPeriod = period;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFD4FF00) : const Color(0xFF2A2A2A),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           period,
//           style: TextStyle(
//             color: isSelected ? Colors.black : Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String value,
//     String unit,
//     String label,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2D4A4A),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         value,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       if (unit.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4, bottom: 2),
//                           child: Text(
//                             unit,
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: 28,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavBar() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFF2A2A2A),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(Icons.home_outlined, false),
//               _buildNavItem(Icons.explore_outlined, false),
//               _buildNavItem(Icons.circle_outlined, false),
//               _buildNavItem(Icons.calendar_today_outlined, true),
//               _buildNavItem(Icons.account_circle_outlined, false),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, bool isHighlighted) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isHighlighted ? const Color(0xFFD4FF00) : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(
//         icon,
//         color: isHighlighted ? Colors.black : Colors.white,
//         size: 24,
//       ),
//     );
//   }
// }
// lib/pages/mental_health/mental_health_dashboard.dart

import 'package:flutter/material.dart';
import '../../models/mental_health_models.dart';
import '../../services/mental_health_service.dart';

class MentalHealthDashboard extends StatefulWidget {
  const MentalHealthDashboard({Key? key}) : super(key: key);

  @override
  State<MentalHealthDashboard> createState() => _MentalHealthDashboardState();
}

class _MentalHealthDashboardState extends State<MentalHealthDashboard> {
  String _selectedPeriod = 'Daily';
  final MentalHealthService _service = MentalHealthService();
  
  MentalHealthStats? _currentStats;
  Map<String, dynamic>? _moodStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _service.getMentalHealthStats();
      final moodStats = await _service.getMoodStatistics(days: 30);
      
      setState(() {
        _currentStats = stats;
        _moodStats = moodStats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFD4FF00),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? _buildLoadingState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFD4FF00),
                                Color(0xFF7FDBDA),
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
                                'Hey Emily,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Here\'s your wellness overview',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Period Selector
                    Row(
                      children: [
                        _buildPeriodButton('Daily'),
                        const SizedBox(width: 8),
                        _buildPeriodButton('Weekly'),
                        const SizedBox(width: 8),
                        _buildPeriodButton('Monthly'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Mental Health Score Card
                    _buildMentalHealthCard(),

                    const SizedBox(height: 16),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${_currentStats?.caloriesBurned ?? 470}',
                            'kcal',
                            'Calories',
                            Icons.local_fire_department,
                            const Color(0xFFFF6B6B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '${_currentStats?.nutritionCalories ?? 618}',
                            'kcal',
                            'Nutrition',
                            Icons.restaurant,
                            const Color(0xFFD4FF00),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            _currentStats?.formattedSleepDuration ?? '8h 30m',
                            '',
                            'Sleep\nDuration',
                            Icons.bedtime,
                            const Color(0xFF7B68EE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '${_currentStats?.heartRate ?? 70}',
                            'bpm',
                            'Heart Rate',
                            Icons.favorite,
                            const Color(0xFFFF69B4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Mood Statistics
                    if (_moodStats != null) _buildMoodStatsCard(),

                    const SizedBox(height: 80),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4FF00),
        ),
      ),
    );
  }

  Widget _buildMentalHealthCard() {
    final score = _currentStats?.mentalHealthScore ?? 92.54;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2D4A4A),
            Color(0xFF234040),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mental Health Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getScoreLabel(score),
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Circular Progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(score),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Score',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Insights
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getInsightTitle(score),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getInsightDescription(score),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D5A5A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getInsightIcon(score),
                        color: _getScoreColor(score),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF7FDBDA);
    if (score >= 60) return const Color(0xFFFFD700);
    return const Color(0xFFFF6B6B);
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    return 'Needs Care';
  }

  String _getInsightTitle(double score) {
    if (score >= 80) return 'Great Progress!';
    if (score >= 60) return 'Keep Going';
    return 'Self-Care Needed';
  }

  String _getInsightDescription(double score) {
    if (score >= 80) return 'You\'re maintaining excellent mental wellness';
    if (score >= 60) return 'Your mental health is on a good track';
    return 'Consider taking more time for self-care';
  }

  IconData _getInsightIcon(double score) {
    if (score >= 80) return Icons.emoji_events;
    if (score >= 60) return Icons.trending_up;
    return Icons.self_improvement;
  }

  Widget _buildMoodStatsCard() {
    final mostFrequentMood = _moodStats!['mostFrequentMood'] as String;
    final totalEntries = _moodStats!['totalEntries'] as int;
    final avgIntensity = _moodStats!['averageIntensity'] as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D4A4A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Insights',
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
                child: _buildMoodInsightItem(
                  'Most Frequent',
                  _getMoodEmoji(mostFrequentMood),
                  mostFrequentMood.toUpperCase(),
                ),
              ),
              Expanded(
                child: _buildMoodInsightItem(
                  'Total Entries',
                  '📊',
                  '$totalEntries',
                ),
              ),
              Expanded(
                child: _buildMoodInsightItem(
                  'Avg Intensity',
                  '⭐',
                  '${avgIntensity.toStringAsFixed(1)}/5',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodInsightItem(String label, String emoji, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return '😊';
      case 'stressed': return '😰';
      case 'tired': return '😴';
      case 'motivated': return '💪';
      case 'calm': return '😌';
      case 'excited': return '😄';
      default: return '😐';
    }
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Color(0xFFD4FF00),
                    Color(0xFFC7F000),
                  ],
                )
              : null,
          color: isSelected ? null : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String unit,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D4A4A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unit.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(
                              unit,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}