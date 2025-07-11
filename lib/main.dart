import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tour_leader/core/theme/app_theme.dart';
import 'package:tour_leader/core/theme/theme_provider.dart';
import 'package:tour_leader/data/services/deep_link_service.dart';
import 'package:tour_leader/data/services/destination_service.dart';
import 'package:tour_leader/presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await DestinationService().initialize();
  await DeepLinkService().initialize();

  // Set system UI overlay style for dark theme by default
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E1E1E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TourLeaderApp());
}

class TourLeaderApp extends StatelessWidget {
  const TourLeaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.select<ThemeProvider, ThemeProvider>(
      (provider) => provider,
    );
    final router = AppRouter.router;

    // Update system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        systemNavigationBarIconBrightness:
            themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'TourLeader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              1.0,
            ), // Prevent text scaling for consistent UI
          ),
          child: child!,
        );
      },
    );
  }
}
