import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final Function(int)? onRatingChanged;
  final int? selectedRating;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
    this.selectedRating,
  });

  @override
  Widget build(BuildContext context) {
    if (interactive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starRating = index + 1;
          final isSelected = selectedRating != null && starRating <= selectedRating!;
          
          return GestureDetector(
            onTap: () => onRatingChanged?.call(starRating),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isSelected
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                size: size,
                color: isSelected
                    ? const Color(0xFFC7F000)
                    : Colors.grey[600],
              ),
            ),
          );
        }),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starRating = index + 1;
          final isFilled = starRating <= rating;
          final isHalfFilled = starRating - 0.5 <= rating && rating < starRating;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled
                  ? CupertinoIcons.star_fill
                  : isHalfFilled
                      ? CupertinoIcons.star_lefthalf_fill
                      : CupertinoIcons.star,
              size: size,
              color: isFilled || isHalfFilled
                  ? const Color(0xFFC7F000)
                  : Colors.grey[600],
            ),
          );
        }),
      );
    }
  }
}

