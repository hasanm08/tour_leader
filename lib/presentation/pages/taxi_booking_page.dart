import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tour_leader/core/extensions/context_extension.dart';
import 'package:tour_leader/core/theme/app_theme.dart';

class TaxiBookingPage extends ConsumerWidget {
  final String? destinationId;

  const TaxiBookingPage({super.key, this.destinationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Taxi Booking',
          style: TextStyle(
            color:
                isDarkMode
                    ? AppTheme.darkTextPrimaryColor
                    : AppTheme.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDarkMode
                    ? AppTheme.darkTextPrimaryColor
                    : AppTheme.textPrimaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          'Taxi Booking Page\n${destinationId != null ? 'Destination: $destinationId' : ''}',
          style: TextStyle(
            fontSize: 24,
            color:
                isDarkMode
                    ? AppTheme.darkTextPrimaryColor
                    : AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
