import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'widgets/calculator_card.dart';
import 'calculators/standard_calculator.dart';
import 'calculators/age_calculator.dart';
import 'calculators/emi_calculator.dart';
import 'calculators/bmi_calculator.dart';
import 'calculators/loan_calculator.dart';
import 'calculators/discount_calculator.dart';
import 'calculators/gst_calculator.dart';
import 'calculators/sip_calculator.dart';
import 'calculators/currency_converter.dart';
import 'calculators/unit_converter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String _searchQuery = "";
  int _selectedCategory = -1;
  int _selectedNavIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isSearchActive = false;

  final List<Map<String, dynamic>> _allCalculators = [
    {'title': 'Standard', 'subtitle': 'Basic arithmetic operations', 'icon': Icons.calculate, 'color': const Color(0xFF6366F1), 'page': const StandardCalculator(), 'category': 'basic', 'tags': ['math', 'arithmetic', 'basic']},
    {'title': 'Age', 'subtitle': 'Calculate exact age in years, months, days', 'icon': Icons.cake, 'color': const Color(0xFFF59E0B), 'page': const AgeCalculator(), 'category': 'life', 'tags': ['birthday', 'years', 'date']},
    {'title': 'EMI', 'subtitle': 'Loan EMI calculator with amortization', 'icon': Icons.account_balance, 'color': const Color(0xFF10B981), 'page': const EMICalculator(), 'category': 'finance', 'tags': ['loan', 'interest', 'payment']},
    {'title': 'BMI', 'subtitle': 'Body Mass Index with health advice', 'icon': Icons.fitness_center, 'color': const Color(0xFFEF4444), 'page': const BMICalculator(), 'category': 'health', 'tags': ['weight', 'height', 'fitness']},
    {'title': 'Loan', 'subtitle': 'Simple loan interest calculator', 'icon': Icons.currency_rupee, 'color': const Color(0xFF8B5CF6), 'page': const LoanCalculator(), 'category': 'finance', 'tags': ['interest', 'borrow', 'money']},
    {'title': 'Discount', 'subtitle': 'Calculate savings and final price', 'icon': Icons.local_offer, 'color': const Color(0xFF06B6D4), 'page': const DiscountCalculator(), 'category': 'finance', 'tags': ['sale', 'save', 'percentage']},
    {'title': 'GST', 'subtitle': 'Goods & Services Tax calculator', 'icon': Icons.receipt, 'color': const Color(0xFFEC4899), 'page': const GSTCalculator(), 'category': 'finance', 'tags': ['tax', 'business', 'invoice']},
    {'title': 'SIP', 'subtitle': 'Mutual fund investment returns', 'icon': Icons.trending_up, 'color': const Color(0xFF14B8A6), 'page': const SIPCalculator(), 'category': 'finance', 'tags': ['investment', 'mutual fund', 'returns']},
    {'title': 'Currency', 'subtitle': 'Live exchange rate converter', 'icon': Icons.currency_exchange, 'color': const Color(0xFFF97316), 'page': const CurrencyConverter(), 'category': 'finance', 'tags': ['money', 'exchange', 'forex']},
    {'title': 'Unit', 'subtitle': 'Convert between different units', 'icon': Icons.straighten, 'color': const Color(0xFF6366F1), 'page': const UnitConverter(), 'category': 'science', 'tags': ['measurement', 'length', 'weight']},
  ];

  List<Map<String, dynamic>> get _filteredCalculators {
    List<Map<String, dynamic>> filtered = _allCalculators;

    // Filter by category
    if (_selectedCategory != -1) {
      String category = "";
      switch (_selectedCategory) {
        case 0:
          category = "basic";
          break;
        case 1:
          category = "finance";
          break;
        case 2:
          category = "health";
          break;
        case 3:
          category = "life";
          break;
        case 4:
          category = "science";
          break;
      }
      filtered = filtered.where((calc) => calc['category'] == category).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((calc) {
        return calc['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            calc['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (calc['tags'] as List).any((tag) => tag.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = animation.drive(CurveTween(curve: Curves.easeIn));
          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final accentColor = themeProvider.currentAccentColor;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Enhanced Animated App Bar with Better Height
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              snap: false,
              stretch: true,
              onStretchTrigger: () async {},
              stretchTriggerOffset: 50,
              flexibleSpace: FlexibleSpaceBar(
                title: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _searchQuery.isNotEmpty
                      ? Text(
                    '${_filteredCalculators.length} Results',
                    key: const ValueKey('results'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )
                      : const Text(
                    'Master Calculator',
                    key: ValueKey('title'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                          : [accentColor, const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          transform: Matrix4.identity()..scale(_searchQuery.isEmpty ? 1.0 : 0.8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.calculate,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '10+ Powerful Calculators',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // Search Button
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _searchQuery.isNotEmpty ? Icons.close : Icons.search,
                      key: ValueKey(_searchQuery.isNotEmpty),
                    ),
                  ),
                  onPressed: () {
                    if (_searchQuery.isNotEmpty) {
                      setState(() => _searchQuery = "");
                    } else {
                      _showSearchDialog();
                    }
                  },
                  tooltip: "Search",
                ),
                // Theme Toggle Button
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey(isDark),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    themeProvider.toggleTheme(!isDark);
                  },
                  tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                ),
                // Settings Button
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _showSettingsDialog(context, themeProvider);
                  },
                  tooltip: "Settings",
                ),
              ],
            ),

            // Search Bar (when active)
            if (_searchQuery.isNotEmpty)
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: "Search calculators...",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => setState(() => _searchQuery = ""),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Category Tabs - Improved Design
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryHeaderDelegate(
                child: Container(
                  height: 55,
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _getCategories().length,
                    itemBuilder: (context, index) {
                      final category = _getCategories()[index];
                      final isSelected = _selectedCategory == category['index'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Row(
                            children: [
                              Icon(category['icon'], size: 16, color: isSelected ? accentColor : null),
                              const SizedBox(width: 6),
                              Text(category['name']),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category['index'] : -1;
                              _searchQuery = "";
                            });
                          },
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          selectedColor: accentColor.withOpacity(0.15),
                          checkmarkColor: accentColor,
                          labelStyle: TextStyle(
                            color: isSelected ? accentColor : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected ? accentColor : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Results Count
            if (_searchQuery.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Found ${_filteredCalculators.length} calculators",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

            // Calculator Grid - Improved Spacing
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _filteredCalculators.isEmpty
                  ? SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No calculators found",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Try searching with different keywords",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final calculator = _filteredCalculators[index];
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: CalculatorCard(
                        title: calculator['title'],
                        subtitle: calculator['subtitle'],
                        icon: calculator['icon'],
                        color: calculator['color'],
                        onTap: () => _navigateTo(context, calculator['page']),
                      ),
                    );
                  },
                  childCount: _filteredCalculators.length,
                ),
              ),
            ),

            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar - Enhanced
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedNavIndex,
            onTap: (index) {
              setState(() => _selectedNavIndex = index);
              if (index == 2) {
                _scrollToTop();
              } else if (index == 1) {
                _showCategoriesDialog();
              } else if (index == 3) {
                _showAboutDialog();
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            selectedItemColor: accentColor,
            unselectedItemColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.arrow_upward),
                label: 'Top',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: 'About',
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCategories() {
    return [
      {'name': 'All', 'icon': Icons.apps, 'index': -1},
      {'name': 'Basic', 'icon': Icons.calculate, 'index': 0},
      {'name': 'Finance', 'icon': Icons.account_balance, 'index': 1},
      {'name': 'Health', 'icon': Icons.fitness_center, 'index': 2},
      {'name': 'Life', 'icon': Icons.cake, 'index': 3},
      {'name': 'Science', 'icon': Icons.science, 'index': 4},
    ];
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSearch = "";
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Search Calculators",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  onChanged: (value) => tempSearch = value,
                  decoration: InputDecoration(
                    hintText: "Type to search...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _searchQuery = tempSearch);
                          Navigator.pop(context);
                        },
                        child: const Text("Search"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Settings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text("Accent Color"),
                subtitle: Text("Current: ${themeProvider.selectedAccentColor}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showColorPickerDialog(context, themeProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showColorPickerDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Accent Color"),
          content: Container(
            width: double.maxFinite,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: themeProvider.accentColors.map((accent) {
                final isSelected = themeProvider.selectedAccentColor == accent["name"];
                return GestureDetector(
                  onTap: () {
                    themeProvider.setAccentColor(accent["name"]);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: accent["color"],
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: accent["color"].withOpacity(0.5),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accent["name"],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showCategoriesDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._getCategories().map((category) {
                final isSelected = _selectedCategory == category['index'];
                return ListTile(
                  leading: Icon(category['icon']),
                  title: Text(category['name']),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = isSelected ? -1 : category['index'];
                      _searchQuery = "";
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Master Calculator",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(Icons.calculate, size: 40),
      children: [
        const SizedBox(height: 16),
        const Text(
          "A professional multi-purpose calculator application with 10+ powerful calculators.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Features:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text("• Standard Calculator"),
        const Text("• Age Calculator"),
        const Text("• EMI Calculator"),
        const Text("• BMI Calculator"),
        const Text("• Discount Calculator"),
        const Text("• GST Calculator"),
        const Text("• SIP Calculator"),
        const Text("• Currency Converter"),
        const Text("• Unit Converter"),
        const Text("• Loan Calculator"),
        const SizedBox(height: 16),
        const Text(
          "Made with ❤️ us With You",
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// Custom SliverPersistentHeaderDelegate for Category Header
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _CategoryHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 55;

  @override
  double get minExtent => 55;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}