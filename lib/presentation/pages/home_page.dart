import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tour_leader/core/constants/app_constants.dart';
import 'package:tour_leader/core/extensions/context_extension.dart';
import 'package:tour_leader/core/theme/app_theme.dart';
import 'package:tour_leader/data/models/destination.dart';
import 'package:tour_leader/data/services/destination_service.dart';
import 'package:tour_leader/presentation/widgets/destination_card.dart';
import 'package:tour_leader/presentation/widgets/search_bar_widget.dart';
import 'package:tour_leader/presentation/widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final PageController _popularController = PageController(
    viewportFraction: 0.7,
  );
  final ScrollController _scrollController = ScrollController();

  int _currentCarouselIndex = 0;
  int _currentPopularIndex = 0;
  bool _showHeaderTitle = false;

  // Single animation controller for header
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation
    _headerAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showTitle = _scrollController.offset > 100;
      if (showTitle != _showHeaderTitle) {
        setState(() {
          _showHeaderTitle = showTitle;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _popularController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildOptimizedSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchSection(),
                _buildFeaturedSection(),
                _buildPopularSection(),
                _buildCategoriesSection(),
                _buildQuickActionsSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedSliverAppBar() {
    final isDarkMode = context.isDarkMode;

    return SliverAppBar(
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  isDarkMode
                      ? AppTheme.darkHeaderGradient
                      : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.9),
                          AppTheme.primaryColor.withOpacity(0.7),
                          AppTheme.secondaryColor.withOpacity(0.8),
                        ],
                      ),
            ),
          ),
        ),
        title: AnimatedOpacity(
          opacity: _showHeaderTitle ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: const Row(
            children: [
              Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'TourLeader',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      title: AnimatedOpacity(
        opacity: _showHeaderTitle ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: FadeTransition(
          opacity: _headerAnimation,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TourLeader',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Discover Amazing Places',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        _buildIconButton(icon: Icons.notifications_outlined, onPressed: () {}),
        _buildIconButton(
          icon: Icons.shopping_cart_outlined,
          onPressed: () => context.pushNamed('tours'),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SearchBarWidget(onTap: () => context.pushNamed('search')),
    );
  }

  Widget _buildFeaturedSection() {
    return FutureBuilder<List<Destination>>(
      future: DestinationService().getFeaturedDestinations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final destinations = snapshot.data!;

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                SectionHeader(
                  title: '✨ Featured Destinations',
                  subtitle: 'Handpicked for your next adventure',
                  onSeeAll: () => context.pushNamed('explore'),
                ),
                const SizedBox(height: 20),
                // Fixed height to prevent overflow
                SizedBox(
                  height: 220, // Adjusted for 16:9 aspect ratio cards
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: destinations.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCarouselIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final destination = destinations[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: RepaintBoundary(
                          child: DestinationCard(
                            destination: destination,
                            enable3D:
                                false, // Disable 3D for better performance
                            onTap:
                                () => context.pushNamed(
                                  'destination_detail',
                                  pathParameters: {'id': destination.id},
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSmoothIndicator(
                  activeIndex: _currentCarouselIndex,
                  count: destinations.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                    activeDotColor: AppTheme.primaryColor,
                    dotColor: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularSection() {
    return FutureBuilder<List<Destination>>(
      future: DestinationService().getPopularDestinations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final destinations = snapshot.data!;
        final limitedDestinations = destinations.take(5).toList();

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                SectionHeader(
                  title: '🔥 Popular Destinations',
                  subtitle: 'Top-rated by travelers worldwide',
                  onSeeAll: () => context.pushNamed('explore'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200, // Fixed height to prevent overflow
                  child: PageView.builder(
                    controller: _popularController,
                    itemCount: limitedDestinations.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPopularIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final destination = limitedDestinations[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: RepaintBoundary(
                          child: DestinationCard(
                            destination: destination,
                            enable3D:
                                false, // Disable 3D for better performance
                            compact: true,
                            onTap:
                                () => context.pushNamed(
                                  'destination_detail',
                                  pathParameters: {'id': destination.id},
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSmoothIndicator(
                  activeIndex: _currentPopularIndex,
                  count: limitedDestinations.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: AppTheme.secondaryColor,
                    dotColor: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<String>>(
      future: DestinationService().getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = snapshot.data!;
        final limitedCategories = categories.take(6).toList();

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                SectionHeader(
                  title: '📍 Categories',
                  subtitle: 'Explore by your interests',
                  onSeeAll: () => context.pushNamed('explore'),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: limitedCategories.length,
                    itemBuilder: (context, index) {
                      final category = limitedCategories[index];
                      return RepaintBoundary(
                        child: _buildCategoryCard(category, index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String category, int index) {
    const icons = [
      Icons.landscape,
      Icons.beach_access,
      Icons.temple_buddhist,
      Icons.nightlife,
      Icons.restaurant,
      Icons.shopping_bag,
    ];

    const gradients = [
      AppTheme.primaryGradient,
      AppTheme.secondaryGradient,
      AppTheme.accentGradient,
      LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF673AB7)]),
      LinearGradient(colors: [Color(0xFF795548), Color(0xFF5D4037)]),
      LinearGradient(colors: [Color(0xFF607D8B), Color(0xFF455A64)]),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: gradients[index % gradients.length],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradients[index % gradients.length].colors.first.withOpacity(
              0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.pushNamed('explore'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icons[index % icons.length],
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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

  Widget _buildQuickActionsSection() {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionHeader(
              title: '⚡ Quick Actions',
              subtitle: 'Everything you need at your fingertips',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Virtual Tours',
                    Icons.view_in_ar,
                    AppTheme.primaryGradient,
                    () => context.pushNamed('virtual_tour'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'My Tours',
                    Icons.card_travel,
                    AppTheme.secondaryGradient,
                    () => context.pushNamed('tours'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return Container(
      height: 120,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
