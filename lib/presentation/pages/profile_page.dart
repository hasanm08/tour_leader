import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:tour_leader/core/extensions/context_extension.dart';
import 'package:tour_leader/core/theme/app_theme.dart';
import 'package:tour_leader/core/theme/theme_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDarkMode),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildProfileHeader(context, theme),
                  _buildThemeSection(context, theme, isDarkMode),
                  _buildSettingsSection(context, theme),
                  _buildAboutSection(context, theme),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.black),
        onPressed: () {
          // Handle menu action
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: const SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Travel Enthusiast',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile Statistics', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, theme, '12', 'Trips'),
              _buildStatItem(context, theme, '34', 'Countries'),
              _buildStatItem(context, theme, '156', 'Photos'),
              _buildStatItem(context, theme, '4.8', 'Rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    ThemeData theme,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dark Mode', style: theme.textTheme.bodyLarge),
                      Text(
                        isDarkMode ? 'Enabled' : 'Disabled',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme();
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeData theme) {
    final settingsItems = [
      {
        'icon': Icons.notifications,
        'title': 'Notifications',
        'subtitle': 'Push notifications',
      },
      {'icon': Icons.language, 'title': 'Language', 'subtitle': 'English'},
      {
        'icon': Icons.security,
        'title': 'Privacy',
        'subtitle': 'Account security',
      },
      {
        'icon': Icons.support,
        'title': 'Help & Support',
        'subtitle': 'Get help',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          ...settingsItems.map(
            (item) => _buildSettingItem(
              context,
              theme,
              item['icon'] as IconData,
              item['title'] as String,
              item['subtitle'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildAboutItem(context, theme, Icons.info, 'Version', '1.0.0'),
          _buildAboutItem(context, theme, Icons.policy, 'Privacy Policy', ''),
          _buildAboutItem(
            context,
            theme,
            Icons.description,
            'Terms of Service',
            '',
          ),
          _buildAboutItem(context, theme, Icons.logout, 'Sign Out', ''),
        ],
      ),
    );
  }

  Widget _buildAboutItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: title == 'Sign Out' ? Colors.red : AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: title == 'Sign Out' ? Colors.red : null,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (title != 'Version' && title != 'Sign Out')
            const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
