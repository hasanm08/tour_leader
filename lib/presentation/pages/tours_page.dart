import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:tour_leader/core/theme/app_theme.dart';
import 'package:tour_leader/data/models/destination.dart';
import 'package:tour_leader/data/models/virtual_tour.dart';
import 'package:tour_leader/data/services/destination_service.dart';
import 'package:tour_leader/presentation/widgets/destination_card.dart';
import 'package:tour_leader/presentation/widgets/section_header.dart';
import 'package:tour_leader/presentation/widgets/tour_sharing_widget.dart';

class ToursPage extends ConsumerStatefulWidget {
  const ToursPage({super.key});

  @override
  ConsumerState<ToursPage> createState() => _ToursPageState();
}

class _ToursPageState extends ConsumerState<ToursPage>
    with TickerProviderStateMixin {
  final DestinationService _destinationService = DestinationService();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentTourIndex = 0;
  final bool _showCreateTour = false;
  final TextEditingController _tourNameController = TextEditingController();

  // Mock data for tours - in a real app, this would come from a state management solution
  List<Tour> _tours = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeMockTours();
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

  void _initializeMockTours() {
    // Convert Tour objects to VirtualTour objects for sharing
    final now = DateTime.now();
    _tours = [
      Tour(
        id: '1',
        name: 'Mediterranean Adventure',
        description: 'Explore the beautiful Mediterranean coastline',
        destinations: [],
        totalPrice: 1299.99,
        duration: 7,
        createdAt: DateTime.now(),
      ),
      Tour(
        id: '2',
        name: 'Asian Cultural Journey',
        description: 'Discover ancient temples and modern cities',
        destinations: [],
        totalPrice: 1799.99,
        duration: 10,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Helper method to convert Tour to VirtualTour for sharing
  VirtualTour _convertToVirtualTour(Tour tour) {
    final now = DateTime.now();
    return VirtualTour(
      id: tour.id,
      name: tour.name,
      description: tour.description,
      userId: 'current_user_id', // Replace with actual user ID
      destinations: tour.destinations,
      totalPrice: tour.totalPrice,
      currency: 'USD',
      duration: tour.duration,
      startDate: now.add(const Duration(days: 30)),
      endDate: now.add(Duration(days: 30 + tour.duration)),
      currentParticipants: 1,
      minParticipants: 20,
      maxParticipants: 50,
      createdAt: tour.createdAt,
      updatedAt: now,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _tourNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                    child: AnimationLimiter(
                      child: Column(
                        children: [
                          _buildToursOverview(),
                          _buildActiveToursSection(),
                          _buildPlannedToursSection(),
                          _buildQuickActionsSection(),
                          const SizedBox(height: 100),
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
      floatingActionButton: _buildCreateTourFAB(),
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
                Icons.card_travel,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'My Tours',
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
            // Filter tours
          },
          icon: const Icon(Icons.filter_list, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            // Search tours
          },
          icon: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildToursOverview() {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    icon: Icons.tour,
                    title: 'Active Tours',
                    value: '${_tours.length}',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatsCard(
                    icon: Icons.place,
                    title: 'Destinations',
                    value:
                        '${_tours.fold(0, (sum, tour) => sum + tour.destinations.length)}',
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatsCard(
                    icon: Icons.attach_money,
                    title: 'Total Cost',
                    value:
                        '\$${_tours.fold(0.0, (sum, tour) => sum + tour.totalPrice).toStringAsFixed(0)}',
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToursSection() {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                SectionHeader(
                  title: '🎯 Active Tours',
                  subtitle: 'Your current travel plans',
                  onSeeAll: () {
                    // View all tours
                  },
                ),
                const SizedBox(height: 16),
                if (_tours.isNotEmpty) ...[
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _tours.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentTourIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final tour = _tours[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildTourCard(tour),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _tours.length,
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
                ] else ...[
                  _buildEmptyState(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTourCard(Tour tour) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppTheme.primaryColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.card_travel,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.name,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tour.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Share button
                IconButton(
                  onPressed: () {
                    final virtualTour = _convertToVirtualTour(tour);
                    TourSharingWidget.show(context, virtualTour);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTourInfoChip(
                  icon: Icons.schedule,
                  label: '${tour.duration} days',
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 8),
                _buildTourInfoChip(
                  icon: Icons.place,
                  label: '${tour.destinations.length} places',
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(width: 8),
                _buildTourInfoChip(
                  icon: Icons.people,
                  label: '19 needed',
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Participants progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const Text(
                      '1 / 20',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 1 / 20,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  minHeight: 4,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewTourDetails(tour),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
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
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final virtualTour = _convertToVirtualTour(tour);
                      TourSharingWidget.show(context, virtualTour);
                    },
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_travel,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Tours Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first tour by exploring destinations and adding them to your itinerary.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed('main'),
            icon: const Icon(Icons.explore),
            label: const Text('Explore Destinations'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannedToursSection() {
    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                SectionHeader(
                  title: '📅 Planned Tours',
                  subtitle: 'Upcoming adventures',
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Destination>>(
                  future: _destinationService.getFeaturedDestinations(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height:
                            158, // Adjusted for 16:9 aspect ratio cards (280 * 9/16 = 158)
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final destination = snapshot.data![index];
                            return Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 12),
                              child: DestinationCard(
                                destination: destination,
                                compact: true,
                                width: 280,
                                height:
                                    280 * 9 / 16, // Maintain 16:9 aspect ratio
                                onTap:
                                    () => context.pushNamed(
                                      'destination_detail',
                                      pathParameters: {'id': destination.id},
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox(
                      height: 158,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return AnimationConfiguration.staggeredList(
      position: 3,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                SectionHeader(
                  title: '⚡ Quick Actions',
                  subtitle: 'Manage your tours',
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    _buildQuickActionCard(
                      icon: Icons.explore,
                      title: 'Explore Destinations',
                      subtitle: 'Find new places',
                      gradient: AppTheme.primaryGradient,
                      onTap: () => context.pushNamed('main'),
                    ),
                    _buildQuickActionCard(
                      icon: Icons.hotel,
                      title: 'Book Hotels',
                      subtitle: 'Find accommodation',
                      gradient: AppTheme.secondaryGradient,
                      onTap: () => context.pushNamed('hotel_booking'),
                    ),
                    _buildQuickActionCard(
                      icon: Icons.local_taxi,
                      title: 'Book Transport',
                      subtitle: 'Arrange travel',
                      gradient: AppTheme.accentGradient,
                      onTap: () => context.pushNamed('taxi_booking'),
                    ),
                    _buildQuickActionCard(
                      icon: Icons.view_in_ar,
                      title: 'Virtual Tours',
                      subtitle: 'Preview destinations',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                      ),
                      onTap: () => context.pushNamed('virtual_tour'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
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
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTourFAB() {
    return FloatingActionButton.extended(
      onPressed: _showCreateTourDialog,
      backgroundColor: AppTheme.primaryColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Create Tour',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCreateTourDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Tour'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tourNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tour Name',
                    hintText: 'Enter tour name',
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your tour',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_tourNameController.text.isNotEmpty) {
                    _createNewTour(_tourNameController.text);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _createNewTour(String name) {
    final newTour = Tour(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: 'Custom tour created by user',
      destinations: [],
      totalPrice: 0,
      duration: 0,
      createdAt: DateTime.now(),
    );

    setState(() {
      _tours.add(newTour);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tour "$name" created successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    _tourNameController.clear();
  }

  void _viewTourDetails(Tour tour) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
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
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            tour.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tour.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondaryColor),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildTourInfoChip(
                                icon: Icons.schedule,
                                label: '${tour.duration} days',
                                color: AppTheme.accentColor,
                              ),
                              const SizedBox(width: 8),
                              _buildTourInfoChip(
                                icon: Icons.place,
                                label: '${tour.destinations.length} places',
                                color: AppTheme.secondaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (tour.destinations.isEmpty) ...[
                            const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No destinations added yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'Destinations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...tour.destinations.map(
                              (destination) => ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.place),
                                ),
                                title: Text(destination.name),
                                subtitle: Text(
                                  '${destination.city}, ${destination.country}',
                                ),
                                trailing: Text(
                                  '\$${destination.price.toStringAsFixed(0)}',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

class Tour {
  final String id;
  final String name;
  final String description;
  final List<Destination> destinations;
  final double totalPrice;
  final int duration;
  final DateTime createdAt;

  Tour({
    required this.id,
    required this.name,
    required this.description,
    required this.destinations,
    required this.totalPrice,
    required this.duration,
    required this.createdAt,
  });
}
