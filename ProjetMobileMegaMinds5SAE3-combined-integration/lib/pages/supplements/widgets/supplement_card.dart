import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/supplement.dart';
import '../services/supplement_database_service.dart';

class SupplementCard extends StatelessWidget {
  final Supplement supplement;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onModify;
  final VoidCallback? onDelete;

  const SupplementCard({
    super.key,
    required this.supplement,
    required this.onTap,
    this.onFavoriteToggle,
    this.onModify,
    this.onDelete,
  });

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
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SupplementDatabaseService.isInWishlist(supplement.id),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF32383E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent overflow
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  _buildSupplementImage(supplement.imageUrl, 150),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7F000).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        supplement.type.displayName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17191C),
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: isFavorite
                              ? CupertinoColors.systemRed
                              : CupertinoColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title - white color
                    Text(
                      supplement.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price and Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${supplement.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC7F000),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                size: 16,
                                color: Color(0xFFC7F000),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                supplement.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${supplement.reviewCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Only show admin buttons if callbacks are provided
                    if (onModify != null || onDelete != null)
                      Row(
                        children: [
                          if (onModify != null)
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                minSize: 0,
                                color: const Color(0xFFC7F000),
                                onPressed: onModify,
                                child: const Icon(
                                  CupertinoIcons.pencil,
                                  color: Color(0xFF17191C),
                                  size: 20,
                                ),
                              ),
                            ),
                          if (onModify != null && onDelete != null)
                            const SizedBox(width: 8),
                          if (onDelete != null)
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                minSize: 0,
                                color: const Color(0xFF522E2E),
                                onPressed: onDelete,
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  color: CupertinoColors.systemRed,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}

