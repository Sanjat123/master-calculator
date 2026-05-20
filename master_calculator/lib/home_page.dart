import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'theme_provider.dart';
import 'models/calculator_item.dart';

// Importing all required calculator screens
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
import 'calculators/bhumi_calculator.dart';

// Import additional pages
import 'pages/history_page.dart';
import 'pages/saved_page.dart';
import 'pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _language = "English";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Language translations with all calculator titles
  Map<String, Map<String, String>> _translations = {
    "English": {
      "hello": "Hello",
      "guest": "Guest",
      "welcomeBack": "Welcome back!",
      "signInPrompt": "Sign in to save progress",
      "cloudSync": "Cloud Sync",
      "syncMessage": "Syncing data to your account...",
      "signInMessage": "Sign in to keep your results safe.",
      "quickTools": "Quick Tools",
      "home": "Home",
      "history": "History",
      "saved": "Saved",
      "settings": "Settings",
      "tools": "TOOLS",
      "signOut": "Sign Out",
      "signIn": "Sign In with Google",
      "guestMode": "Guest Mode",
      "signInForCloud": "Sign in for cloud features",
      "viewHistory": "View History",
      "logOut": "Log Out",
      "profile": "Profile",
      "language": "Language",
      "english": "English",
      "hindi": "Hindi",
      "darkMode": "Dark Mode",
      "lightMode": "Light Mode",
      "about": "About",
      "rateUs": "Rate Us",
      "share": "Share App",
      "privacy": "Privacy Policy",
      "version": "Version 1.0.0",
      "standard": "Standard",
      "age": "Age",
      "emi": "EMI",
      "bmi": "BMI",
      "gst": "GST",
      "sip": "SIP",
      "currency": "Currency",
      "unit": "Unit",
      "discount": "Discount",
      "loan": "Loan",
      "standardSub": "Arithmetic",
      "Bhumi Calculator": "Bhumi Calculator",
      "BhumiSub": "Land Measurement",
      "ageSub": "Exact Birthday",
      "emiSub": "Loan Planner",
      "bmiSub": "Fitness Index",
      "gstSub": "Tax Breakdown",
      "sipSub": "Invest Returns",
      "currencySub": "Live Rates",
      "unitSub": "Conversions",
      "discountSub": "Sale Savings",
      "loanSub": "Simple Interest",
    },
    "Hindi": {
      "hello": "नमस्ते",
      "guest": "अतिथि",
      "welcomeBack": "वापसी पर स्वागत है!",
      "signInPrompt": "प्रगति सहेजने के लिए साइन इन करें",
      "cloudSync": "क्लाउड सिंक",
      "syncMessage": "आपके खाते में डेटा सिंक हो रहा है...",
      "signInMessage": "अपने परिणाम सुरक्षित रखने के लिए साइन इन करें।",
      "quickTools": "त्वरित उपकरण",
      "home": "होम",
      "history": "इतिहास",
      "saved": "सहेजे गए",
      "settings": "सेटिंग्स",
      "tools": "उपकरण",
      "signOut": "साइन आउट",
      "signIn": "Google से साइन इन करें",
      "guestMode": "अतिथि मोड",
      "signInForCloud": "क्लाउड सुविधाओं के लिए साइन इन करें",
      "viewHistory": "इतिहास देखें",
      "logOut": "लॉग आउट",
      "profile": "प्रोफ़ाइल",
      "language": "भाषा",
      "english": "अंग्रेजी",
      "hindi": "हिंदी",
      "darkMode": "डार्क मोड",
      "lightMode": "लाइट मोड",
      "about": "के बारे में",
      "rateUs": "रेट करें",
      "share": "ऐप साझा करें",
      "privacy": "गोपनीयता नीति",
      "version": "संस्करण 1.0.0",
      "standard": "मानक",
      "age": "आयु",
      "emi": "ईएमआई",
      "bmi": "बीएमआई",
      "gst": "जीएसटी",
      "sip": "एसआईपी",
      "currency": "मुद्रा",
      "unit": "इकाई",
      "discount": "छूट",
      "loan": "ऋण",
      "standardSub": "अंकगणित",
      "Bhumi Calculator": "भूमि कैलकुलेटर",
      "BhumiSub": "जमीन की माप",
      "ageSub": "सटीक जन्मदिन",
      "emiSub": "ऋण योजनाकार",
      "bmiSub": "फिटनेस सूचकांक",
      "gstSub": "कर विवरण",
      "sipSub": "निवेश रिटर्न",
      "currencySub": "लाइव दरें",
      "unitSub": "रूपांतरण",
      "discountSub": "बिक्री बचत",
      "loanSub": "साधारण ब्याज",
    },
  };

  String getText(String key) {

    return _translations[_language]?[key] ??
        _translations["English"]?[key] ??
        key;
  }

  void toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
    HapticFeedback.lightImpact();
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
    super.dispose();
  }

  // --- Authentication: Google Sign-In Logic ---
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      HapticFeedback.heavyImpact();
      _showSnackBar("Signed in successfully!");
    } catch (e) {
      debugPrint("Authentication Error: $e");
      _showSnackBar("Sign-In Failed: $e");
    }
  }

  // --- Authentication: Sign-Out Logic ---
  Future<void> _handleSignOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    HapticFeedback.mediumImpact();
    _showSnackBar("Signed out successfully");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
    );
  }

  // Navigation methods
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  void _navigateToSaved() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedPage()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = snapshot.data;
        final bool isLoggedIn = user != null;

        // List of all calculators with proper titles
        final List<CalculatorItem> items = [
          CalculatorItem(
            title: getText("standard"),
            subtitle: getText("standardSub"),
            icon: Icons.calculate,
            color: Colors.blue,
            page: const StandardCalculator(),
          ),

          CalculatorItem(
            title: getText("Bhumi Calculator"),
            subtitle: getText("BhumiSub"),
            icon: Icons.agriculture_rounded,
            color: Colors.green,
            page: const BhumiCalculator(),
          ),

          CalculatorItem(
            title: getText("age"),
            subtitle: getText("ageSub"),
            icon: Icons.cake,
            color: Colors.orange,
            page: const AgeCalculator(),
          ),
          CalculatorItem(
            title: getText("emi"),
            subtitle: getText("emiSub"),
            icon: Icons.account_balance,
            color: Colors.green,
            page: const EMICalculator(),
          ),
          CalculatorItem(
            title: getText("bmi"),
            subtitle: getText("bmiSub"),
            icon: Icons.fitness_center,
            color: Colors.red,
            page: const BMICalculator(),
          ),
          CalculatorItem(
            title: getText("gst"),
            subtitle: getText("gstSub"),
            icon: Icons.receipt,
            color: Colors.pink,
            page: const GSTCalculator(),
          ),
          CalculatorItem(
            title: getText("sip"),
            subtitle: getText("sipSub"),
            icon: Icons.trending_up,
            color: Colors.teal,
            page: const SIPCalculator(),
          ),
          CalculatorItem(
            title: getText("currency"),
            subtitle: getText("currencySub"),
            icon: Icons.currency_exchange,
            color: Colors.deepOrange,
            page: const CurrencyConverter(),
          ),
          CalculatorItem(
            title: getText("unit"),
            subtitle: getText("unitSub"),
            icon: Icons.straighten,
            color: Colors.indigo,
            page: const UnitConverter(),
          ),
          CalculatorItem(
            title: getText("discount"),
            subtitle: getText("discountSub"),
            icon: Icons.local_offer,
            color: Colors.cyan,
            page: const DiscountCalculator(),
          ),
          CalculatorItem(
            title: getText("loan"),
            subtitle: getText("loanSub"),
            icon: Icons.money,
            color: Colors.purple,
            page: const LoanCalculator(),
          ),
        ];

        return Scaffold(
          key: _scaffoldKey,
          drawer: _buildAppDrawer(user, isLoggedIn, items, themeProvider),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: "Menu",
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.transparent,
                    backgroundImage: isLoggedIn && user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: !isLoggedIn
                        ? const Icon(Icons.person_outline, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${getText("hello")}, ${isLoggedIn ? (user.displayName?.split(' ')[0] ?? getText("guest")) : getText("guest")}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            isLoggedIn ? Icons.check_circle : Icons.info_outline,
                            size: 12,
                            color: isLoggedIn ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLoggedIn ? getText("welcomeBack") : getText("signInPrompt"),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: toggleLanguage,
                tooltip: getText("language"),
              ),
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeProvider.toggleTheme(!isDark),
              ),
              GestureDetector(
                onTap: isLoggedIn ? () => _showProfileModal(context, user) : _handleGoogleSignIn,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    backgroundImage: isLoggedIn && user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: !isLoggedIn
                        ? const Icon(Icons.account_circle, size: 22, color: Colors.blue)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          body: _getBody(_selectedIndex, isDark, items, isLoggedIn, user),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _getBody(int index, bool isDark, List<CalculatorItem> items, bool isLoggedIn, User? user) {
    switch (index) {
      case 0:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                _buildQuickBanner(isLoggedIn),
                const SizedBox(height: 25),
                Text(getText("quickTools"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildCalculatorCard(items[index], isDark),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      case 1:
        return const HistoryPage();
      case 2:
        return const SavedPage();
      case 3:
        return const SettingsPage();
      default:
        return Container();
    }
  }

  Widget _buildQuickBanner(bool loggedIn) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 45),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getText("cloudSync"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(
                  loggedIn ? getText("syncMessage") : getText("signInMessage"),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard(CalculatorItem item, bool isDark) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(context, MaterialPageRoute(builder: (context) => item.page));
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: item.color.withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: item.color.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 40, color: item.color),
              const SizedBox(height: 12),
              Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item.subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(User? user, bool loggedIn, List<CalculatorItem> items, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 35,
                backgroundImage: loggedIn && user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: !loggedIn ? const Icon(Icons.person_outline, size: 40, color: Color(0xFF6366F1)) : null,
              ),
              accountName: Text(
                loggedIn ? (user?.displayName ?? getText("guest")) : getText("guestMode"),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
              accountEmail: Text(
                loggedIn ? (user?.email ?? "") : getText("signInForCloud"),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                  child: Text("CALCULATORS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ...items.map((item) => ListTile(
                  leading: Icon(item.icon, color: item.color, size: 22),
                  title: Text(item.title),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => item.page));
                  },
                )),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                  child: Text("GENERAL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Color(0xFF6366F1)),
                  title: const Text("History"),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToHistory();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star, color: Color(0xFFF59E0B)),
                  title: const Text("Saved"),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToSaved();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFF10B981)),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToSettings();
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                  child: Text("PREFERENCES", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.blue),
                  title: const Text("Language"),
                  trailing: DropdownButton<String>(
                    value: _language,
                    items: const [
                      DropdownMenuItem(value: "English", child: Text("English")),
                      DropdownMenuItem(value: "Hindi", child: Text("हिंदी")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _language = value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
        /*        ListTile(
                  leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: Text(isDark ? getText("darkMode") : getText("lightMode")),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) => themeProvider.toggleTheme(value),
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                  child: Text("ABOUT", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFF8B5CF6)),
                  title: const Text("About"),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_rate, color: Color(0xFFF59E0B)),
                  title: const Text("Rate Us"),
                  onTap: () {
                    Navigator.pop(context);
                    _showRateUsDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Color(0xFF10B981)),
                  title: const Text("Share App"),
                  onTap: () {
                    Navigator.pop(context);
                    _shareApp();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Color(0xFF6366F1)),
                  title: const Text("Privacy Policy"),
                  onTap: () {
                    Navigator.pop(context);
                    _showPrivacyPolicy();
                  },
                ),   */
                const Divider(),
                ListTile(
                  leading: Icon(loggedIn ? Icons.logout : Icons.login, color: Colors.red),
                  title: Text(loggedIn ? getText("signOut") : getText("signIn")),
                  onTap: () {
                    Navigator.pop(context);
                    loggedIn ? _handleSignOut() : _handleGoogleSignIn();
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    getText("version"),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileModal(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null ? const Icon(Icons.person, size: 45) : null,
            ),
            const SizedBox(height: 15),
            Text(user.displayName ?? getText("guest"), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.email ?? "", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text(getText("viewHistory")),
              onTap: () {
                Navigator.pop(context);
                _navigateToHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(getText("saved")),
              onTap: () {
                Navigator.pop(context);
                _navigateToSaved();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(getText("logOut")),
              onTap: () {
                Navigator.pop(context);
                _handleSignOut();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Master Calculator",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(Icons.calculate, size: 40),
      children: const [
        SizedBox(height: 16),
        Text(
          "A professional multi-purpose calculator application with 10+ powerful calculators.",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          "Made with ❤️ using Flutter",
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  void _showRateUsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rate Us"),
        content: const Text("If you enjoy using Master Calculator, please take a moment to rate us on the store."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar("Thank you for rating!");
            },
            child: const Text("Rate Now"),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Clipboard.setData(const ClipboardData(text: "Check out Master Calculator app!"));
    _showSnackBar("App link copied to clipboard!");
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Text(
            "We value your privacy. This app does not collect any personal information.\n\n"
                "Data Storage: All calculations are stored locally on your device.\n\n"
                "Third-Party Services: We use Google Sign-In for authentication.\n\n"
                "Contact: For any privacy concerns, please contact us.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6366F1),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: "Saved"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}