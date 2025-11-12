// TensorFlow Lite is optional - using fallback algorithm
// Uncomment if you add tensorflow_lite_flutter package:
// import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/supplement.dart';
import '../models/category.dart';
import 'supplement_database_service.dart';

class RecommendationService {
  // static Interpreter? _interpreter; // Uncomment if using TensorFlow Lite
  static bool _initialized = false;
  // Cache to avoid recomputing recommendations
  static List<Supplement>? _cachedRecommendations;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// Initialize TensorFlow Lite model (optional - uses fallback if not available)
  static Future<void> init() async {
    if (_initialized) return;

    // TensorFlow Lite is optional - using fallback algorithm
    // If you want to use TensorFlow Lite:
    // 1. Add tensorflow_lite_flutter to pubspec.yaml
    // 2. Uncomment the TensorFlow Lite code below
    // 3. Add your model file to assets/
    
    debugPrint('RecommendationService initialized (using fallback algorithm)');
    _initialized = true;
  }

  /// Generate recommendations based on user data
  /// Uses caching and isolates to prevent UI blocking
  static Future<List<Supplement>> getRecommendations({
    int limit = 20,
  }) async {
    await init();

    // Check cache first
    if (_cachedRecommendations != null && 
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheValidDuration) {
      debugPrint('✅ Returning cached recommendations');
      return _cachedRecommendations!.take(limit).toList();
    }

    debugPrint('🔄 Computing recommendations...');
    
    // Load data efficiently - batch operations
    final dataFuture = Future.wait([
      SupplementDatabaseService.getAllPurchaseHistory(),
      SupplementDatabaseService.getFavorites(),
      SupplementDatabaseService.getWishlist(),
      SupplementDatabaseService.getAllReviews(),
      SupplementDatabaseService.getAllSupplements(),
    ]);

    final results = await dataFuture;
    final purchaseHistory = results[0] as List<dynamic>;
    final favorites = results[1] as List<Supplement>;
    final wishlist = results[2] as List<Supplement>;
    final reviews = results[3] as List<dynamic>;
    final allSupplements = results[4] as List<Supplement>;

    if (allSupplements.isEmpty) {
      return [];
    }

    // Move heavy computation to isolate to avoid blocking UI
    try {
      final recommendations = await compute(
        _computeRecommendationsIsolate,
        _RecommendationData(
          purchaseHistory: purchaseHistory,
          favorites: favorites,
          wishlist: wishlist,
          reviews: reviews,
          allSupplements: allSupplements,
          limit: limit,
        ),
      );

      // Cache results
      _cachedRecommendations = recommendations;
      _cacheTimestamp = DateTime.now();
      
      debugPrint('✅ Recommendations computed: ${recommendations.length} items');
      return recommendations;
    } catch (e) {
      debugPrint('❌ Error computing recommendations in isolate: $e');
      // Fallback to main thread if isolate fails
      return _getRecommendationsFallback(
        purchaseHistory: purchaseHistory,
        favorites: favorites,
        wishlist: wishlist,
        reviews: reviews,
        allSupplements: allSupplements,
        limit: limit,
      );
    }
  }

  /// Get recommendations using TensorFlow Lite model (optional - commented out)
  // Uncomment this method if you add TensorFlow Lite support:
  /*
  static List<Supplement> _getRecommendationsWithModel({
    required List<dynamic> purchaseHistory,
    required List<Supplement> favorites,
    required List<Supplement> wishlist,
    required List<dynamic> reviews,
    required List<Supplement> allSupplements,
    required int limit,
  }) {
    // Extract features from user data
    final features = _extractFeatures(
      purchaseHistory: purchaseHistory,
      favorites: favorites,
      wishlist: wishlist,
      reviews: reviews,
      allSupplements: allSupplements,
    );

    // Prepare input tensor
    final input = [features];
    final output = List.filled(allSupplements.length, 0.0).reshape([1, allSupplements.length]);

    try {
      // Run inference
      _interpreter!.run(input, output);

      // Get top recommendations
      final scores = output[0] as List<double>;
      final indexedScores = scores.asMap().entries.toList();
      indexedScores.sort((a, b) => b.value.compareTo(a.value));

      final recommendations = indexedScores
          .take(limit)
          .map((entry) => allSupplements[entry.key])
          .where((supplement) => supplement.isInStock)
          .toList();

      return recommendations;
    } catch (e) {
      debugPrint('Error running TensorFlow inference: $e');
      return _getRecommendationsFallback(
        purchaseHistory: purchaseHistory,
        favorites: favorites,
        wishlist: wishlist,
        reviews: reviews,
        allSupplements: allSupplements,
        limit: limit,
      );
    }
  }
  */

