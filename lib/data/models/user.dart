class User {
  final String id;
  final String email;
  final String name;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? bio;
  final String? location;
  final List<String> interests;
  final List<String> favoriteDestinations;
  final int totalTrips;
  final int totalReviews;
  final bool isVerified;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
    this.location,
    this.interests = const [],
    this.favoriteDestinations = const [],
    this.totalTrips = 0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'])
              : null,
      bio: json['bio'],
      location: json['location'],
      interests: List<String>.from(json['interests'] ?? []),
      favoriteDestinations: List<String>.from(
        json['favoriteDestinations'] ?? [],
      ),
      totalTrips: json['totalTrips'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(
        json['lastSeen'] ?? DateTime.now().toIso8601String(),
      ),
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
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'location': location,
      'interests': interests,
      'favoriteDestinations': favoriteDestinations,
      'totalTrips': totalTrips,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
    String? location,
    List<String>? interests,
    List<String>? favoriteDestinations,
    int? totalTrips,
    int? totalReviews,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      favoriteDestinations: favoriteDestinations ?? this.favoriteDestinations,
      totalTrips: totalTrips ?? this.totalTrips,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}
