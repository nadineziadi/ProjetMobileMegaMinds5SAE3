class Review {
  String id;
  String supplementId;
  String userId;
  int rating; // 1-5
  String comment;
  DateTime date;
  String? userName; // Optional, for display

  Review({
    required this.id,
    required this.supplementId,
    required this.userId,
    required this.rating,
    required this.comment,
    DateTime? date,
    this.userName,
  }) : date = date ?? DateTime.now();

  Review copyWith({
    String? id,
    String? supplementId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? date,
    String? userName,
  }) {
    return Review(
      id: id ?? this.id,
      supplementId: supplementId ?? this.supplementId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      userName: userName ?? this.userName,
    );
  }

  bool get isValidRating => rating >= 1 && rating <= 5;

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplementId': supplementId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'userName': userName,
    };
  }

  // Create from Map (from SQLite)
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      supplementId: map['supplementId'] as String,
      userId: map['userId'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      date: DateTime.parse(map['date'] as String),
      userName: map['userName'] as String?,
    );
  }
}

