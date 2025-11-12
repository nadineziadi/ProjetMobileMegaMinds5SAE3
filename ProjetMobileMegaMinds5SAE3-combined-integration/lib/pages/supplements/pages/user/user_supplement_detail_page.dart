import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/supplement.dart';
import '../../models/review.dart';
import '../../models/purchase_history.dart';
import '../../services/supplement_database_service.dart';
import '../../widgets/review_widget.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/interactive_rating_stars.dart';
import 'payment_screen.dart';

bool get isAdmin => false; // User version - no admin privileges

enum ReviewSortOption {
  mostRecent,
  mostLiked,
}

class UserSupplementDetailPage extends StatefulWidget {
  final Supplement supplement;

  const UserSupplementDetailPage({
    super.key,
    required this.supplement,
  });

  @override
  State<UserSupplementDetailPage> createState() => _UserSupplementDetailPageState();
}

class _UserSupplementDetailPageState extends State<UserSupplementDetailPage> {
  late Supplement _supplement;
  List<Review> _reviews = [];
  Map<String, int> _reviewLikes = {};
  Map<String, bool> _reviewLikedByMe = {};
  ReviewSortOption _reviewSort = ReviewSortOption.mostRecent;
  bool _isLoading = true;
  bool _isInWishlist = false;
  bool _hasRated = false;
  Review? _userReview;
  bool _isWishlistHovered = false;
  bool _isBuyNowHovered = false;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _loadLikes() async {
    final Map<String, int> counts = {};
    final Map<String, bool> liked = {};
    for (final r in _reviews) {
      counts[r.id] = await SupplementDatabaseService.getReviewLikeCount(r.id);
      liked[r.id] = await SupplementDatabaseService.isReviewLiked(r.id);
    }
    setState(() {
      _reviewLikes = counts;
      _reviewLikedByMe = liked;
    });
  }

  void _applyReviewSort() {
    final List<Review> sorted = List.from(_reviews);
    switch (_reviewSort) {
      case ReviewSortOption.mostRecent:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ReviewSortOption.mostLiked:
        sorted.sort((a, b) {
          final la = _reviewLikes[a.id] ?? 0;
          final lb = _reviewLikes[b.id] ?? 0;
          final cmp = lb.compareTo(la);
          if (cmp != 0) return cmp;
          return b.date.compareTo(a.date);
        });
        break;
    }
    setState(() {
      _reviews = sorted;
    });
  }

  @override
  void initState() {
    super.initState();
    _supplement = widget.supplement;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Reload supplement to get latest data
      final updatedSupplement = await SupplementDatabaseService.getSupplement(_supplement.id);
      if (updatedSupplement != null) {
        _supplement = updatedSupplement;
      }

      // Check if user has rated
      _hasRated = await SupplementDatabaseService.hasUserRated(_supplement.id);
      if (_hasRated) {
        _userReview = await SupplementDatabaseService.getUserReview(_supplement.id);
      }

      // Load reviews
      _reviews = await SupplementDatabaseService.getReviewsForSupplement(_supplement.id);
      _reviews.sort((a, b) => b.date.compareTo(a.date));

      // Check wishlist status
      _isInWishlist = await SupplementDatabaseService.isInWishlist(_supplement.id);

      await _loadLikes();
      _applyReviewSort();
    } catch (e) {
      debugPrint('Error loading supplement details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isInWishlist) {
      await SupplementDatabaseService.removeFromWishlist(_supplement.id);
      setState(() => _isInWishlist = false);
    } else {
      await SupplementDatabaseService.addToWishlist(_supplement.id);
      setState(() => _isInWishlist = true);
      // Show notification when adding to wishlist
      if (mounted) {
        _showWishlistNotification();
      }
    }
  }

