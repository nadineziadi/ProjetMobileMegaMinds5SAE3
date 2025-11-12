// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math';

// class MotivationScreen extends StatefulWidget {
//   const MotivationScreen({Key? key}) : super(key: key);

//   @override
//   State<MotivationScreen> createState() => _MotivationScreenState();
// }

// class _MotivationScreenState extends State<MotivationScreen> with SingleTickerProviderStateMixin {
//   int _currentQuoteIndex = 0;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   final List<Map<String, String>> _quotes = [
//     {
//       'text': 'The only way to do great work is to love what you do.',
//       'author': 'Steve Jobs'
//     },
//     {
//       'text': 'Believe you can and you\'re halfway there.',
//       'author': 'Theodore Roosevelt'
//     },
//     {
//       'text': 'Your mental health is everything. Prioritize it.',
//       'author': 'Unknown'
//     },
//     {
//       'text': 'You don\'t have to be positive all the time. It\'s perfectly okay to feel sad, angry, annoyed, frustrated, scared, and anxious.',
//       'author': 'Lori Deschene'
//     },
//     {
//       'text': 'Taking care of yourself doesn\'t mean me first, it means me too.',
//       'author': 'L.R. Knost'
//     },
//     {
//       'text': 'Be patient with yourself. Self-growth is tender; it\'s holy ground.',
//       'author': 'Stephen Covey'
//     },
//     {
//       'text': 'You are enough just as you are.',
//       'author': 'Meghan Markle'
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//     _animationController.forward();
//   }

//   void _generateNewQuote() {
//     _animationController.reverse().then((_) {
//       setState(() {
//         _currentQuoteIndex = Random().nextInt(_quotes.length);
//       });
//       _animationController.forward();
//     });
//   }

//   void _shareQuote() {
//     final quote = _quotes[_currentQuoteIndex];
//     Clipboard.setData(
//       ClipboardData(text: '"${quote['text']}"\n- ${quote['author']}'),
//     );
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Quote copied to clipboard!'),
//         backgroundColor: Color(0xFF4CAF50),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentQuote = _quotes[_currentQuoteIndex];

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color(0xFF7F7FD5),
//               const Color(0xFF86A8E7),
//               const Color(0xFF91EAE4),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     const Text(
//                       'Daily Motivation',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.more_vert, color: Colors.white),
//                       onPressed: () {},
//                     ),
//                   ],
//                 ),
//               ),

