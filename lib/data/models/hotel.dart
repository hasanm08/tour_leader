class Hotel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final String currency;
  final List<String> amenities;
  final List<String> roomTypes;
  final bool isAvailable;
  final bool isFeatured;
  final String contactPhone;
  final String contactEmail;
  final String website;
  final String checkInTime;
  final String checkOutTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.pricePerNight = 0.0,
    this.currency = 'USD',
    this.amenities = const [],
    this.roomTypes = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    this.contactPhone = '',
    this.contactEmail = '',
    this.website = '',
    this.checkInTime = '14:00',
    this.checkOutTime = '12:00',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      pricePerNight: (json['pricePerNight'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      amenities: List<String>.from(json['amenities'] ?? []),
      roomTypes: List<String>.from(json['roomTypes'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      contactPhone: json['contactPhone'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      website: json['website'] ?? '',
      checkInTime: json['checkInTime'] ?? '14:00',
      checkOutTime: json['checkOutTime'] ?? '12:00',
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
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'rating': rating,
      'reviewCount': reviewCount,
      'pricePerNight': pricePerNight,
      'currency': currency,
      'amenities': amenities,
      'roomTypes': roomTypes,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'website': website,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Hotel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    double? pricePerNight,
    String? currency,
    List<String>? amenities,
    List<String>? roomTypes,
    bool? isAvailable,
    bool? isFeatured,
    String? contactPhone,
    String? contactEmail,
    String? website,
    String? checkInTime,
    String? checkOutTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      currency: currency ?? this.currency,
      amenities: amenities ?? this.amenities,
      roomTypes: roomTypes ?? this.roomTypes,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      website: website ?? this.website,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hotel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Hotel(id: $id, name: $name, address: $address)';
  }
}