  void _showWishlistNotification() {
    // Show top notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: CupertinoColors.systemGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Supplement has been successfully added to your wishlist.',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF32383E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 0,
        ),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final isFavorite = await SupplementDatabaseService.isFavorite(_supplement.id);
    if (isFavorite) {
      await SupplementDatabaseService.removeFromFavorites(_supplement.id);
    } else {
      await SupplementDatabaseService.addToFavorites(_supplement.id);
    }
    setState(() {});
  }

  Future<void> _showReviewDialog() async {
    int? selectedRating;
    final commentController = TextEditingController();

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Write a Review'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text('Rating'),
              const SizedBox(height: 8),
              RatingStars(
                rating: (selectedRating ?? 0).toDouble(),
                size: 30,
                interactive: true,
                selectedRating: selectedRating,
                onRatingChanged: (rating) {
                  setState(() => selectedRating = rating);
                },
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: commentController,
                placeholder: 'Write your review...',
                maxLines: 4,
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              if (selectedRating != null && selectedRating! >= 1) {
                _submitReview(selectedRating!, commentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview(int rating, String comment) async {
    try {
      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        supplementId: _supplement.id,
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}', // TODO: Get actual user ID
        rating: rating,
        comment: comment,
        userName: 'You', // TODO: Get actual user name
      );

      await SupplementDatabaseService.saveReview(review);

      // Update supplement rating
      final allReviews = await SupplementDatabaseService.getReviewsForSupplement(_supplement.id);
      final averageRating = allReviews.isEmpty
          ? 0.0
          : allReviews.map((r) => r.rating).reduce((a, b) => a + b) /
              allReviews.length;

      final updatedSupplement = _supplement.copyWith(
        rating: averageRating,
        reviewCount: allReviews.length,
        updatedAt: DateTime.now(),
      );

      await SupplementDatabaseService.saveSupplement(updatedSupplement);
      _supplement = updatedSupplement;

      _loadData();
    } catch (e) {
      debugPrint('Error submitting review: $e');
    }
  }

  Future<void> _confirmDeleteReview(Review review) async {
    final reasons = <String>[
      'Offensive Language',
      'Spam or Fake Review',
      'Irrelevant Content',
      'Harassment or Abuse',
    ];

    String? selectedReason;
    final feedbackController = TextEditingController();
    String? validationError;

    bool hasLetters(String s) => RegExp(r'[A-Za-z]').hasMatch(s);

    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> onConfirm() async {
              final feedback = feedbackController.text.trim();

              if (selectedReason == null || selectedReason!.isEmpty) {
                setState(() => validationError = 'Please select a reason.');
                return;
              }
              if (feedback.length < 10) {
                setState(() => validationError = 'Feedback must be at least 10 characters.');
                return;
              }
              if (RegExp(r'^\\d+$').hasMatch(feedback)) {
                setState(() => validationError = 'Feedback cannot contain only numbers.');
                return;
              }
              if (!hasLetters(feedback)) {
                setState(() => validationError = 'Feedback should include letters (normal text).');
                return;
              }

              // Close the dialog before running async work to avoid dependency issues
              Navigator.of(context, rootNavigator: true).pop();

              try {
                await SupplementDatabaseService.deleteReview(review.id);

                await SupplementDatabaseService.logReviewDeletion(
                  reviewId: review.id,
                  supplementId: _supplement.id,
                  adminUserId: 'admin_default', // TODO: Replace with actual admin ID
                  reason: selectedReason!,
                  feedback: feedback,
                );

                if (mounted) {
                  await _loadData();
                }

                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: const Text('Review deleted successfully'),
                      backgroundColor: const Color(0xFF32383E),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete review: $e'),
                      backgroundColor: const Color(0xFF32383E),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            }

            return CupertinoAlertDialog(
              title: const Text('Delete Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text('Select a reason:'),
                  const SizedBox(height: 8),
                  ...reasons.map((reason) {
                    final selected = selectedReason == reason;
                    return GestureDetector(
                      onTap: () => setState(() => selectedReason = reason),
                      child: Row(
                        children: [
                          Icon(
                            selected ? CupertinoIcons.smallcircle_fill_circle : CupertinoIcons.circle,
                            size: 18,
                            color: selected ? const Color(0xFFC7F000) : CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reason,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                decoration: TextDecoration.none,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: feedbackController,
                    placeholder: 'Optional feedback to the user (min 10 chars)...',
                    maxLines: 4,
                    padding: const EdgeInsets.all(8),
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      validationError!,
                      style: const TextStyle(
                        color: CupertinoColors.systemRed,
                        decoration: TextDecoration.none,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  onPressed: onConfirm,
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleLikeReview(Review review) async {
    try {
      final liked = _reviewLikedByMe[review.id] ?? false;
      if (liked) {
        await SupplementDatabaseService.unlikeReview(review.id);
      } else {
        await SupplementDatabaseService.likeReview(review.id);
      }
      final newCount = await SupplementDatabaseService.getReviewLikeCount(review.id);
      final newLiked = await SupplementDatabaseService.isReviewLiked(review.id);
      setState(() {
        _reviewLikes[review.id] = newCount;
        _reviewLikedByMe[review.id] = newLiked;
      });
      _applyReviewSort();
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _handleBuyNow() async {
    if (!mounted) return;
    
    // Navigate to payment screen
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PaymentScreen(supplement: _supplement),
      ),
    );
    
    // Reload data after returning from payment screen (in case purchase was made)
    _loadData();
  }

  Widget _buildSupplementImage(String imageUrl, double height) {
    if (imageUrl.isEmpty) {
      return _buildFallbackImage(height);
    }

    // Check if it's a file path (local) or URL (network)
    final isFile = imageUrl.startsWith('/') || 
                   imageUrl.contains('\\') || 
                   (!imageUrl.startsWith('http') && imageUrl.isNotEmpty);

    if (isFile) {
      // Local file path
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage(height);
          },
        );
      } else {
        return _buildFallbackImage(height);
      }
    } else {
      // Network URL
      return Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage(height);
        },
      );
    }
  }

  Widget _buildFallbackImage(double height) {
    return Container(
      height: height,
      color: Colors.grey[800],
      child: const Icon(
        CupertinoIcons.photo,
        size: 80,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: CupertinoNavigationBar(
        heroTag: 'nav-supplement-detail',
        transitionBetweenRoutes: false,
        middle: const Text(
          'Supplement Details',
          style: TextStyle(
            color: CupertinoColors.white,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: const Color(0xFF32383E),
        trailing: FutureBuilder<bool>(
          future: SupplementDatabaseService.isInWishlist(_supplement.id),
          builder: (context, snapshot) {
            final isFavorite = snapshot.data ?? false;
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleWishlist,
              child: Icon(
                isFavorite
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: isFavorite
                    ? CupertinoColors.systemRed
                    : CupertinoColors.white,
              ),
            );
          },
        ),
      ),
      child: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    _buildSupplementImage(_supplement.imageUrl, 300),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and Category
                          Text(
                            _supplement.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Brand, Type, and Price on one line
                          Row(
                            children: [
                              // Brand
                              Text(
                                _supplement.brand,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Separator
                              Text(
                                '|',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Type (no label, just value)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC7F000),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _supplement.type.displayName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF17191C),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Separator
                              Text(
                                '|',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Price
                              Text(
                                '${_supplement.price.toInt()}DT',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC7F000),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Description label and Rating on same line
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Description label
                              const Text(
                                'Description:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              // Rating
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InteractiveRatingStars(
                                    currentRating: _supplement.rating,
                                    readOnly: _hasRated,
                                    size: 20,
                                    spacing: 4,
                                    onRatingChanged: _hasRated ? null : (rating) async {
                                      // Save rating
                                      try {
                                        final review = Review(
                                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                                          supplementId: _supplement.id,
                                          userId: 'user_default', // TODO: Replace with actual user ID from auth
                                          rating: rating,
                                          comment: '', // Empty comment for rating-only
                                        );
                                        
                                        await SupplementDatabaseService.saveReview(review);
                                        
                                        // Update supplement rating
                                        final allReviews = await SupplementDatabaseService.getReviewsForSupplement(_supplement.id);
                                        final averageRating = allReviews.isEmpty
                                            ? 0.0
                                            : allReviews.map((r) => r.rating).reduce((a, b) => a + b) / allReviews.length;
                                        
                                        final updatedSupplement = _supplement.copyWith(
                                          rating: averageRating,
                                          reviewCount: allReviews.length,
                                          updatedAt: DateTime.now(),
                                        );
                                        
                                        await SupplementDatabaseService.saveSupplement(updatedSupplement);
                                        
                                        setState(() {
                                          _supplement = updatedSupplement;
                                          _hasRated = true;
                                          _userReview = review;
                                        });
                                        
                                        // Reload reviews
                                        _loadData();
                                      } catch (e) {
                                        debugPrint('Error saving rating: $e');
                                        if (mounted) {
                                          showCupertinoDialog(
                                            context: context,
                                            builder: (context) => CupertinoAlertDialog(
                                              title: const Text('Error'),
                                              content: Text('Failed to save rating: $e'),
                                              actions: [
                                                CupertinoDialogAction(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${_supplement.rating.toStringAsFixed(1)})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: CupertinoColors.white,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Description text (under the label and rating line)
                          Text(
                            _supplement.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.white,
                              height: 1.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Wish List button with hover effect
                              MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _isWishlistHovered = true;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    _isWishlistHovered = false;
                                  });
                                },
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  color: const Color(0xFF32383E),
                                  onPressed: _toggleWishlist,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          (_isInWishlist || _isWishlistHovered)
                                              ? CupertinoIcons.heart_fill
                                              : CupertinoIcons.heart,
                                          key: ValueKey(_isInWishlist || _isWishlistHovered),
                                          color: (_isInWishlist || _isWishlistHovered)
                                              ? CupertinoColors.systemRed
                                              : CupertinoColors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Wish List',
                                        style: TextStyle(
                                          color: CupertinoColors.white,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Buy Now button - GREEN theme color
                              MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _isBuyNowHovered = true;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    _isBuyNowHovered = false;
                                  });
                                },
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  color: _isBuyNowHovered 
                                      ? const Color(0xFFD4F500) // Lighter green on hover
                                      : const Color(0xFFC7F000), // Pistachio green theme color
                                  disabledColor: Colors.grey,
                                  onPressed: _supplement.isInStock ? _handleBuyNow : null,
                                  child: const Text(
                                    'Buy Now',
                                    style: TextStyle(
                                      color: Color(0xFF17191C), // Dark text on light green
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Reviews section (title + inline sort icon + write button)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Reviews',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.white,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    onPressed: () async {
                                      await showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) => CupertinoActionSheet(
                                          title: const Text('Sort Reviews'),
                                          actions: [
                                            CupertinoActionSheetAction(
                                              onPressed: () {
                                                setState(() => _reviewSort = ReviewSortOption.mostRecent);
                                                _applyReviewSort();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Most Recent'),
                                            ),
                                            CupertinoActionSheetAction(
                                              onPressed: () {
                                                setState(() => _reviewSort = ReviewSortOption.mostLiked);
                                                _applyReviewSort();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Most Liked'),
                                            ),
                                          ],
                                          cancelButton: CupertinoActionSheetAction(
                                            isDestructiveAction: true,
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      CupertinoIcons.sort_down,
                                      color: CupertinoColors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _showReviewDialog,
                                child: const Text(
                                  'Write Review',
                                  style: TextStyle(
                                    color: Color(0xFFC7F000),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Reviews list
                          if (_reviews.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  const Icon(
                                    CupertinoIcons.chat_bubble,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No reviews yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[400],
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Be the first to review!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._reviews.map(
                              (review) => ReviewWidget(
                                review: review,
                                dateText: _formatDate(review.date),
                                likeCount: _reviewLikes[review.id] ?? 0,
                                isLiked: _reviewLikedByMe[review.id] ?? false,
                                showDelete: isAdmin,
                                onDelete: () => _confirmDeleteReview(review),
                                onToggleLike: () => _toggleLikeReview(review),
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
}


