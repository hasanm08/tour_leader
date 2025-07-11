class AppConstants {
  // App Info
  static const String appName = 'TourLeader';
  static const String appVersion = '1.0.0';

  // API Configuration (for future use)
  static const String baseUrl = 'https://api.tourleader.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  static const double cardElevation = 4.0;

  // Image Sizes
  static const double profileImageSize = 40.0;
  static const double largeProfileImageSize = 80.0;
  static const double thumbnailSize = 60.0;

  // Grid/List
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = 16.0;
  static const double listItemHeight = 120.0;

  // Chat
  static const int maxMessageLength = 1000;
  static const int messagesPerPage = 20;

  // Virtual Tour
  static const int maxDestinationsInTour = 10;

  // Ratings
  static const double maxRating = 5.0;
  static const double minRating = 1.0;
}
