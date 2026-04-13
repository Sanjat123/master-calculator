import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MasterCalculatorApp(),
    ),
  );
}

class MasterCalculatorApp extends StatelessWidget {
  const MasterCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Master Calculator',
          themeMode: themeProvider.themeMode,
          theme: themeProvider.getLightTheme(),
          darkTheme: themeProvider.getDarkTheme(),
          home: const HomePage(),
        );
      },
    );
  }
}