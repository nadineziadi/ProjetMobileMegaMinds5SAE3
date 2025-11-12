class PurchaseHistory {
  String id;
  String supplementId;
  String userId;
  DateTime purchaseDate;
  int quantity;
  double price;
  String? supplementName; // Cached for display
  String? supplementImageUrl; // Cached for display
  String? paymentIntentId; // Stripe payment intent ID

  PurchaseHistory({
    required this.id,
    required this.supplementId,
    required this.userId,
    required this.quantity,
    required this.price,
    DateTime? purchaseDate,
    this.supplementName,
    this.supplementImageUrl,
    this.paymentIntentId,
  }) : purchaseDate = purchaseDate ?? DateTime.now();

  PurchaseHistory copyWith({
    String? id,
    String? supplementId,
    String? userId,
    DateTime? purchaseDate,
    int? quantity,
    double? price,
    String? supplementName,
    String? supplementImageUrl,
    String? paymentIntentId,
  }) {
    return PurchaseHistory(
      id: id ?? this.id,
      supplementId: supplementId ?? this.supplementId,
      userId: userId ?? this.userId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      supplementName: supplementName ?? this.supplementName,
      supplementImageUrl: supplementImageUrl ?? this.supplementImageUrl,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
    );
  }

  double get totalAmount => quantity * price;

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplementId': supplementId,
      'userId': userId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'quantity': quantity,
      'price': price,
      'supplementName': supplementName,
      'supplementImageUrl': supplementImageUrl,
      'paymentIntentId': paymentIntentId,
    };
  }

  // Create from Map (from SQLite)
  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'] as String,
      supplementId: map['supplementId'] as String,
      userId: map['userId'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      supplementName: map['supplementName'] as String?,
      supplementImageUrl: map['supplementImageUrl'] as String?,
      paymentIntentId: map['paymentIntentId'] as String?,
    );
  }
}

