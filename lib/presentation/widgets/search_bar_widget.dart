import 'package:flutter/material.dart';
import 'package:tour_leader/core/constants/app_constants.dart';
import 'package:tour_leader/core/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final bool readOnly;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Where do you want to go?',
    this.onTap,
    this.onChanged,
    this.readOnly = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: IconButton(
            onPressed: () {
              // Add filter functionality
            },
            icon: const Icon(Icons.tune, color: AppTheme.textSecondaryColor),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding,
          ),
        ),
      ),
    );
  }
}
