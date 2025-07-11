import 'package:tour_leader/data/models/hotel.dart';
import 'package:tour_leader/data/models/review.dart';

class Destination {
  final String id;
  final String name;
  final String description;
  final String longDescription;
  final String country;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final double rating;
  final int reviewCount;
  final List<Review> reviews;
  final List<Hotel> hotels;
  final List<String> attractions;
  final List<String> categories;
  final double price;
  final String currency;
  final bool isPopular;
  final bool isFeatured;
  final String bestTimeToVisit;
  final List<String> activities;
  final Map<String, dynamic> additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.longDescription,
    required this.country,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    this.videoUrls = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [],
    this.hotels = const [],
    this.attractions = const [],
    this.categories = const [],
    this.price = 0.0,
    this.currency = 'USD',
    this.isPopular = false,
    this.isFeatured = false,
    this.bestTimeToVisit = '',
    this.activities = const [],
    this.additionalInfo = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      longDescription: json['longDescription'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrls: List<String>.from(json['videoUrls'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      reviews:
          (json['reviews'] as List?)?.map((e) => Review.fromJson(e)).toList() ??
          [],
      hotels:
          (json['hotels'] as List?)?.map((e) => Hotel.fromJson(e)).toList() ??
          [],
      attractions: List<String>.from(json['attractions'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      isPopular: json['isPopular'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      bestTimeToVisit: json['bestTimeToVisit'] ?? '',
      activities: List<String>.from(json['activities'] ?? []),
      additionalInfo: Map<String, dynamic>.from(json['additionalInfo'] ?? {}),
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
      'name': name,
      'description': description,
      'longDescription': longDescription,
      'country': country,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'hotels': hotels.map((e) => e.toJson()).toList(),
      'attractions': attractions,
      'categories': categories,
      'price': price,
      'currency': currency,
      'isPopular': isPopular,
      'isFeatured': isFeatured,
      'bestTimeToVisit': bestTimeToVisit,
      'activities': activities,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Destination copyWith({
    String? id,
    String? name,
    String? description,
    String? longDescription,
    String? country,
    String? city,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    List<String>? videoUrls,
    double? rating,
    int? reviewCount,
    List<Review>? reviews,
    List<Hotel>? hotels,
    List<String>? attractions,
    List<String>? categories,
    double? price,
    String? currency,
    bool? isPopular,
    bool? isFeatured,
    String? bestTimeToVisit,
    List<String>? activities,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      country: country ?? this.country,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      reviews: reviews ?? this.reviews,
      hotels: hotels ?? this.hotels,
      attractions: attractions ?? this.attractions,
      categories: categories ?? this.categories,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isPopular: isPopular ?? this.isPopular,
      isFeatured: isFeatured ?? this.isFeatured,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      activities: activities ?? this.activities,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Destination && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Destination(id: $id, name: $name, country: $country, city: $city)';
  }
}
