import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  String _selectedAccentColor = "Purple";
  bool _useDynamicColors = false;

  // Available accent colors
  final List<Map<String, dynamic>> accentColors = [
    {"name": "Purple", "color": const Color(0xFF6366F1), "darkColor": const Color(0xFF818CF8)},
    {"name": "Blue", "color": const Color(0xFF3B82F6), "darkColor": const Color(0xFF60A5FA)},
    {"name": "Green", "color": const Color(0xFF10B981), "darkColor": const Color(0xFF34D399)},
    {"name": "Red", "color": const Color(0xFFEF4444), "darkColor": const Color(0xFFF87171)},
    {"name": "Orange", "color": const Color(0xFFF59E0B), "darkColor": const Color(0xFFFBBF24)},
    {"name": "Pink", "color": const Color(0xFFEC4899), "darkColor": const Color(0xFFF472B6)},
    {"name": "Teal", "color": const Color(0xFF14B8A6), "darkColor": const Color(0xFF2DD4BF)},
    {"name": "Indigo", "color": const Color(0xFF8B5CF6), "darkColor": const Color(0xFFA78BFA)},
  ];

  String get selectedAccentColor => _selectedAccentColor;

  Color get currentAccentColor {
    final accent = accentColors.firstWhere(
          (a) => a["name"] == _selectedAccentColor,
      orElse: () => accentColors[0],
    );
    return isDarkMode ? accent["darkColor"] : accent["color"];
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get useDynamicColors => _useDynamicColors;

  void toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setAccentColor(String colorName) {
    _selectedAccentColor = colorName;
    notifyListeners();
  }

  void toggleDynamicColors() {
    _useDynamicColors = !_useDynamicColors;
    notifyListeners();
  }

  // Get custom theme based on accent color
  ThemeData getCurrentTheme() {
    return isDarkMode ? getDarkTheme() : getLightTheme();
  }

  ThemeData getLightTheme() {
    final accent = accentColors.firstWhere(
          (a) => a["name"] == _selectedAccentColor,
      orElse: () => accentColors[0],
    );
    final primaryColor = accent["color"];
    final secondaryColor = _getSecondaryColor(primaryColor);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      canvasColor: Colors.white,
      dividerColor: const Color(0xFFE2E8F0),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        error: const Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1E293B),
        onError: Colors.white,
        tertiary: const Color(0xFF8B5CF6),
        inversePrimary: const Color(0xFF6366F1),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: primaryColor),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        headlineLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        headlineMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF475569)),
        bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        bodySmall: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: primaryColor),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: StadiumBorder(side: BorderSide(color: primaryColor.withOpacity(0.5))),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  ThemeData getDarkTheme() {
    final accent = accentColors.firstWhere(
          (a) => a["name"] == _selectedAccentColor,
      orElse: () => accentColors[0],
    );
    final primaryColor = accent["darkColor"];
    final secondaryColor = _getSecondaryColor(primaryColor);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B),
      canvasColor: const Color(0xFF1E293B),
      dividerColor: const Color(0xFF334155),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color(0xFF1E293B),
        error: const Color(0xFFF87171),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        tertiary: const Color(0xFFA78BFA),
        inversePrimary: const Color(0xFF818CF8),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: primaryColor),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
        displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        headlineLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
        bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        bodySmall: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF1E293B),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.2),
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: primaryColor),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: StadiumBorder(side: BorderSide(color: primaryColor.withOpacity(0.5))),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        backgroundColor: const Color(0xFF1E293B),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  Color _getSecondaryColor(Color primary) {
    // Generate a complementary secondary color
    if (primary == const Color(0xFF6366F1)) return const Color(0xFF8B5CF6);
    if (primary == const Color(0xFF3B82F6)) return const Color(0xFF60A5FA);
    if (primary == const Color(0xFF10B981)) return const Color(0xFF34D399);
    if (primary == const Color(0xFFEF4444)) return const Color(0xFFF87171);
    if (primary == const Color(0xFFF59E0B)) return const Color(0xFFFBBF24);
    if (primary == const Color(0xFFEC4899)) return const Color(0xFFF472B6);
    if (primary == const Color(0xFF14B8A6)) return const Color(0xFF2DD4BF);
    return const Color(0xFFA78BFA);
  }
}