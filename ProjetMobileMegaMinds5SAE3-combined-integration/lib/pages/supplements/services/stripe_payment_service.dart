import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'stripe_api_service.dart';

class StripePaymentService {
  /// Process a payment with quantity, currency, and description
  /// [amount] should be in cents (e.g., 1500 = $15.00)
  /// [currency] is the currency code (default: 'usd')
  /// [description] is the product description
  /// [quantity] is the quantity being purchased (default: 1)
  /// Returns true if payment was successful, throws exception if failed
  Future<bool> pay({
    required int amount,
    String currency = 'usd',
    String description = '',
    int quantity = 1,
  }) async {
    try {
      // Validate Stripe is initialized
      if (Stripe.publishableKey == null || Stripe.publishableKey!.isEmpty) {
        throw Exception('Stripe is not initialized. Please check your STRIPE_PUBLISHABLE_KEY in .env file.');
      }
      
      debugPrint('🔄 Creating payment intent: amount=$amount, currency=$currency, quantity=$quantity');
      
      // Step 1: Get client secret from backend
      final clientSecret = await StripeApiService.createPaymentIntent(
        amount: amount,
        currency: currency,
        description: description,
        quantity: quantity,
      );
      
      if (clientSecret.isEmpty) {
        throw Exception('Failed to get client secret from backend');
      }
      
      debugPrint('✅ Received client secret from backend');
      
      // Step 2: Initialize payment sheet with Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'FitLife Tracker',
        ),
      );

      debugPrint('✅ Payment sheet initialized');

      // Step 3: Present payment sheet to user
      await Stripe.instance.presentPaymentSheet();

      debugPrint('✅ Payment completed successfully');
      
      // Step 4: Payment completed successfully
      return true;
    } on StripeException catch (e) {
      // Handle Stripe-specific errors
      debugPrint('❌ Stripe error: ${e.error.message}');
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Payment was canceled by user');
      } else {
        throw Exception('Stripe error: ${e.error.message}');
      }
    } catch (e) {
      // Handle other errors
      debugPrint('❌ Payment error: $e');
      throw Exception('Payment failed: $e');
    }
  }
}

