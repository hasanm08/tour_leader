import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tour_leader/presentation/pages/chat_page.dart';
import 'package:tour_leader/presentation/pages/destination_detail_page.dart';
import 'package:tour_leader/presentation/pages/hotel_booking_page.dart';
import 'package:tour_leader/presentation/pages/main_page.dart';
import 'package:tour_leader/presentation/pages/profile_page.dart';
import 'package:tour_leader/presentation/pages/search_page.dart';
import 'package:tour_leader/presentation/pages/taxi_booking_page.dart';
import 'package:tour_leader/presentation/pages/tours_page.dart';
import 'package:tour_leader/presentation/pages/virtual_tour_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: '/destination/:id',
        name: 'destination_detail',
        builder: (context, state) {
          final destinationId = state.pathParameters['id']!;
          return DestinationDetailPage(destinationId: destinationId);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/tours',
        name: 'tours',
        builder: (context, state) => const ToursPage(),
      ),
      GoRoute(
        path: '/virtual-tour',
        name: 'virtual_tour',
        builder: (context, state) => const VirtualTourPage(),
      ),
      GoRoute(
        path: '/hotel-booking',
        name: 'hotel_booking',
        builder: (context, state) {
          final destinationId = state.uri.queryParameters['destinationId'];
          return HotelBookingPage(destinationId: destinationId);
        },
      ),
      GoRoute(
        path: '/taxi-booking',
        name: 'taxi_booking',
        builder: (context, state) {
          final destinationId = state.uri.queryParameters['destinationId'];
          return TaxiBookingPage(destinationId: destinationId);
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => ChatPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'The page you are looking for does not exist.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );
});
