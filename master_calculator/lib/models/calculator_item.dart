import 'package:flutter/material.dart';

class CalculatorItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  final Color? gradientStart;
  final Color? gradientEnd;
  final String? category;
  final List<String>? tags;
  final bool isPremium;
  final String? description;
  final String? version;

  CalculatorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
    this.gradientStart,
    this.gradientEnd,
    this.category,
    this.tags,
    this.isPremium = false,
    this.description,
    this.version,
  });

  // Factory method for creating a standard calculator item
  factory CalculatorItem.standard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
    String? category,
    List<String>? tags,
  }) {
    return CalculatorItem(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      page: page,
      gradientStart: color.withOpacity(0.2),
      gradientEnd: color.withOpacity(0.05),
      category: category ?? "general",
      tags: tags ?? [],
      isPremium: false,
      description: subtitle,
      version: "1.0",
    );
  }

  // Factory method for premium calculators
  factory CalculatorItem.premium({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
    String? category,
    List<String>? tags,
  }) {
    return CalculatorItem(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      page: page,
      gradientStart: Colors.amber.withOpacity(0.3),
      gradientEnd: Colors.orange.withOpacity(0.1),
      category: category ?? "premium",
      tags: tags ?? [],
      isPremium: true,
      description: "Premium Feature - $subtitle",
      version: "1.0",
    );
  }

  // Get gradient colors (returns default if not set)
  List<Color> get gradientColors {
    if (gradientStart != null && gradientEnd != null) {
      return [gradientStart!, gradientEnd!];
    }
    return [color.withOpacity(0.15), color.withOpacity(0.05)];
  }

  // Check if item matches search query
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        subtitle.toLowerCase().contains(lowerQuery) ||
        (category?.toLowerCase().contains(lowerQuery) ?? false) ||
        (tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false);
  }

  // Check if item matches category
  bool matchesCategory(String? categoryFilter) {
    if (categoryFilter == null || categoryFilter == "All") return true;
    return category == categoryFilter;
  }

  @override
  String toString() {
    return 'CalculatorItem(title: $title, category: $category, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculatorItem &&
        other.title == title &&
        other.page == page;
  }

  @override
  int get hashCode => title.hashCode ^ page.hashCode;
}

// Extension methods for list of calculator items
extension CalculatorItemListExtension on List<CalculatorItem> {
  List<CalculatorItem> filterByCategory(String? category) {
    if (category == null || category == "All") return this;
    return where((item) => item.category == category).toList();
  }

  List<CalculatorItem> filterBySearch(String query) {
    if (query.isEmpty) return this;
    return where((item) => item.matchesSearch(query)).toList();
  }

  List<CalculatorItem> get premiumItems {
    return where((item) => item.isPremium).toList();
  }

  List<CalculatorItem> get freeItems {
    return where((item) => !item.isPremium).toList();
  }

  Map<String, List<CalculatorItem>> groupByCategory() {
    final Map<String, List<CalculatorItem>> grouped = {};
    for (final item in this) {
      final category = item.category ?? "general";
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    return grouped;
  }
}

// Pre-defined calculator items for easy access
class CalculatorItems {
  static List<CalculatorItem> getAllCalculators() {
    return [
      CalculatorItem.standard(
        title: "Standard",
        subtitle: "Basic arithmetic operations",
        icon: Icons.calculate,
        color: const Color(0xFF6366F1),
        page: Container(), // Replace with actual page
        category: "basic",
        tags: ["math", "arithmetic", "basic"],
      ),
      CalculatorItem.standard(
        title: "Age",
        subtitle: "Calculate exact age in years, months, days",
        icon: Icons.cake,
        color: const Color(0xFFF59E0B),
        page: Container(), // Replace with actual page
        category: "life",
        tags: ["birthday", "years", "date"],
      ),
      CalculatorItem.standard(
        title: "EMI",
        subtitle: "Loan EMI calculator with amortization",
        icon: Icons.account_balance,
        color: const Color(0xFF10B981),
        page: Container(), // Replace with actual page
        category: "finance",
        tags: ["loan", "interest", "payment"],
      ),
      CalculatorItem.standard(
        title: "BMI",
        subtitle: "Body Mass Index with health advice",
        icon: Icons.fitness_center,
        color: const Color(0xFFEF4444),
        page: Container(), // Replace with actual page
        category: "health",
        tags: ["weight", "height", "fitness"],
      ),
      CalculatorItem.standard(
        title: "GST",
        subtitle: "Goods & Services Tax calculator",
        icon: Icons.receipt,
        color: const Color(0xFFEC4899),
        page: Container(), // Replace with actual page
        category: "finance",
        tags: ["tax", "business", "invoice"],
      ),
    ];
  }

  static List<String> getCategories() {
    return ["All", "Basic", "Finance", "Health", "Life", "Science", "Premium"];
  }

  static Map<String, IconData> getCategoryIcons() {
    return {
      "All": Icons.apps,
      "Basic": Icons.calculate,
      "Finance": Icons.account_balance,
      "Health": Icons.fitness_center,
      "Life": Icons.cake,
      "Science": Icons.science,
      "Premium": Icons.star,
    };
  }
}