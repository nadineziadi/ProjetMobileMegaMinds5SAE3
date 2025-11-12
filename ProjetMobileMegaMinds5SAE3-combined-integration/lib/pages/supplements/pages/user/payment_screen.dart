import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/supplement.dart';
import '../../models/purchase_history.dart';
import '../../services/supplement_database_service.dart';
import '../../services/stripe_payment_service.dart';
import '../../services/email_api_service.dart';

class PaymentScreen extends StatefulWidget {
  final Supplement supplement;
  final int quantity;

  const PaymentScreen({
    super.key,
    required this.supplement,
    this.quantity = 1,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String? _errorMessage;
  final StripePaymentService _paymentService = StripePaymentService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Convert price from dollars to cents for Stripe
  /// Total amount = price per item * quantity
  int _getAmountInCents() {
    return (widget.supplement.price * widget.quantity * 100).toInt();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final amountInCents = _getAmountInCents();
      
      // Process payment through Stripe with quantity parameter
      final success = await _paymentService.pay(
        amount: (widget.supplement.price * 100).toInt(), // Price per item in cents
        currency: 'usd',
        description: widget.supplement.name,
        quantity: widget.quantity,
      );

      if (success && mounted) {
        // Record purchase in database
        try {
          final purchase = PurchaseHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            supplementId: widget.supplement.id,
            supplementName: widget.supplement.name,
            price: widget.supplement.price,
            quantity: widget.quantity,
            purchaseDate: DateTime.now(),
            userId: 'user_${DateTime.now().millisecondsSinceEpoch}', // TODO: Get actual user ID
          );
          await SupplementDatabaseService.savePurchaseHistory(purchase);
        } catch (e) {
          debugPrint('Warning: Failed to save purchase history: $e');
          // Don't fail the payment if history save fails
        }

        // Send order confirmation email (non-blocking)
        try {
          final totalPrice = widget.supplement.price * widget.quantity;
          final emailSent = await EmailApiService.sendOrderConfirmationEmail(
            customerEmail: _emailController.text.trim(),
            customerName: _nameController.text.trim().isEmpty 
                ? 'Customer' 
                : _nameController.text.trim(),
            supplement: widget.supplement,
            quantity: widget.quantity,
            totalPrice: totalPrice,
            purchaseTime: DateTime.now(),
          );

          if (emailSent) {
            debugPrint('✅ Order confirmation email sent successfully');
          } else {
            debugPrint('⚠️ Email sending failed but payment succeeded');
          }
        } catch (e) {
          debugPrint('Warning: Failed to send email: $e');
          // Don't fail payment if email fails
        }

        // Show success message
        if (mounted) {
          await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Payment Successful'),
              content: Text(
                'Your purchase of ${widget.supplement.name} has been completed successfully!\n\nA confirmation email has been sent to ${_emailController.text.trim()}.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close payment screen
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isProcessing = false;
      });

      if (mounted) {
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Payment Failed'),
            content: Text(_errorMessage ?? 'An unknown error occurred'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountInCents = _getAmountInCents();
    final priceInDollars = (amountInCents / 100).toStringAsFixed(2);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF17191C),
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Payment',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: Color(0xFF32383E),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                
                // Product Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF32383E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.supplement.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Brand: ${widget.supplement.brand}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (widget.quantity > 1) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Quantity: ${widget.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          '\$$priceInDollars',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC7F000),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Customer Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF32383E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name field (optional)
                    CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Your Name (Optional)',
                      placeholderStyle: TextStyle(color: Colors.grey[400]),
                      style: const TextStyle(color: CupertinoColors.white),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17191C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Email field (required)
                    StatefulBuilder(
                      builder: (context, setStateField) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoTextField(
                              controller: _emailController,
                              placeholder: 'Email Address *',
                              placeholderStyle: TextStyle(color: Colors.grey[400]),
                              style: const TextStyle(color: CupertinoColors.white),
                              keyboardType: TextInputType.emailAddress,
                              padding: const EdgeInsets.all(12),
                              onChanged: (value) {
                                setStateField(() {});
                                if (_formKey.currentState != null) {
                                  _formKey.currentState!.validate();
                                }
                              },
                              decoration: BoxDecoration(
                                color: const Color(0xFF17191C),
                                borderRadius: BorderRadius.circular(8),
                                border: _emailController.text.isNotEmpty && 
                                        !_isValidEmail(_emailController.text)
                                    ? Border.all(color: CupertinoColors.systemRed, width: 1)
                                    : null,
                              ),
                            ),
                            if (_emailController.text.isNotEmpty && 
                                !_isValidEmail(_emailController.text)) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Please enter a valid email address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemRed,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll send your order confirmation to this email',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Payment Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: _isProcessing
                      ? Colors.grey
                      : const Color(0xFFC7F000),
                  disabledColor: Colors.grey,
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const CupertinoActivityIndicator()
                      : const Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Color(0xFF17191C),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: TextDecoration.none,
                          ),
                        ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_circle_fill,
                        color: CupertinoColors.systemRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF32383E).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.lock_fill,
                      color: Color(0xFFC7F000),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your payment is secured by Stripe. We never store your card details.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