  /// Extract features from user data for model input
  /// OPTIMIZED: No longer does N+1 queries - uses already loaded supplements map
  static Future<List<double>> _extractFeatures({
    required List<dynamic> purchaseHistory,
    required List<Supplement> favorites,
    required List<Supplement> wishlist,
    required List<dynamic> reviews,
    required List<Supplement> allSupplements,
  }) async {
    // Create feature vector
    // Features: category preferences, average rating given, price range, etc.
    final features = <double>[];

    // OPTIMIZATION: Create a map of supplements by ID to avoid N+1 queries
    final supplementsMap = <String, Supplement>{};
    for (final supplement in allSupplements) {
      supplementsMap[supplement.id] = supplement;
    }

    // Category preferences (one-hot encoding for 5 categories)
    final categoryCounts = <SupplementCategory, int>{};
    for (final category in SupplementCategory.values) {
      categoryCounts[category] = 0;
    }

    // Count purchases by category - OPTIMIZED: use map instead of database queries
    for (final purchase in purchaseHistory) {
      final supplement = supplementsMap[purchase.supplementId];
      if (supplement != null) {
        categoryCounts[supplement.type] =
            (categoryCounts[supplement.type] ?? 0) + 1;
      }
    }

    // Normalize category preferences
    final totalPurchases = categoryCounts.values.fold(0, (a, b) => a + b);
    for (final category in SupplementCategory.values) {
      features.add(totalPurchases > 0
          ? (categoryCounts[category] ?? 0) / totalPurchases
          : 0.2); // Equal preference if no purchases
    }

    // Average rating given by user
    final userRatings = reviews.map((r) => r.rating as int).toList();
    final avgRating = userRatings.isEmpty
        ? 3.0
        : userRatings.reduce((a, b) => a + b) / userRatings.length;
    features.add(avgRating / 5.0); // Normalize to 0-1

    // Preferred price range (from purchase history)
    final purchasePrices = purchaseHistory
        .map((p) => (p.price as num).toDouble())
        .where((p) => p > 0)
        .toList();
    final avgPrice = purchasePrices.isEmpty
        ? 50.0
        : purchasePrices.reduce((a, b) => a + b) / purchasePrices.length;
    features.add((avgPrice / 200.0).clamp(0.0, 1.0)); // Normalize assuming max price ~200

    // Fill remaining features with zeros (if model expects more features)
    while (features.length < 10) {
      features.add(0.0);
    }

    return features.take(10).toList();
  }

  /// Fallback recommendation algorithm (rule-based)
  /// Made public for isolate access
  static List<Supplement> _getRecommendationsFallback({
    required List<dynamic> purchaseHistory,
    required List<Supplement> favorites,
    required List<Supplement> wishlist,
    required List<dynamic> reviews,
    required List<Supplement> allSupplements,
    required int limit,
  }) {
    // Score supplements based on various factors
    final scores = <Supplement, double>{};

    // Get favorite categories
    final favoriteCategories = <SupplementCategory>{};
    for (final favorite in favorites) {
      favoriteCategories.add(favorite.type);
    }
    for (final item in wishlist) {
      favoriteCategories.add(item.type);
    }

    // Get purchased supplement IDs
    final purchasedIds = purchaseHistory
        .map((p) => p.supplementId as String)
        .toSet();

    for (final supplement in allSupplements) {
      if (!supplement.isInStock) continue;
      if (purchasedIds.contains(supplement.id)) continue; // Don't recommend already purchased

      double score = 0.0;

      // Category match (high weight)
      if (favoriteCategories.contains(supplement.type)) {
        score += 3.0;
      }

      // Rating (medium weight)
      score += supplement.rating * 0.5;

      // Review count (low weight)
      score += (supplement.reviewCount / 10.0).clamp(0.0, 1.0);

      // Price similarity to purchased items
      if (purchaseHistory.isNotEmpty) {
        final avgPurchasePrice = purchaseHistory
                .map((p) => (p.price as num).toDouble())
                .reduce((a, b) => a + b) /
            purchaseHistory.length;
        final priceDiff = (supplement.price - avgPurchasePrice).abs();
        score += (1.0 - (priceDiff / 100.0).clamp(0.0, 1.0)) * 0.5;
      }

      scores[supplement] = score;
    }

    // Sort by score and return top recommendations
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(limit)
        .map((entry) => entry.key)
        .where((supplement) => supplement.isInStock)
        .toList();
  }

  /// Clear cache and model resources
  static void clearCache() {
    _cachedRecommendations = null;
    _cacheTimestamp = null;
    debugPrint('🗑️ Recommendation cache cleared');
  }

  /// Clear model resources
  static void dispose() {
    // Uncomment if using TensorFlow Lite:
    // _interpreter?.close();
    // _interpreter = null;
    clearCache();
    _initialized = false;
  }
}

/// Data class for isolate communication (must be top-level)
class _RecommendationData {
  final List<dynamic> purchaseHistory;
  final List<Supplement> favorites;
  final List<Supplement> wishlist;
  final List<dynamic> reviews;
  final List<Supplement> allSupplements;
  final int limit;

  _RecommendationData({
    required this.purchaseHistory,
    required this.favorites,
    required this.wishlist,
    required this.reviews,
    required this.allSupplements,
    required this.limit,
  });
}

/// Top-level function for compute isolate (must be outside class)
List<Supplement> _computeRecommendationsIsolate(_RecommendationData data) {
  return RecommendationService._getRecommendationsFallback(
    purchaseHistory: data.purchaseHistory,
    favorites: data.favorites,
    wishlist: data.wishlist,
    reviews: data.reviews,
    allSupplements: data.allSupplements,
    limit: data.limit,
  );
}
