import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/supplement.dart';

class EmailApiService {
  static String get baseUrl {
    final url = dotenv.env['STRIPE_BACKEND_URL'];
    if (url != null && url.isNotEmpty) {
      return url;
    }
    return 'http://192.168.1.18:5000'; // Default
  }

  /// Send order confirmation email after successful payment
  static Future<bool> sendOrderConfirmationEmail({
    required String customerEmail,
    String? customerName,
    required Supplement supplement,
    required int quantity,
    required double totalPrice,
    required DateTime purchaseTime,
  }) async {
    try {
      final url = '$baseUrl/email/send-order-confirmation';
      debugPrint('📧 Sending order confirmation email to: $customerEmail');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerEmail': customerEmail,
          'customerName': customerName ?? 'Customer',
          'supplementName': supplement.name,
          'brand': supplement.brand,
          'type': supplement.type.toString().split('.').last,
          'description': supplement.description,
          'quantity': quantity,
          'price': totalPrice,
          'purchaseTime': purchaseTime.toIso8601String(),
          'imageUrl': supplement.imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Order confirmation email sent successfully to ${data['recipient']}');
          return true;
        } else {
          debugPrint('⚠️ Email sending failed: ${data['error']}');
          return false; // Don't throw - payment succeeded
        }
      } else {
        debugPrint('⚠️ Email endpoint error: ${response.statusCode}');
        return false; // Don't throw - payment succeeded
      }
    } catch (e) {
      debugPrint('⚠️ Error sending email (payment still succeeded): $e');
      return false; // Don't throw - payment succeeded
    }
  }
}

