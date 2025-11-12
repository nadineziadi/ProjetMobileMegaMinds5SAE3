// lib/pages/mental_health/wellness_hub_screen.dart

import 'package:flutter/material.dart';
import '../../models/mental_health_models.dart';
import '../../services/mental_health_service.dart';

class WellnessHubScreen extends StatefulWidget {
  const WellnessHubScreen({Key? key}) : super(key: key);

  @override
  State<WellnessHubScreen> createState() => _WellnessHubScreenState();
}

class _WellnessHubScreenState extends State<WellnessHubScreen> {
  int _selectedFilterIndex = 0;
  final MentalHealthService _service = MentalHealthService();
  
  List<WellnessPost> _posts = [];
  bool _isLoading = true;
  
  final List<String> _filters = ['All', 'Therapy', 'Relationship', 'Self-Care', 'Work'];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    
    try {
      final category = _selectedFilterIndex == 0 
          ? null 
          : _filters[_selectedFilterIndex].toLowerCase();
      
      final posts = await _service.getWellnessPosts(category: category);
      
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike(WellnessPost post) async {
    final success = await _service.togglePostLike(post);
    if (success) {
      _loadPosts(); // Recharger pour afficher les nouvelles données
    }
  }

  void _showCreatePostDialog() {
    String selectedCategory = 'therapy';
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Share Your Wellness',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Selector
              const Text(
                'Category:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['therapy', 'relationship', 'self-care', 'work']
                    .map((category) => ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                selectedCategory = category;
                              });
                            }
                          },
                          backgroundColor: const Color(0xFF1E1E1E),
                          selectedColor: const Color(0xFFD4FF00),
                          labelStyle: TextStyle(
                            color: selectedCategory == category
                                ? Colors.black
                                : Colors.white,
                            fontSize: 12,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              
              // Content Field
              TextField(
                controller: contentController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts, questions, or experiences...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  final success = await _service.createWellnessPost(
                    contentController.text,
                    selectedCategory,
                  );
                  
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post shared successfully!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                    _loadPosts();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4FF00),
                foregroundColor: Colors.black,
              ),
              child: const Text('Share'),
            ),
          ],
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
          'Wellness Hub',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                      _loadPosts();
                    },
                    backgroundColor: const Color(0xFF2A2A2A),
                    selectedColor: const Color(0xFFD4FF00),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Posts List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4FF00),
                    ),
                  )
                : _posts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPosts,
                        color: const Color(0xFFD4FF00),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            return _buildPostCard(_posts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFFD4FF00),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Share',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your wellness journey!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePostDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4FF00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(WellnessPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getCategoryColor(post.category).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(post.category),
                      _getCategoryColor(post.category).withOpacity(0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2A2A2A),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(post.category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            post.category,
                            style: TextStyle(
                              color: _getCategoryColor(post.category),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            post.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(post),
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.pink : Colors.white54,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likes}',
                      style: TextStyle(
                        color: post.isLiked ? Colors.pink : Colors.white54,
                        fontSize: 14,
                        fontWeight: post.isLiked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white54),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'therapy':
        return const Color(0xFF7FDBDA);
      case 'relationship':
        return const Color(0xFFFF69B4);
      case 'self-care':
        return const Color(0xFFB8B5FF);
      case 'work':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF87CEEB);
    }
  }
}