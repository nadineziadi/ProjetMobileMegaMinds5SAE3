import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite/sqflite.dart' as sqflite_mobile;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:io';
import '../models/supplement.dart';
import '../models/review.dart';
import '../models/purchase_history.dart';

class SupplementDatabaseService {
  static Database? _database;
  static bool _isInitializing = false;
  static const String _databaseName = 'supplements.db';
  static const int _databaseVersion = 2; // Incremented for favorite field migration

  // Table names
  static const String supplementsTable = 'supplements';
  static const String reviewsTable = 'reviews';
  static const String purchaseHistoryTable = 'purchase_history';
  static const String favoritesTable = 'favorites';
  static const String wishlistTable = 'wishlist';

  // Default user ID (in production, get from auth service)
  static String get _currentUserId => 'user_default';

  /// Initialize SQLite database
  static Future<void> init() async {
    if (_database != null) return; // Already initialized
    if (_isInitializing) {
      // Wait for ongoing initialization
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;
    try {
      String databasePath;
      
      if (kIsWeb) {
        throw Exception('SQLite is not supported on web platform');
      } else if (defaultTargetPlatform == TargetPlatform.windows ||
                 defaultTargetPlatform == TargetPlatform.linux ||
                 defaultTargetPlatform == TargetPlatform.macOS) {
        // Desktop platforms: use application documents directory
        // The databaseFactory is already set in main.dart, so openDatabase will use it
        final Directory documentsDir = await getApplicationDocumentsDirectory();
        databasePath = join(documentsDir.path, _databaseName);
        debugPrint('Desktop platform detected: ${defaultTargetPlatform.name}');
      } else {
        // Mobile platforms (Android/iOS): use standard database path
        final dbPathBase = await sqflite_mobile.getDatabasesPath();
        databasePath = join(dbPathBase, _databaseName);
      }
      
      _database = await sqflite_mobile.openDatabase(
        databasePath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
      debugPrint('✓ Supplement database initialized successfully at: $databasePath');
    } catch (e, stackTrace) {
      debugPrint('✗ Supplement database initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to initialize supplement database: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Supplements table
    await db.execute('''
      CREATE TABLE $supplementsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        type INTEGER NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        rating REAL NOT NULL DEFAULT 0.0,
        reviewCount INTEGER NOT NULL DEFAULT 0,
        favorite INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Reviews table
    await db.execute('''
      CREATE TABLE $reviewsTable (
        id TEXT PRIMARY KEY,
        supplementId TEXT NOT NULL,
        userId TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT NOT NULL,
        date TEXT NOT NULL,
        userName TEXT,
        FOREIGN KEY (supplementId) REFERENCES $supplementsTable (id)
      )
    ''');

    // Purchase history table
    await db.execute('''
      CREATE TABLE $purchaseHistoryTable (
        id TEXT PRIMARY KEY,
        supplementId TEXT NOT NULL,
        userId TEXT NOT NULL,
        purchaseDate TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        supplementName TEXT,
        supplementImageUrl TEXT,
        paymentIntentId TEXT,
        FOREIGN KEY (supplementId) REFERENCES $supplementsTable (id)
      )
    ''');

    // Favorites table (composite primary key)
    await db.execute('''
      CREATE TABLE $favoritesTable (
        supplementId TEXT NOT NULL,
        userId TEXT NOT NULL,
        PRIMARY KEY (supplementId, userId),
        FOREIGN KEY (supplementId) REFERENCES $supplementsTable (id)
      )
    ''');

    // Wishlist table (composite primary key)
    await db.execute('''
      CREATE TABLE $wishlistTable (
        supplementId TEXT NOT NULL,
        userId TEXT NOT NULL,
        PRIMARY KEY (supplementId, userId),
        FOREIGN KEY (supplementId) REFERENCES $supplementsTable (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_reviews_supplement ON $reviewsTable(supplementId)');
    await db.execute('CREATE INDEX idx_purchase_user ON $purchaseHistoryTable(userId)');
    await db.execute('CREATE INDEX idx_favorites_user ON $favoritesTable(userId)');
    await db.execute('CREATE INDEX idx_wishlist_user ON $wishlistTable(userId)');
  }

  /// Upgrade database schema
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add favorite column to supplements table
      // Note: SQLite doesn't support NOT NULL in ALTER TABLE, so we use DEFAULT 0
      try {
        await db.execute('ALTER TABLE $supplementsTable ADD COLUMN favorite INTEGER DEFAULT 0');
        debugPrint('✓ Database migrated: Added favorite column to supplements table');
        
        // Update all existing rows to have favorite = 0 (explicitly set for safety)
        await db.update(
          supplementsTable,
          {'favorite': 0},
          where: 'favorite IS NULL',
        );
        debugPrint('✓ Updated existing supplements to have favorite = 0');
      } catch (e) {
        // Column might already exist, check if it's a different error
        if (e.toString().contains('duplicate column') || 
            e.toString().contains('already exists')) {
          debugPrint('ℹ Migration note: favorite column already exists');
        } else {
          debugPrint('✗ Migration error: $e');
          rethrow; // Re-throw if it's a different error
        }
      }
    }
  }

  /// Get database instance (async to ensure initialization)
  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    
    // If not initialized, try to initialize now
    if (!_isInitializing) {
      await init();
    } else {
      // Wait for ongoing initialization
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    if (_database == null) {
      throw Exception('Supplement database not initialized. Call SupplementDatabaseService.init() first.');
    }
    
    return _database!;
  }

  // ========== Supplement CRUD Operations ==========

  /// Save a supplement (insert or update)
  static Future<void> saveSupplement(Supplement supplement) async {
    final db = await database;
    await db.insert(
      supplementsTable,
      supplement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a supplement by ID
  static Future<Supplement?> getSupplement(String id) async {
    final db = await database;
    final maps = await db.query(
      supplementsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Supplement.fromMap(maps.first);
  }

  /// Get all supplements
  static Future<List<Supplement>> getAllSupplements() async {
    final db = await database;
    final maps = await db.query(supplementsTable);
    return maps.map((map) => Supplement.fromMap(map)).toList();
  }

  /// Delete a supplement
  static Future<void> deleteSupplement(String id) async {
    final db = await database;
    await db.delete(
      supplementsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all supplements
  static Future<void> clearSupplements() async {
    final db = await database;
    await db.delete(supplementsTable);
  }

  // ========== Review CRUD Operations ==========

  /// Save a review
  static Future<void> saveReview(Review review) async {
    final db = await database;
    await db.insert(
      reviewsTable,
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a review by ID
  static Future<Review?> getReview(String id) async {
    final db = await database;
    final maps = await db.query(
      reviewsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Review.fromMap(maps.first);
  }

  /// Get all reviews for a supplement
  static Future<List<Review>> getReviewsForSupplement(String supplementId) async {
    final db = await database;
    final maps = await db.query(
      reviewsTable,
      where: 'supplementId = ?',
      whereArgs: [supplementId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Review.fromMap(map)).toList();
  }

  /// Get all reviews
  static Future<List<Review>> getAllReviews() async {
    final db = await database;
    final maps = await db.query(reviewsTable);
    return maps.map((map) => Review.fromMap(map)).toList();
  }

  /// Delete a review
  static Future<void> deleteReview(String id) async {
    final db = await database;
    await db.delete(
      reviewsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Log review deletion (reason and optional feedback)
  static Future<void> logReviewDeletion({
    required String reviewId,
    required String supplementId,
    required String adminUserId,
    required String reason,
    String? feedback,
  }) async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS review_deletions (
        id TEXT PRIMARY KEY,
        reviewId TEXT NOT NULL,
        supplementId TEXT NOT NULL,
        adminUserId TEXT NOT NULL,
        reason TEXT NOT NULL,
        feedback TEXT,
        date TEXT NOT NULL
      )
    ''');

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert(
      'review_deletions',
      {
        'id': id,
        'reviewId': reviewId,
        'supplementId': supplementId,
        'adminUserId': adminUserId,
        'reason': reason,
        'feedback': feedback,
        'date': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Check if user has already rated a supplement
  static Future<bool> hasUserRated(String supplementId, {String? userId}) async {
    final db = await database;
    final uid = userId ?? _currentUserId;
    final maps = await db.query(
      reviewsTable,
      where: 'supplementId = ? AND userId = ?',
      whereArgs: [supplementId, uid],
    );
    return maps.isNotEmpty;
  }

  // ========== Review Likes Operations ==========

  static Future<void> _ensureReviewLikesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS review_likes (
        reviewId TEXT NOT NULL,
        userId TEXT NOT NULL,
        PRIMARY KEY (reviewId, userId)
      )
    ''');
  }

  /// Like a review
  static Future<void> likeReview(String reviewId, {String? userId}) async {
    final db = await database;
    await _ensureReviewLikesTable(db);
    final uid = userId ?? _currentUserId;
    await db.insert(
      'review_likes',
      {
        'reviewId': reviewId,
        'userId': uid,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Unlike a review
  static Future<void> unlikeReview(String reviewId, {String? userId}) async {
    final db = await database;
    await _ensureReviewLikesTable(db);
    final uid = userId ?? _currentUserId;
    await db.delete(
      'review_likes',
      where: 'reviewId = ? AND userId = ?',
      whereArgs: [reviewId, uid],
    );
  }

  /// Check if current user liked a review
  static Future<bool> isReviewLiked(String reviewId, {String? userId}) async {
    final db = await database;
    await _ensureReviewLikesTable(db);
    final uid = userId ?? _currentUserId;
    final maps = await db.query(
      'review_likes',
      where: 'reviewId = ? AND userId = ?',
      whereArgs: [reviewId, uid],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// Get like count for a review
  static Future<int> getReviewLikeCount(String reviewId) async {
    final db = await database;
    await _ensureReviewLikesTable(db);
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM review_likes WHERE reviewId = ?',
      [reviewId],
    );
    final count = result.first['cnt'] as int?;
    return count ?? 0;
  }

  /// Get user's review for a supplement
  static Future<Review?> getUserReview(String supplementId, {String? userId}) async {
    final db = await database;
    final uid = userId ?? _currentUserId;
    final maps = await db.query(
      reviewsTable,
      where: 'supplementId = ? AND userId = ?',
      whereArgs: [supplementId, uid],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Review.fromMap(maps.first);
  }

  // ========== Favorites Operations ==========

  /// Add supplement to favorites
  static Future<void> addToFavorites(String supplementId, {String? userId}) async {
    final db = await database;
    final uid = userId ?? _currentUserId;
    await db.insert(
      favoritesTable,
      {
        'supplementId': supplementId,
        'userId': uid,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove supplement from favorites
  static Future<void> removeFromFavorites(String supplementId, {String? userId}) async {
    final db = await database;
    final uid = userId ?? _currentUserId;
    await db.delete(
      favoritesTable,
      where: 'supplementId = ? AND userId = ?',
      whereArgs: [supplementId, uid],
    );
  }

  /// Check if supplement is in favorites
  static Future<bool> isFavorite(String supplementId, {String? userId}) async {
    final db = await database;
    final uid = userId ?? _currentUserId;
    final maps = await db.query(
      favoritesTable,
      where: 'supplementId = ? AND userId = ?',
      whereArgs: [supplementId, uid],
    );
    return maps.isNotEmpty;
  }

  /// Get all favorite supplement IDs
  static Future<List<String>> getFavoriteIds({String? userId}) async {
    final db = await database;
    final uid = userId ?? _currentUserId;
    final maps = await db.query(
      favoritesTable,
      where: 'userId = ?',
      whereArgs: [uid],
    );
    return maps.map((map) => map['supplementId'] as String).toList();
  }

  /// Get all favorite supplements
  static Future<List<Supplement>> getFavorites({String? userId}) async {
    final db = await database;
    final favoriteIds = await getFavoriteIds(userId: userId);
    if (favoriteIds.isEmpty) return [];

    final placeholders = favoriteIds.map((_) => '?').join(',');
    final maps = await db.query(
      supplementsTable,
      where: 'id IN ($placeholders)',
      whereArgs: favoriteIds,
    );
    return maps.map((map) => Supplement.fromMap(map)).toList();
  }

  // ========== Wishlist Operations ==========

  /// Add supplement to wishlist (set favorite = true)
  static Future<void> addToWishlist(String supplementId, {String? userId}) async {
    final db = await database;
    final supplement = await getSupplement(supplementId);
    if (supplement != null) {
      final updatedSupplement = supplement.copyWith(
        favorite: true,
        updatedAt: DateTime.now(),
      );
      await saveSupplement(updatedSupplement);
    }
  }

  /// Remove supplement from wishlist (set favorite = false)
  static Future<void> removeFromWishlist(String supplementId, {String? userId}) async {
    final db = await database;
    final supplement = await getSupplement(supplementId);
    if (supplement != null) {
      final updatedSupplement = supplement.copyWith(
        favorite: false,
        updatedAt: DateTime.now(),
      );
      await saveSupplement(updatedSupplement);
    }
  }

  /// Check if supplement is in wishlist (check favorite field)
  static Future<bool> isInWishlist(String supplementId, {String? userId}) async {
    final db = await database;
    final supplement = await getSupplement(supplementId);
    return supplement?.favorite ?? false;
  }

  /// Get all wishlist supplement IDs (supplements where favorite = true)
  static Future<List<String>> getWishlistIds({String? userId}) async {
    final db = await database;
    final maps = await db.query(
      supplementsTable,
      where: 'favorite = ?',
      whereArgs: [1],
      columns: ['id'],
    );
    return maps.map((map) => map['id'] as String).toList();
  }

  /// Get all wishlist supplements (where favorite = true)
  static Future<List<Supplement>> getWishlist({String? userId}) async {
    final db = await database;
    final maps = await db.query(
      supplementsTable,
      where: 'favorite = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Supplement.fromMap(map)).toList();
  }

  // ========== Purchase History Operations ==========

  /// Save purchase history
  static Future<void> savePurchaseHistory(PurchaseHistory purchase) async {
    final db = await database;
    await db.insert(
      purchaseHistoryTable,
      purchase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get purchase history by ID
  static Future<PurchaseHistory?> getPurchaseHistory(String id) async {
    final db = await database;
    final maps = await db.query(
      purchaseHistoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return PurchaseHistory.fromMap(maps.first);
  }

  /// Get all purchase history for a user
  static Future<List<PurchaseHistory>> getPurchaseHistoryForUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      purchaseHistoryTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'purchaseDate DESC',
    );
    return maps.map((map) => PurchaseHistory.fromMap(map)).toList();
  }

  /// Get all purchase history
  static Future<List<PurchaseHistory>> getAllPurchaseHistory() async {
    final db = await database;
    final maps = await db.query(
      purchaseHistoryTable,
      orderBy: 'purchaseDate DESC',
    );
    return maps.map((map) => PurchaseHistory.fromMap(map)).toList();
  }

  /// Clear all data (useful for testing or reset)
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete(supplementsTable);
    await db.delete(reviewsTable);
    await db.delete(purchaseHistoryTable);
    await db.delete(favoritesTable);
    await db.delete(wishlistTable);
  }

  /// Close database connection
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
