import 'package:flutter/material.dart';

class CalculatorItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  final String gradientStart;
  final String gradientEnd;

  CalculatorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
    required this.gradientStart,
    required this.gradientEnd,
  });
}