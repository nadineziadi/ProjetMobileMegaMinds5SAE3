import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeApiService {
  // Get backend URL from environment or use default
  static String get baseUrl {
    final url = dotenv.env['STRIPE_BACKEND_URL'];
    if (url != null && url.isNotEmpty) {
      return url;
    }
    // Default to localhost - update this to match your backend server IP
    return 'http://192.168.1.18:5000';
  }

  /// Fetch products from backend
  /// Note: This is a generic method. For supplements, we use local database.
  /// This can be used if you want to sync products from backend.
  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  /// Create a payment intent with Stripe backend
  /// [amount] should be in cents (e.g., 1500 = $15.00)
  /// [currency] is the currency code (default: 'usd')
  /// [description] is the product description
  /// [quantity] is the quantity being purchased (default: 1)
  static Future<String> createPaymentIntent({
    required int amount,
    String currency = 'usd',
    String description = '',
    int quantity = 1,
  }) async {
    try {
      final url = '$baseUrl/payment/create-payment-intent';
      debugPrint('🔄 Calling backend: $url');
      debugPrint('📦 Request body: amount=$amount, currency=$currency, quantity=$quantity');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'description': description,
          'quantity': quantity,
        }),
      );

      debugPrint('📥 Backend response status: ${response.statusCode}');
      debugPrint('📥 Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final clientSecret = data['clientSecret'] as String?;
        
        if (clientSecret == null || clientSecret.isEmpty) {
          throw Exception('No clientSecret received from backend. Response: ${response.body}');
        }
        
        debugPrint('✅ Client secret received successfully');
        return clientSecret;
      } else {
        final errorBody = response.body;
        debugPrint('❌ Backend error: $errorBody');
        throw Exception('Failed to create payment intent: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      debugPrint('❌ Error creating payment intent: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to backend server. Please check STRIPE_BACKEND_URL in .env file and ensure the backend is running.');
      }
      throw Exception('Error creating payment intent: $e');
    }
  }
}