//               // Quote Card
//               Expanded(
//                 child: Center(
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Padding(
//                       padding: const EdgeInsets.all(32),
//                       child: Container(
//                         padding: const EdgeInsets.all(32),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.9),
//                           borderRadius: BorderRadius.circular(30),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 20,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Quote Icon
//                             Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     const Color(0xFF7F7FD5),
//                                     const Color(0xFF91EAE4),
//                                   ],
//                                 ),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.format_quote,
//                                 color: Colors.white,
//                                 size: 32,
//                               ),
//                             ),

//                             const SizedBox(height: 32),

//                             // Quote Text
//                             Text(
//                               currentQuote['text']!,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w500,
//                                 color: Color(0xFF2C3E50),
//                                 height: 1.5,
//                               ),
//                             ),

//                             const SizedBox(height: 24),

//                             // Author
//                             Text(
//                               '— ${currentQuote['author']}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontStyle: FontStyle.italic,
//                                 color: Color(0xFF7F8C8D),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Action Buttons
//               Padding(
//                 padding: const EdgeInsets.all(32),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     // Share Button
//                     _buildActionButton(
//                       icon: Icons.share,
//                       label: 'Share',
//                       onTap: _shareQuote,
//                     ),

//                     // New Quote Button
//                     _buildActionButton(
//                       icon: Icons.refresh,
//                       label: 'New Quote',
//                       onTap: _generateNewQuote,
//                       isPrimary: true,
//                     ),

//                     // Favorite Button
//                     _buildActionButton(
//                       icon: Icons.favorite_border,
//                       label: 'Save',
//                       onTap: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Quote saved!'),
//                             backgroundColor: Color(0xFFFF69B4),
//                             duration: Duration(seconds: 2),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // Quote Counter
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     min(_quotes.length, 5),
//                     (index) => Container(
//                       width: 8,
//                       height: 8,
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         color: index == _currentQuoteIndex % 5
//                             ? Colors.white
//                             : Colors.white.withOpacity(0.4),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     bool isPrimary = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 80,
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isPrimary
//               ? Colors.white
//               : Colors.white.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: isPrimary
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: isPrimary ? const Color(0xFF7F7FD5) : Colors.white,
//               size: 28,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isPrimary ? const Color(0xFF7F7FD5) : Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }
// lib/pages/mental_health/motivation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/mental_health_models.dart';
import '../../services/mental_health_service.dart';
import '../../services/database_helper.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({Key? key}) : super(key: key);

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> with SingleTickerProviderStateMixin {
  final MentalHealthService _service = MentalHealthService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  Quote? _currentQuote;
  bool _isLoading = true;
  bool _isFavorite = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQuote();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadQuote() async {
    setState(() => _isLoading = true);
    
    try {
      final quote = await _service.getTodayQuote();
      
      setState(() {
        _currentQuote = quote;
        _isFavorite = quote.isFavorite;
        _isLoading = false;
      });
      
      _animationController.forward(from: 0.0);
    } catch (e) {
      print('Error loading quote: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateNewQuote() async {
    _animationController.reverse().then((_) async {
      setState(() => _isLoading = true);
      
      try {
        final quote = await _service.fetchDailyQuote();
        
        setState(() {
          _currentQuote = quote;
          _isFavorite = quote?.isFavorite ?? false;
          _isLoading = false;
        });
        
        _animationController.forward();
        
        _showSnackBar('New quote loaded!', Colors.green);
      } catch (e) {
        print('Error generating new quote: $e');
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load new quote', Colors.red);
      }
    });
  }

  Future<void> _shareQuote() async {
    if (_currentQuote == null) return;
    
    final quote = '"${_currentQuote!.text}"\n- ${_currentQuote!.author}';
    
    await Clipboard.setData(ClipboardData(text: quote));
    _showSnackBar('Quote copied to clipboard!', const Color(0xFF4CAF50));
  }

  Future<void> _toggleFavorite() async {
    if (_currentQuote == null) return;
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    try {
      await _dbHelper.toggleQuoteFavorite(_currentQuote!.id, _isFavorite);
      
      _showSnackBar(
        _isFavorite ? 'Added to favorites!' : 'Removed from favorites',
        _isFavorite ? Colors.pink : Colors.grey,
      );
    } catch (e) {
      print('Error toggling favorite: $e');
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7F7FD5),
              const Color(0xFF86A8E7),
              const Color(0xFF91EAE4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Daily Motivation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.pink[300] : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                ),
              ),

              // Quote Card
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : _currentQuote == null
                          ? _buildErrorState()
                          : _buildQuoteCard(),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: _shareQuote,
                    ),
                    _buildActionButton(
                      icon: Icons.refresh,
                      label: 'New Quote',
                      onTap: _generateNewQuote,
                      isPrimary: true,
                    ),
                    _buildActionButton(
                      icon: Icons.download,
                      label: 'Save',
                      onTap: _toggleFavorite,
                    ),
                  ],
                ),
              ),

              // API Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_done,
                            size: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Powered by ZenQuotes API',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
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

  Widget _buildQuoteCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quote Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7F7FD5),
                        const Color(0xFF91EAE4),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.format_quote,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 32),

                // Quote Text
                Text(
                  _currentQuote!.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7F7FD5),
                        const Color(0xFF91EAE4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Author
                Text(
                  '— ${_currentQuote!.author}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Timestamp
                if (_currentQuote!.fetchedAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Fetched ${_getTimeAgo(_currentQuote!.fetchedAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Failed to load quote',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Check your internet connection',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7F7FD5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white
              : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? const Color(0xFF7F7FD5) : Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? const Color(0xFF7F7FD5) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}