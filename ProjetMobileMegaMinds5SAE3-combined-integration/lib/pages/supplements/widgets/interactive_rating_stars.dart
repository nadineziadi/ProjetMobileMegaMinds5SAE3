import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InteractiveRatingStars extends StatefulWidget {
  final double currentRating;
  final Function(int)? onRatingChanged;
  final bool readOnly;
  final double size;
  final double spacing;

  const InteractiveRatingStars({
    super.key,
    required this.currentRating,
    this.onRatingChanged,
    this.readOnly = false,
    this.size = 20,
    this.spacing = 4,
  });

  @override
  State<InteractiveRatingStars> createState() => _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  int? _hoveredRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starRating = index + 1;
        final displayRating = _hoveredRating ?? widget.currentRating.round();
        final isFilled = starRating <= displayRating;

        return GestureDetector(
          onTap: widget.readOnly
              ? null
              : () {
                  widget.onRatingChanged?.call(starRating);
                },
          child: MouseRegion(
            onEnter: widget.readOnly
                ? null
                : (_) {
                    setState(() {
                      _hoveredRating = starRating;
                    });
                  },
            onExit: widget.readOnly
                ? null
                : (_) {
                    setState(() {
                      _hoveredRating = null;
                    });
                  },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Icon(
                isFilled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                size: widget.size,
                color: isFilled
                    ? const Color(0xFFC7F000) // Yellow
                    : Colors.grey[600], // Grey
              ),
            ),
          ),
        );
      }),
    );
  }
}

