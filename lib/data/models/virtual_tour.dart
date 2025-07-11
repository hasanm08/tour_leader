import 'package:tour_leader/data/models/destination.dart';

class VirtualTour {
  final String id;
  final String name;
  final String description;
  final String userId;
  final List<Destination> destinations;
  final double totalPrice;
  final String currency;
  final int duration; // in days
  final DateTime startDate;
  final DateTime endDate;
  final bool isBookmarked;
  final bool isShared;
  final String status; // draft, active, completed
  final int currentParticipants;
  final int minParticipants;
  final int maxParticipants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VirtualTour({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.destinations,
    this.totalPrice = 0.0,
    this.currency = 'USD',
    this.duration = 0,
    required this.startDate,
    required this.endDate,
    this.isBookmarked = false,
    this.isShared = false,
    this.status = 'draft',
    this.currentParticipants = 1,
    this.minParticipants = 20,
    this.maxParticipants = 50,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VirtualTour.fromJson(Map<String, dynamic> json) {
    return VirtualTour(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      destinations:
          (json['destinations'] as List?)
              ?.map((e) => Destination.fromJson(e))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      duration: json['duration'] ?? 0,
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      isBookmarked: json['isBookmarked'] ?? false,
      isShared: json['isShared'] ?? false,
      status: json['status'] ?? 'draft',
      currentParticipants: json['currentParticipants'] ?? 1,
      minParticipants: json['minParticipants'] ?? 20,
      maxParticipants: json['maxParticipants'] ?? 50,
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
      'userId': userId,
      'destinations': destinations.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'currency': currency,
      'duration': duration,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isBookmarked': isBookmarked,
      'isShared': isShared,
      'status': status,
      'currentParticipants': currentParticipants,
      'minParticipants': minParticipants,
      'maxParticipants': maxParticipants,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  VirtualTour copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    List<Destination>? destinations,
    double? totalPrice,
    String? currency,
    int? duration,
    DateTime? startDate,
    DateTime? endDate,
    bool? isBookmarked,
    bool? isShared,
    String? status,
    int? currentParticipants,
    int? minParticipants,
    int? maxParticipants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VirtualTour(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      destinations: destinations ?? this.destinations,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isShared: isShared ?? this.isShared,
      status: status ?? this.status,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      minParticipants: minParticipants ?? this.minParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VirtualTour && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VirtualTour(id: $id, name: $name, destinations: ${destinations.length})';
  }
}
