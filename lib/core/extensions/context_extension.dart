import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => colorScheme.brightness == Brightness.dark;
  bool get isLightMode => colorScheme.brightness == Brightness.light;
}
