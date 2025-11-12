import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'supplement_database_service.dart';

class SupplementNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Supplement notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate page based on payload
  }

  /// Show a simple notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'supplements_channel',
      'Supplements Notifications',
      channelDescription: 'Notifications for supplements, promotions, and alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule a notification for a specific time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'supplements_channel',
      'Supplements Notifications',
      channelDescription: 'Notifications for supplements, promotions, and alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Convert DateTime to TZDateTime (simplified - in production use timezone package)
  static dynamic _convertToTZDateTime(DateTime dateTime) {
    // For simplicity, using DateTime directly
    // In production, use timezone package: TZDateTime.from(dateTime, getLocation('UTC'))
    return dateTime;
  }

  /// Notify about promotion on favorite supplements
  static Future<void> notifyPromotionOnFavorites() async {
    final favorites = await SupplementDatabaseService.getFavorites();
    
    if (favorites.isEmpty) return;

    // Pick a random favorite or the first one
    final supplement = favorites.first;

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Special Promotion!',
      body: '${supplement.name} is now on sale! Check it out!',
      payload: supplement.id,
    );
  }

  /// Notify about low stock on favorite supplements
  static Future<void> checkLowStockAlerts() async {
    final favorites = await SupplementDatabaseService.getFavorites();
    const lowStockThreshold = 5;

    for (final supplement in favorites) {
      if (supplement.stock > 0 && supplement.stock <= lowStockThreshold) {
        await showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000 + supplement.id.hashCode,
          title: 'Low Stock Alert',
          body: '${supplement.name} is running low (${supplement.stock} left)!',
          payload: supplement.id,
        );
      }
    }
  }

  /// Notify about new supplements in favorite categories
  static Future<void> notifyNewSupplementsInFavoriteCategories() async {
    final favorites = await SupplementDatabaseService.getFavorites();
    if (favorites.isEmpty) return;

    // Get favorite categories
    final favoriteCategories = favorites
        .map((s) => s.type)
        .toSet()
        .toList();

    // Get all supplements
    final allSupplements = await SupplementDatabaseService.getAllSupplements();

    // Find new supplements in favorite categories (created in last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    for (final category in favoriteCategories) {
      final newSupplements = allSupplements.where((s) {
        return s.type == category &&
            s.createdAt.isAfter(sevenDaysAgo);
      }).toList();

      if (newSupplements.isNotEmpty) {
        final supplement = newSupplements.first;
        await showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000 + category.hashCode,
          title: 'New in ${category.displayName}',
          body: 'Check out ${supplement.name}!',
          payload: supplement.id,
        );
        break; // Only notify about one new supplement
      }
    }
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
