import 'dart:math' show sin, cos, pi;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tour_leader/core/theme/app_theme.dart';
import 'package:tour_leader/data/models/destination.dart';
import 'package:tour_leader/data/services/destination_service.dart';
import 'package:tour_leader/presentation/widgets/section_header.dart';

// Provider for virtual tour destinations
final virtualTourDestinationsProvider = FutureProvider<List<Destination>>((
  ref,
) {
  return DestinationService().getFeaturedDestinations();
});

class VirtualTourPage extends ConsumerStatefulWidget {
  const VirtualTourPage({super.key});

  @override
  ConsumerState<VirtualTourPage> createState() => _VirtualTourPageState();
}

class _VirtualTourPageState extends ConsumerState<VirtualTourPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentTourIndex = 0;
  bool _isInVirtualMode = false;
  String? _selectedDestination;
  final bool _isFullscreen = false;

  // Enhanced 3D Panoramic State
  final double _panAngle = 0.0;
  final double _tiltAngle = 0.0;
  final double _zoomLevel = 1.0;
  final bool _isDragging = false;
  Offset? _lastPanPosition;
  final bool _isGyroscopeMode = false;

  // Advanced 3D Effects
  final double _parallaxOffset = 0.0;
  final double _depthLayer1 = 0.0;
  final double _depthLayer2 = 0.0;
  final double _depthLayer3 = 0.0;
  final double _lightingIntensity = 1.0;
  final bool _showHotspots = true;
  final int _activeHotspot = -1;
  final double _atmosphereOpacity = 0.3;
  final bool _showParticles = true;

  // Ticket Purchase State
  final bool _showTicketDialog = false;
  final bool _isAddingToTour = false;

  // Enhanced Animation Controllers
  late AnimationController _parallaxController;
  late Animation<double> _parallaxAnimation;
  late AnimationController _hotspotController;
  late Animation<double> _hotspotAnimation;
  late AnimationController _lightingController;
  late Animation<double> _lightingAnimation;
  late AnimationController _particleController;
  late Animation<double> _particleAnimation;
  late AnimationController _atmosphereController;
  late Animation<double> _atmosphereAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initialize3DEffects();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  void _initialize3DEffects() {
    // Parallax effect controller
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _parallaxAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _parallaxController, curve: Curves.easeInOut),
    );

    // Hotspot pulse controller
    _hotspotController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _hotspotAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _hotspotController, curve: Curves.easeInOut),
    );

    // Dynamic lighting controller
    _lightingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _lightingAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _lightingController, curve: Curves.easeInOut),
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Atmosphere effect controller
    _atmosphereController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _atmosphereAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _atmosphereController, curve: Curves.easeInOut),
    );

    // Start continuous animations
    _parallaxController.repeat(reverse: true);
    _hotspotController.repeat(reverse: true);
    _lightingController.repeat(reverse: true);
    _particleController.repeat();
    _atmosphereController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _parallaxController.dispose();
    _hotspotController.dispose();
    _lightingController.dispose();
    _particleController.dispose();
    _atmosphereController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildVirtualTourHero(),
                        _buildAvailableToursSection(),
                        _buildInteractiveFeaturesSection(),
                        _buildRecentToursSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.view_in_ar,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Virtual Tours',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Filter virtual tours
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
          ),
        ),
        IconButton(
          onPressed: () {
            // Search virtual tours
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualTourHero() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.view_in_ar, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Experience Destinations in 360°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore amazing places from anywhere in the world with immersive virtual tours',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _startVirtualTour(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Virtual Tour'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableToursSection() {
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync = ref.watch(virtualTourDestinationsProvider);

        return destinationsAsync.when(
          data: (destinations) {
            if (destinations.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  SectionHeader(
                    title: '🌍 Available Virtual Tours',
                    subtitle: 'Explore destinations in immersive 360° views',
                    onSeeAll: () => context.go('/explore'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: destinations.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentTourIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildVirtualTourCard(destination),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      destinations.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              index == _currentTourIndex
                                  ? AppTheme.primaryColor
                                  : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading:
              () => const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildVirtualTourCard(Destination destination) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                destination.imageUrls.isNotEmpty
                    ? destination.imageUrls.first
                    : 'assets/images/placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '360° VIEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.view_in_ar,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      destination.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => _startVirtualTourForDestination(
                                  destination,
                                ),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Start Tour'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _shareVirtualTour(destination),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFeaturesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            title: '🎮 Interactive Features',
            subtitle: 'Make your virtual tour experience even better',
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                'Voice Guide',
                Icons.record_voice_over,
                'Audio commentary in multiple languages',
                AppTheme.primaryGradient,
                () {},
              ),
              _buildFeatureCard(
                'Photo Mode',
                Icons.camera_alt,
                'Capture stunning screenshots',
                AppTheme.secondaryGradient,
                () {},
              ),
              _buildFeatureCard(
                'Night Mode',
                Icons.nightlight,
                'Experience destinations at night',
                AppTheme.accentGradient,
                () {},
              ),
              _buildFeatureCard(
                'Weather',
                Icons.wb_sunny,
                'See different weather conditions',
                const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                ),
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    String description,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentToursSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionHeader(
            title: '📱 Recent Virtual Tours',
            subtitle: 'Continue where you left off',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No recent tours',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Start exploring destinations to see your history here',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startVirtualTour() {
    setState(() {
      _isInVirtualMode = true;
    });

    // Show virtual tour mode dialog
    showDialog(
      context: context,
      builder: (context) => _buildVirtualTourModeDialog(),
    );
  }

  void _startVirtualTourForDestination(Destination destination) {
    setState(() {
      _selectedDestination = destination.name;
      _isInVirtualMode = true;
    });

    // Navigate to virtual tour experience
    _showVirtualTourExperience(destination);
  }

  void _shareVirtualTour(Destination destination) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing virtual tour for ${destination.name}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildVirtualTourModeDialog() {
    return AlertDialog(
      title: const Text('Choose Virtual Tour Mode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.view_in_ar, color: AppTheme.primaryColor),
            title: const Text('360° Panoramic View'),
            subtitle: const Text('Explore destinations in full 360°'),
            onTap: () {
              Navigator.pop(context);
              _showVirtualTourExperience(null);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.video_library,
              color: AppTheme.secondaryColor,
            ),
            title: const Text('Video Tour'),
            subtitle: const Text('Watch guided video tours'),
            onTap: () {
              Navigator.pop(context);
              _showVideoTourExperience();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library,
              color: AppTheme.accentColor,
            ),
            title: const Text('Photo Gallery'),
            subtitle: const Text('Browse high-quality photos'),
            onTap: () {
              Navigator.pop(context);
              _showPhotoGalleryExperience();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _showVirtualTourExperience(Destination? destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _VirtualTourExperienceModal(destination: destination),
    );
  }

  void _showVideoTourExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoTourExperienceModal(),
    );
  }

  void _showPhotoGalleryExperience() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoGalleryExperienceModal(),
    );
  }
}

class _VirtualTourExperienceModal extends StatefulWidget {
  final Destination? destination;

  const _VirtualTourExperienceModal({this.destination});

  @override
  State<_VirtualTourExperienceModal> createState() =>
      _VirtualTourExperienceModalState();
}

class _VirtualTourExperienceModalState
    extends State<_VirtualTourExperienceModal>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  // Cinematic Animation Controllers
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _morphController;
  late AnimationController _floatingController;
  late AnimationController _shimmerController;
  late AnimationController _rippleController;

  // Cinematic Animations
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _morphAnimation;
  late Animation<Offset> _floatingAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rippleAnimation;

  final double _currentRotation = 0.0;
  final double _currentTilt = 0.0;
  bool _isLoading = true;
  final int _currentViewIndex = 0;
  bool _isGyroscopeMode = false;
  bool _isFullscreen = false;

  // Enhanced Visual State
  final double _particleIntensity = 1.0;
  final double _ambientGlow = 0.5;
  List<ParticleData> _particles = [];
  final List<RippleData> _ripples = [];

  // 360° panoramic images for different viewpoints
  final List<String> _panoramicImages = [
    'assets/images/santorini.jpg',
    'assets/images/bali.jpg',
    'assets/images/kyoto.jpg',
    'assets/images/cappadocia.jpg',
    'assets/images/banff.jpg',
  ];

  final List<String> _viewPoints = [
    'Main Square',
    'Coastal View',
    'Mountain Vista',
    'City Center',
    'Historic District',
  ];

  // 360° rotation data
  double _panAngle = 0.0;
  double _tiltAngle = 0.0;
  double _zoomLevel = 1.0;
  bool _isDragging = false;
  Offset? _lastPanPosition;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _simulateLoading();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Cinematic Animation Controllers
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _morphController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animation Definitions
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Start Continuous Animations
    _rotationController.repeat();
    _particleController.repeat();
    _waveController.repeat();
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _morphController.repeat();
    _floatingController.repeat(reverse: true);
    _shimmerController.repeat();

    // Initialize particles
    _initializeParticles();
  }

  void _initializeParticles() {
    _particles = List.generate(50, (index) {
      return ParticleData(
        position: Offset((index * 17) % 300 + 50.0, (index * 23) % 400 + 100.0),
        velocity: Offset((index % 3 - 1) * 0.5, (index % 4 - 2) * 0.3),
        size: 2.0 + (index % 3),
        opacity: 0.3 + (index % 7) * 0.1,
        color:
            [
              Colors.white,
              Colors.blue.shade200,
              Colors.purple.shade200,
              Colors.pink.shade200,
            ][index % 4],
      );
    });
  }

  void _simulateLoading() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _morphController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _addRipple(Offset position) {
    setState(() {
      _ripples.add(RippleData(position: position, radius: 0.0, opacity: 0.8));
    });

    _rippleController.reset();
    _rippleController.forward().then((_) {
      if (mounted) {
        setState(() {
          _ripples.removeWhere((ripple) => ripple.opacity <= 0.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: _isLoading ? _buildLoadingView() : _buildVirtualTourView(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.view_in_ar,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading 360° Panoramic...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preparing immersive panoramic experience',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualTourView() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.destination?.name ?? '360° Panoramic Tour',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _viewPoints[_currentViewIndex],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _toggleGyroscopeMode(),
                icon: Icon(
                  _isGyroscopeMode
                      ? Icons.screen_rotation
                      : Icons.screen_rotation_alt,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => _toggleFullscreen(),
                icon: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ],
          ),
        ),

        // BREATHTAKING 3D Cinematic Panoramic Experience
        Expanded(
          child: GestureDetector(
            onTapDown: (details) {
              _addRipple(details.localPosition);
            },
            onScaleStart: (details) {
              setState(() {
                _isDragging = true;
                _lastPanPosition = details.localFocalPoint;
              });
            },
            onScaleUpdate: (details) {
              setState(() {
                // Zoom functionality
                _zoomLevel = details.scale.clamp(0.5, 3.0);

                // Pan during scale (handles both pan and zoom)
                if (_lastPanPosition != null) {
                  final deltaX = details.focalPoint.dx - _lastPanPosition!.dx;
                  final deltaY = details.focalPoint.dy - _lastPanPosition!.dy;

                  _panAngle += deltaX * 0.01;
                  _tiltAngle += deltaY * 0.01;
                  _tiltAngle = _tiltAngle.clamp(-0.5, 0.5);

                  _lastPanPosition = details.focalPoint;
                }
              });
            },
            onScaleEnd: (details) {
              setState(() {
                _isDragging = false;
                _lastPanPosition = null;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Animated Cosmic Background
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _waveAnimation,
                          _glowAnimation,
                          _morphAnimation,
                        ]),
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.5 + _waveAnimation.value * 0.3,
                                colors: [
                                  Colors.deepPurple.withOpacity(
                                    0.3 * _glowAnimation.value,
                                  ),
                                  Colors.blue.withOpacity(
                                    0.4 * _glowAnimation.value,
                                  ),
                                  Colors.purple.withOpacity(
                                    0.2 * _glowAnimation.value,
                                  ),
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: CustomPaint(
                              painter: CosmicBackgroundPainter(
                                animation: _morphAnimation.value,
                                waveValue: _waveAnimation.value,
                              ),
                              size: Size.infinite,
                            ),
                          );
                        },
                      ),
                    ),

                    // Floating Particle System
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _particleAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: CinematicParticlePainter(
                              particles: _particles,
                              animationValue: _particleAnimation.value,
                              intensity: _particleIntensity,
                            ),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),

                    // Main 360° Panoramic Image with Morphing Effects
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _fadeAnimation,
                          _morphAnimation,
                          _pulseAnimation,
                        ]),
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform(
                              transform:
                                  Matrix4.identity()
                                    ..setEntry(3, 2, 0.003) // Deep perspective
                                    ..rotateY(
                                      _panAngle + _morphAnimation.value * 0.1,
                                    )
                                    ..rotateX(
                                      _tiltAngle +
                                          sin(_waveAnimation.value) * 0.05,
                                    )
                                    ..scale(_zoomLevel * _pulseAnimation.value),
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 20 * _glowAnimation.value,
                                      spreadRadius: 5 * _glowAnimation.value,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Stack(
                                    children: [
                                      // Base panoramic image
                                      _buildEnhancedPanoramicImage(),

                                      // Morphing overlay
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.cyan.withOpacity(
                                                0.1 * _morphAnimation.value,
                                              ),
                                              Colors.purple.withOpacity(
                                                0.08 * _morphAnimation.value,
                                              ),
                                              Colors.pink.withOpacity(
                                                0.06 * _morphAnimation.value,
                                              ),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Floating Elements Layer
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _floatingAnimation.value * 20,
                            child: CustomPaint(
                              painter: FloatingElementsPainter(
                                floatValue: _floatingAnimation.value.dy,
                                glowIntensity: _glowAnimation.value,
                              ),
                              size: Size.infinite,
                            ),
                          );
                        },
                      ),
                    ),

                    // Interactive Ripple Effects
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: RippleEffectPainter(
                              ripples: _ripples,
                              animationValue: _rippleAnimation.value,
                            ),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),

                    // Holographic Shimmer Effect
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(
                                  -1.0 + _shimmerAnimation.value * 2,
                                  -1.0,
                                ),
                                end: Alignment(
                                  1.0 + _shimmerAnimation.value * 2,
                                  1.0,
                                ),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.1),
                                  Colors.cyan.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Dynamic Energy Orbs
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _pulseAnimation,
                          _morphAnimation,
                        ]),
                        builder: (context, child) {
                          return CustomPaint(
                            painter: EnergyOrbsPainter(
                              pulseValue: _pulseAnimation.value,
                              morphValue: _morphAnimation.value,
                            ),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),

                    // Interactive Hotspots with Pulsing Glow
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: _buildInteractiveHotspots(),
                        );
                      },
                    ),

                    // Floating Control Panel with Morphing Background
                    Positioned(
                      top: 16,
                      left: 16,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _glowAnimation,
                          _floatingAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _floatingAnimation.value * 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.purple.withOpacity(
                                      0.3 * _glowAnimation.value,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.cyan.withOpacity(
                                    0.6 * _glowAnimation.value,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withOpacity(
                                      0.3 * _glowAnimation.value,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Icon(
                                          Icons.view_in_ar,
                                          color: Colors.white,
                                          size: 18,
                                          shadows: [
                                            Shadow(
                                              color: Colors.cyan.withOpacity(
                                                _glowAnimation.value,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.cyan.withOpacity(
                                              _glowAnimation.value,
                                            ),
                                            Colors.purple.withOpacity(
                                              _glowAnimation.value,
                                            ),
                                          ],
                                        ).createShader(bounds),
                                    child: const Text(
                                      '360° CINEMATIC',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Floating Action Buttons with Cosmic Effects
                    Positioned(
                      right: 16,
                      top: 80,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatingAnimation,
                          _glowAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _floatingAnimation.value * 10,
                            child: Column(
                              children: [
                                _buildCinematicControlButton(
                                  icon: Icons.zoom_in,
                                  onPressed: () => _zoomIn(),
                                  tooltip: 'Zoom In',
                                ),
                                const SizedBox(height: 12),
                                _buildCinematicControlButton(
                                  icon: Icons.zoom_out,
                                  onPressed: () => _zoomOut(),
                                  tooltip: 'Zoom Out',
                                ),
                                const SizedBox(height: 12),
                                _buildCinematicControlButton(
                                  icon: Icons.refresh,
                                  onPressed: () => _resetView(),
                                  tooltip: 'Reset View',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Breathtaking Call-to-Action with Morphing Background
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _pulseAnimation,
                          _glowAnimation,
                          _morphAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.95 + _pulseAnimation.value * 0.05,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.4 * _glowAnimation.value,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: _buildCinematicCallToActionButtons(),
                            ),
                          );
                        },
                      ),
                    ),

                    // Immersive Instruction Panel
                    Positioned(
                      bottom: 100,
                      left: 16,
                      right: 16,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatingAnimation,
                          _shimmerAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _floatingAnimation.value * 8,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              transform:
                                  Matrix4.identity()
                                    ..scale(_isDragging ? 0.95 : 1.0),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.purple.withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback:
                                          (bounds) => LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.cyan,
                                              Colors.purple,
                                            ],
                                          ).createShader(bounds),
                                      child: Text(
                                        _isGyroscopeMode
                                            ? '📱 Move device to explore the universe'
                                            : '👆 Drag to explore • 🔍 Pinch to zoom into infinity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '✨ Experience the magic of cinematic reality',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Control Panel
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.volume_up,
                onPressed: () => _toggleAudio(),
                tooltip: 'Audio',
              ),
              _buildControlButton(
                icon: Icons.camera_alt,
                onPressed: () => _takePhoto(),
                tooltip: 'Photo',
              ),
              _buildControlButton(
                icon: Icons.refresh,
                onPressed: () => _resetView(),
                tooltip: 'Reset',
              ),
              _buildControlButton(
                icon: Icons.info_outline,
                onPressed: () => _showInfo(),
                tooltip: 'Info',
              ),
              _buildControlButton(
                icon: Icons.share,
                onPressed: () => _shareExperience(),
                tooltip: 'Share',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPanoramicImage() {
    // Create a more realistic 360° panoramic effect
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        widget.destination?.imageUrls.isNotEmpty == true
            ? widget.destination!.imageUrls.first
            : _panoramicImages[_currentViewIndex % _panoramicImages.length],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildEnhancedPanoramicImage() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        widget.destination?.imageUrls.isNotEmpty == true
            ? widget.destination!.imageUrls.first
            : _panoramicImages[_currentViewIndex % _panoramicImages.length],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildDepthLayerPattern() {
    return CustomPaint(
      painter: DepthLayerPainter(
        imagePath:
            'assets/images/mountain_pattern.jpg', // Replace with your actual pattern image
        panAngle: _panAngle,
        tiltAngle: _tiltAngle,
        zoomLevel: _zoomLevel,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildMidgroundPattern() {
    return CustomPaint(
      painter: MidgroundPainter(
        imagePath:
            'assets/images/city_pattern.jpg', // Replace with your actual pattern image
        panAngle: _panAngle,
        tiltAngle: _tiltAngle,
        zoomLevel: _zoomLevel,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildInteractiveHotspots() {
    return Positioned.fill(
      child: CustomPaint(
        painter: HotspotPainter(
          imagePath:
              widget.destination?.imageUrls.isNotEmpty == true
                  ? widget.destination!.imageUrls.first
                  : _panoramicImages[_currentViewIndex %
                      _panoramicImages.length],
          panAngle: _panAngle,
          tiltAngle: _tiltAngle,
          zoomLevel: _zoomLevel,
          hotspotRadius: 0.05, // Adjust as needed
          hotspotColor: AppTheme.accentColor.withOpacity(0.8),
          hotspotBorderColor: Colors.white.withOpacity(0.5),
          hotspotBorderWidth: 2.0,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlePainter(
          imagePath:
              'assets/images/particle.png', // Replace with your actual particle image
          panAngle: _panAngle,
          tiltAngle: _tiltAngle,
          zoomLevel: _zoomLevel,
          particleCount: 50,
          particleSize: 10.0,
          particleSpeed: 0.5,
          particleOpacity: 0.7,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildCallToActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _purchaseTicket(),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Buy Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _addToTour(),
            icon: const Icon(Icons.add_to_photos),
            label: const Text('Add to Tour'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  void _toggleGyroscopeMode() {
    setState(() {
      _isGyroscopeMode = !_isGyroscopeMode;
    });

    if (_isGyroscopeMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gyroscope mode activated - move your device to look around',
          ),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  void _rotateLeft() {
    setState(() {
      _panAngle -= 0.5; // Rotate 90 degrees left
    });
  }

  void _rotateRight() {
    setState(() {
      _panAngle += 0.5; // Rotate 90 degrees right
    });
  }

  void _resetView() {
    setState(() {
      _panAngle = 0.0;
      _tiltAngle = 0.0;
      _zoomLevel = 1.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View reset to center'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _toggleAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio guide toggled'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Panoramic photo captured at ${_viewPoints[_currentViewIndex]}',
        ),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'About ${widget.destination?.name ?? '360° Panoramic Tour'}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${widget.destination?.city}, ${widget.destination?.country}',
                ),
                const SizedBox(height: 8),
                Text('Description: ${widget.destination?.description}'),
                const SizedBox(height: 8),
                const Text('360° Panoramic Features:'),
                const Text('• Full 360° horizontal rotation'),
                const Text('• Vertical tilt with limits'),
                const Text('• Zoom functionality'),
                const Text('• Gyroscope support'),
                const Text('• Photo capture'),
                const Text('• Audio commentary'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _shareExperience() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing 360° panoramic tour of ${widget.destination?.name}',
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _purchaseTicket() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Purchase Ticket for ${widget.destination?.name}'),
            content: Text(
              'Would you like to purchase a ticket for this virtual tour?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ticket purchased for ${widget.destination?.name}!',
                      ),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
                child: const Text('Buy Now'),
              ),
            ],
          ),
    );
  }

  void _addToTour() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add to Tour for ${widget.destination?.name}'),
            content: Text(
              'Would you like to add this virtual tour to your tour list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added ${widget.destination?.name} to your tour!',
                      ),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                },
                child: const Text('Add to Tour'),
              ),
            ],
          ),
    );
  }

  // Helper methods for enhanced 3D experience
  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 3.0);
    });
  }

  // Cinematic UI Methods
  Widget _buildCinematicControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Tooltip(
          message: tooltip ?? '',
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.secondaryColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.6 * _glowAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(
                    0.4 * _glowAnimation.value,
                  ),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(25),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                  shadows: [
                    Shadow(
                      color: Colors.cyan.withOpacity(_glowAnimation.value),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCinematicCallToActionButtons() {
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.9),
                AppTheme.primaryColor.withOpacity(0.3 * _morphAnimation.value),
                AppTheme.secondaryColor.withOpacity(
                  0.2 * _morphAnimation.value,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildCinematicButton(
                    'Buy Ticket',
                    Icons.shopping_cart,
                    AppTheme.primaryGradient,
                    () => _purchaseTicket(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCinematicButton(
                    'Add to Tour',
                    Icons.add_to_photos,
                    AppTheme.secondaryGradient,
                    () => _addToTour(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCinematicButton(
    String text,
    IconData icon,
    Gradient gradient,
    VoidCallback onPressed,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 18,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// BREATHTAKING CUSTOM PAINTERS FOR CINEMATIC EFFECTS

class CosmicBackgroundPainter extends CustomPainter {
  final double animation;
  final double waveValue;

  CosmicBackgroundPainter({required this.animation, required this.waveValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create cosmic nebula effect
    for (int i = 0; i < 5; i++) {
      final radius =
          size.width * (0.1 + i * 0.15) * (1 + sin(waveValue + i) * 0.2);
      final center = Offset(
        size.width * (0.2 + i * 0.2 + cos(animation * 2 + i) * 0.1),
        size.height * (0.3 + sin(animation + i) * 0.2),
      );

      paint.shader = RadialGradient(
        colors: [
          [
            Colors.purple,
            Colors.blue,
            Colors.cyan,
            Colors.pink,
            Colors.orange,
          ][i].withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }

    // Add star field
    final starPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width.toInt();
      final y = (i * 73) % size.height.toInt();
      final twinkle = sin(waveValue * 3 + i) * 0.5 + 0.5;

      starPaint.color = Colors.white.withOpacity(0.3 + twinkle * 0.7);
      canvas.drawCircle(
        Offset(x.toDouble(), y.toDouble()),
        1 + twinkle * 2,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CinematicParticlePainter extends CustomPainter {
  final List<ParticleData> particles;
  final double animationValue;
  final double intensity;

  CinematicParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Update particle position based on animation
      final animatedX =
          particle.position.dx +
          sin(animationValue * 2 * pi + particle.position.dx * 0.01) * 20;
      final animatedY =
          particle.position.dy +
          cos(animationValue * 2 * pi + particle.position.dy * 0.01) * 15;

      // Create pulsing effect
      final pulse = sin(animationValue * 4 * pi + particle.size) * 0.3 + 0.7;
      final currentSize = particle.size * pulse * intensity;

      // Create glowing effect
      paint.shader = RadialGradient(
        colors: [
          particle.color.withOpacity(particle.opacity),
          particle.color.withOpacity(particle.opacity * 0.5),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(animatedX, animatedY),
          radius: currentSize * 2,
        ),
      );

      canvas.drawCircle(Offset(animatedX, animatedY), currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FloatingElementsPainter extends CustomPainter {
  final double floatValue;
  final double glowIntensity;

  FloatingElementsPainter({
    required this.floatValue,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create floating geometric shapes
    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.1 + i * 0.12);
      final y = size.height * (0.2 + sin(floatValue * 2 + i) * 0.3);
      final shapeSize = 15 + sin(floatValue * 3 + i) * 8;

      paint.color = [Colors.cyan, Colors.purple, Colors.pink, Colors.orange][i %
          4].withOpacity(0.3 * glowIntensity);

      // Draw different shapes
      if (i % 3 == 0) {
        // Triangle
        final path = Path();
        path.moveTo(x, y - shapeSize);
        path.lineTo(x - shapeSize, y + shapeSize);
        path.lineTo(x + shapeSize, y + shapeSize);
        path.close();
        canvas.drawPath(path, paint);
      } else if (i % 3 == 1) {
        // Circle
        canvas.drawCircle(Offset(x, y), shapeSize, paint);
      } else {
        // Rectangle
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y),
              width: shapeSize * 2,
              height: shapeSize,
            ),
            const Radius.circular(5),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RippleEffectPainter extends CustomPainter {
  final List<RippleData> ripples;
  final double animationValue;

  RippleEffectPainter({required this.ripples, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    for (final ripple in ripples) {
      final currentRadius = ripple.radius + animationValue * 100;
      final currentOpacity = ripple.opacity * (1 - animationValue);

      paint.color = Colors.cyan.withOpacity(currentOpacity);
      canvas.drawCircle(ripple.position, currentRadius, paint);

      // Inner ripple
      paint.color = Colors.white.withOpacity(currentOpacity * 0.5);
      canvas.drawCircle(ripple.position, currentRadius * 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EnergyOrbsPainter extends CustomPainter {
  final double pulseValue;
  final double morphValue;

  EnergyOrbsPainter({required this.pulseValue, required this.morphValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create energy orbs in corners
    final orbs = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.1),
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.9, size.height * 0.9),
    ];

    for (int i = 0; i < orbs.length; i++) {
      final orb = orbs[i];
      final orbSize = 20 + pulseValue * 15 + sin(morphValue * 2 * pi + i) * 10;

      paint.shader = RadialGradient(
        colors: [
          [
            Colors.cyan,
            Colors.purple,
            Colors.pink,
            Colors.orange,
          ][i].withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: orb, radius: orbSize));

      canvas.drawCircle(orb, orbSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data Classes for Cinematic Effects
class ParticleData {
  final Offset position;
  final Offset velocity;
  final double size;
  final double opacity;
  final Color color;

  ParticleData({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

class RippleData {
  final Offset position;
  final double radius;
  final double opacity;

  RippleData({
    required this.position,
    required this.radius,
    required this.opacity,
  });
}

// Legacy Custom Painters (keeping for compatibility)
class DepthLayerPainter extends CustomPainter {
  final String imagePath;
  final double panAngle;
  final double tiltAngle;
  final double zoomLevel;

  DepthLayerPainter({
    required this.imagePath,
    required this.panAngle,
    required this.tiltAngle,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.6);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MidgroundPainter extends CustomPainter {
  final String imagePath;
  final double panAngle;
  final double tiltAngle;
  final double zoomLevel;

  MidgroundPainter({
    required this.imagePath,
    required this.panAngle,
    required this.tiltAngle,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.orange.withOpacity(0.4)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final rect = Rect.fromLTWH(
        size.width * 0.1 + i * size.width * 0.15,
        size.height * 0.6,
        size.width * 0.1,
        size.height * 0.3,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HotspotPainter extends CustomPainter {
  final String imagePath;
  final double panAngle;
  final double tiltAngle;
  final double zoomLevel;
  final double hotspotRadius;
  final Color hotspotColor;
  final Color hotspotBorderColor;
  final double hotspotBorderWidth;

  HotspotPainter({
    required this.imagePath,
    required this.panAngle,
    required this.tiltAngle,
    required this.zoomLevel,
    required this.hotspotRadius,
    required this.hotspotColor,
    required this.hotspotBorderColor,
    required this.hotspotBorderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hotspotPositions = [
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.3),
    ];

    for (final position in hotspotPositions) {
      final borderPaint =
          Paint()
            ..color = hotspotBorderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = hotspotBorderWidth;

      canvas.drawCircle(position, hotspotRadius * size.width, borderPaint);

      final fillPaint =
          Paint()
            ..color = hotspotColor
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        position,
        (hotspotRadius * size.width) - hotspotBorderWidth,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final String imagePath;
  final double panAngle;
  final double tiltAngle;
  final double zoomLevel;
  final int particleCount;
  final double particleSize;
  final double particleSpeed;
  final double particleOpacity;

  ParticlePainter({
    required this.imagePath,
    required this.panAngle,
    required this.tiltAngle,
    required this.zoomLevel,
    required this.particleCount,
    required this.particleSize,
    required this.particleSpeed,
    required this.particleOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(particleOpacity)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final x = (i * 37) % size.width.toInt();
      final y = (i * 73) % size.height.toInt();
      final offset = Offset(x.toDouble(), y.toDouble());

      canvas.drawCircle(offset, particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _VideoTourExperienceModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Video Tour Experience',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Guided video tours with expert commentary\n\nFeatures:\n• HD video quality\n• Multiple languages\n• Offline download\n• Interactive chapters',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGalleryExperienceModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Photo Gallery Experience',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'High-quality photo collections\n\nFeatures:\n• Professional photography\n• Multiple viewpoints\n• Day/night variations\n• Download options',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
