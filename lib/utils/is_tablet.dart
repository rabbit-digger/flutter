import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  bool get isTablet => MediaQuery.of(this).size.shortestSide > 600;

  bool get isPhone => MediaQuery.of(this).size.shortestSide < 600;
}
