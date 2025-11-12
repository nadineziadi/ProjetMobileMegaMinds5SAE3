import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/review.dart';
import 'rating_stars.dart';

class ReviewWidget extends StatelessWidget {
  final Review review;
  final String dateText;
  final int likeCount;
  final bool isLiked;
  final bool showDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleLike;

  const ReviewWidget({
    super.key,
    required this.review,
    required this.dateText,
    required this.likeCount,
    required this.isLiked,
    this.showDelete = false,
    this.onDelete,
    this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF32383E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Date (left) → Heart+count → Trash (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date text (left)
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 12),
              // Heart + like count
              _LikeButton(
                isLiked: isLiked,
                likeCount: likeCount,
                onPressed: onToggleLike,
              ),
              const Spacer(),
              // Delete icon (admin, right)
              if (showDelete)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minSize: 0,
                  color: const Color(0xFF522E2E),
                  onPressed: onDelete,
                  child: const Icon(
                    CupertinoIcons.trash,
                    size: 16,
                    color: CupertinoColors.systemRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // User header: avatar, name, stars
          Row(
            children: [
              // User avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFC7F000).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (review.userName ?? review.userId.substring(0, 1))
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFC7F000),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'User ${review.userId.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingStars(
                      rating: review.rating.toDouble(),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.white,
                height: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback? onPressed;

  const _LikeButton({
    required this.isLiked,
    required this.likeCount,
    this.onPressed,
  });

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.isLiked || _hovering;
    final icon = filled ? CupertinoIcons.heart_fill : CupertinoIcons.heart;
    final color = filled ? const Color(0xFFC7F000) : CupertinoColors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              widget.likeCount.toString(),
              style: const TextStyle(
                color: CupertinoColors.white,
                decoration: TextDecoration.none,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

