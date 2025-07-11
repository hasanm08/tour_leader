import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_share/social_share.dart';
import 'package:tour_leader/data/models/virtual_tour.dart';
import 'package:url_launcher/url_launcher.dart';

class SharingService {
  static final SharingService _instance = SharingService._internal();
  factory SharingService() => _instance;
  SharingService._internal();

  // Base deep link URL - replace with your actual domain
  static const String _baseDeepLinkUrl = 'https://tourleader.app';
  static const String _appScheme = 'tourleader';

  /// Generate a deep link for a tour
  String generateTourDeepLink(VirtualTour tour) {
    return '$_baseDeepLinkUrl/tour/${tour.id}?name=${Uri.encodeComponent(tour.name)}&duration=${tour.duration}&price=${tour.totalPrice}';
  }

  /// Generate a shareable message for a tour
  String generateShareMessage(VirtualTour tour) {
    final participantsNeeded = _calculateParticipantsNeeded(tour);
    final message = '''
🌟 Join my amazing ${tour.name} tour! 

📍 ${tour.destinations.length} incredible destinations
🗓️ ${tour.duration} days of adventure
💰 ${tour.currency} ${tour.totalPrice.toStringAsFixed(2)}

${participantsNeeded > 0 ? '👥 We need $participantsNeeded more travelers to make this tour happen!' : '👥 This tour is ready to go!'}

${tour.description}

Join me: ${generateTourDeepLink(tour)}

#TourLeader #Travel #Adventure
''';
    return message;
  }

  /// Calculate how many more participants are needed (minimum 20)
  int _calculateParticipantsNeeded(VirtualTour tour) {
    final needed = tour.minParticipants - tour.currentParticipants;
    return needed > 0 ? needed : 0;
  }

  /// Share tour to Instagram
  Future<bool> shareToInstagram(VirtualTour tour, {String? imagePath}) async {
    try {
      final message = generateShareMessage(tour);

      if (imagePath != null) {
        final result = await SocialShare.shareInstagramStory(
          appId: "your_app_id", // Replace with your actual app ID
          imagePath: imagePath,
          backgroundTopColor: "#ffffff",
          backgroundBottomColor: "#000000",
          attributionURL: generateTourDeepLink(tour),
        );
        return result?.isNotEmpty ?? false;
      } else {
        // Use system share dialog for Instagram
        await shareWithSystemDialog(tour);
        return true;
      }
    } catch (e) {
      print('Error sharing to Instagram: $e');
      return false;
    }
  }

  /// Share tour to Twitter/X
  Future<bool> shareToTwitter(VirtualTour tour) async {
    try {
      final message = generateShareMessage(tour);
      final result = await SocialShare.shareTwitter(
        message,
        hashtags: ["TourLeader", "Travel", "Adventure"],
        url: generateTourDeepLink(tour),
      );
      return result?.isNotEmpty ?? false;
    } catch (e) {
      print('Error sharing to Twitter: $e');
      return false;
    }
  }

  /// Share tour to Facebook
  Future<bool> shareToFacebook(VirtualTour tour) async {
    try {
      final message = generateShareMessage(tour);
      final result = await SocialShare.shareFacebookStory(
        imagePath: "", // You can provide an image path here
        backgroundTopColor: "#ffffff",
        backgroundBottomColor: "#000000",
        attributionURL: generateTourDeepLink(tour),
        appId:
            "your_facebook_app_id", // Replace with your actual Facebook app ID
      );
      return result?.isNotEmpty ?? false;
    } catch (e) {
      print('Error sharing to Facebook: $e');
      // Fallback to system share
      await shareWithSystemDialog(tour);
      return true;
    }
  }

  /// Share tour to WhatsApp
  Future<bool> shareToWhatsApp(VirtualTour tour) async {
    try {
      final message = generateShareMessage(tour);
      final result = await SocialShare.shareWhatsapp(message);
      return result?.isNotEmpty ?? false;
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      return false;
    }
  }

  /// Share tour to Telegram
  Future<bool> shareToTelegram(VirtualTour tour) async {
    try {
      final message = generateShareMessage(tour);
      final result = await SocialShare.shareTelegram(message);
      return result?.isNotEmpty ?? false;
    } catch (e) {
      print('Error sharing to Telegram: $e');
      return false;
    }
  }

  /// Share tour using the system share dialog
  Future<void> shareWithSystemDialog(VirtualTour tour) async {
    try {
      final message = generateShareMessage(tour);
      await Share.share(message, subject: '${tour.name} - Join my tour!');
    } catch (e) {
      print('Error sharing with system dialog: $e');
    }
  }

  /// Copy tour link to clipboard
  Future<void> copyTourLink(VirtualTour tour) async {
    try {
      final link = generateTourDeepLink(tour);
      await Clipboard.setData(ClipboardData(text: link));
    } catch (e) {
      print('Error copying tour link: $e');
    }
  }

  /// Open tour deep link in browser
  Future<bool> openTourLink(String tourId) async {
    try {
      final url = '$_baseDeepLinkUrl/tour/$tourId';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error opening tour link: $e');
      return false;
    }
  }

  /// Parse tour information from deep link
  Map<String, String>? parseTourDeepLink(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.host == 'tourleader.app' && uri.pathSegments.length >= 2) {
        final tourId = uri.pathSegments[1];
        final queryParams = uri.queryParameters;

        return {
          'tourId': tourId,
          'name': queryParams['name'] ?? '',
          'duration': queryParams['duration'] ?? '',
          'price': queryParams['price'] ?? '',
        };
      }

      return null;
    } catch (e) {
      print('Error parsing tour deep link: $e');
      return null;
    }
  }

  /// Generate share options for a tour
  List<ShareOption> getShareOptions(VirtualTour tour) {
    return [
      ShareOption(
        title: 'WhatsApp',
        icon: 'whatsapp',
        color: 0xFF25D366,
        onTap: () => shareToWhatsApp(tour),
      ),
      ShareOption(
        title: 'Instagram',
        icon: 'instagram',
        color: 0xFFE4405F,
        onTap: () => shareToInstagram(tour),
      ),
      ShareOption(
        title: 'Facebook',
        icon: 'facebook',
        color: 0xFF1877F2,
        onTap: () => shareToFacebook(tour),
      ),
      ShareOption(
        title: 'Twitter',
        icon: 'twitter',
        color: 0xFF1DA1F2,
        onTap: () => shareToTwitter(tour),
      ),
      ShareOption(
        title: 'Telegram',
        icon: 'telegram',
        color: 0xFF0088CC,
        onTap: () => shareToTelegram(tour),
      ),
      ShareOption(
        title: 'Copy Link',
        icon: 'copy',
        color: 0xFF6C757D,
        onTap: () => copyTourLink(tour),
      ),
      ShareOption(
        title: 'More',
        icon: 'more',
        color: 0xFF8E8E93,
        onTap: () => shareWithSystemDialog(tour),
      ),
    ];
  }
}

class ShareOption {
  final String title;
  final String icon;
  final int color;
  final Future<void> Function() onTap;

  ShareOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
