class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String destinationId;
  final String title;
  final String comment;
  final double rating;
  final List<String> imageUrls;
  final bool isVerified;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl = '',
    required this.destinationId,
    required this.title,
    required this.comment,
    required this.rating,
    this.imageUrls = const [],
    this.isVerified = false,
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatarUrl: json['userAvatarUrl'] ?? '',
      destinationId: json['destinationId'] ?? '',
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      isVerified: json['isVerified'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'destinationId': destinationId,
      'title': title,
      'comment': comment,
      'rating': rating,
      'imageUrls': imageUrls,
      'isVerified': isVerified,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? destinationId,
    String? title,
    String? comment,
    double? rating,
    List<String>? imageUrls,
    bool? isVerified,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      destinationId: destinationId ?? this.destinationId,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerified: isVerified ?? this.isVerified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Review(id: $id, userId: $userId, rating: $rating)';
  }
}
