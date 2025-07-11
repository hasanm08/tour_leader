import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tour_leader/core/extensions/context_extension.dart';
import 'package:tour_leader/core/theme/app_theme.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Destinations',
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
          'Search Page',
          style: TextStyle(
            fontSize: 24,
            color:
                isDarkMode
                    ? AppTheme.darkTextPrimaryColor
                    : AppTheme.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}
