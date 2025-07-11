import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:tour_leader/data/services/sharing_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  final SharingService _sharingService = SharingService();

  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Handle app opened from deep link
    try {
      final initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        handleDeepLink(initialLink.toString());
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }

    // Handle deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        handleDeepLink(uri.toString());
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  /// Handle a deep link
  void handleDeepLink(String url) {
    print('Received deep link: $url');

    final tourInfo = _sharingService.parseTourDeepLink(url);
    if (tourInfo != null) {
      _handleTourInvitation(tourInfo);
    }
  }

  /// Handle tour invitation from deep link
  void _handleTourInvitation(Map<String, String> tourInfo) {
    final tourId = tourInfo['tourId'] ?? '';
    final tourName = tourInfo['name'] ?? '';
    final duration = tourInfo['duration'] ?? '';
    final price = tourInfo['price'] ?? '';

    if (tourId.isNotEmpty) {
      // Show tour invitation dialog
      _showTourInvitationDialog(tourInfo);
    }
  }

  /// Show tour invitation dialog
  void _showTourInvitationDialog(Map<String, String> tourInfo) {
    final context = _getCurrentContext();
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) => TourInvitationDialog(tourInfo: tourInfo),
    );
  }

  /// Get current context (you might need to implement this based on your app structure)
  BuildContext? _getCurrentContext() {
    // This is a simplified implementation
    // In a real app, you'd use a navigation service or global key
    return null;
  }

  /// Dispose of resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}

class TourInvitationDialog extends StatelessWidget {
  final Map<String, String> tourInfo;

  const TourInvitationDialog({super.key, required this.tourInfo});

  @override
  Widget build(BuildContext context) {
    final tourName = tourInfo['name'] ?? 'Unknown Tour';
    final duration = tourInfo['duration'] ?? '0';
    final price = tourInfo['price'] ?? '0';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF34A853)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tour, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tour Invitation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You\'ve been invited to join:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4285F4).withOpacity(0.1),
                  const Color(0xFF34A853).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4285F4).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tourName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Color(0xFF4285F4),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$duration days',
                      style: const TextStyle(
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.attach_money,
                      color: Color(0xFF34A853),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'USD $price',
                      style: const TextStyle(
                        color: Color(0xFF34A853),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFCE3D)),
            ),
            child: const Row(
              children: [
                Icon(Icons.people, color: Color(0xFFB68C00), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This tour needs 20 participants to proceed',
                    style: TextStyle(
                      color: Color(0xFFB68C00),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Maybe Later',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _joinTour(context, tourInfo);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4285F4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Join Tour'),
        ),
      ],
    );
  }

  void _joinTour(BuildContext context, Map<String, String> tourInfo) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined ${tourInfo['name']}! 🎉'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // In a real app, you would:
    // 1. Add the user to the tour
    // 2. Update the participant count
    // 3. Send notifications to other participants
    // 4. Navigate to the tour details page
  }
}

/// Tour invitation model for managing invitations
class TourInvitation {
  final String tourId;
  final String tourName;
  final String inviterName;
  final String inviterUserId;
  final DateTime invitedAt;
  final String status; // pending, accepted, declined
  final Map<String, dynamic> tourDetails;

  TourInvitation({
    required this.tourId,
    required this.tourName,
    required this.inviterName,
    required this.inviterUserId,
    required this.invitedAt,
    this.status = 'pending',
    this.tourDetails = const {},
  });

  factory TourInvitation.fromJson(Map<String, dynamic> json) {
    return TourInvitation(
      tourId: json['tourId'] ?? '',
      tourName: json['tourName'] ?? '',
      inviterName: json['inviterName'] ?? '',
      inviterUserId: json['inviterUserId'] ?? '',
      invitedAt: DateTime.parse(
        json['invitedAt'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'pending',
      tourDetails: json['tourDetails'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'tourName': tourName,
      'inviterName': inviterName,
      'inviterUserId': inviterUserId,
      'invitedAt': invitedAt.toIso8601String(),
      'status': status,
      'tourDetails': tourDetails,
    };
  }
}
