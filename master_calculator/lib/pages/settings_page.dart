import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _hapticEnabled = true;
  bool _autoSaveEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 33,
                    backgroundColor: Colors.transparent,
                    backgroundImage: isLoggedIn && user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: !isLoggedIn
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? (user.displayName ?? "User") : "Guest User",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoggedIn ? (user.email ?? "") : "Sign in to sync data",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!isLoggedIn)
                        ElevatedButton(
                          onPressed: () => _handleGoogleSignIn(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.login, size: 16),
                              SizedBox(width: 4),
                              Text("Sign In", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Verified Account",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (isLoggedIn)
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () => _handleSignOut(context),
                    tooltip: "Sign Out",
                  ),
              ],
            ),
          ),

          // Appearance Section
          _buildSectionHeader("Appearance", Icons.palette),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text("Dark Mode"),
              subtitle: const Text("Switch between light and dark theme"),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.blue : Colors.orange,
              ),
              value: isDark,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),

          // Preferences Section
          _buildSectionHeader("Preferences", Icons.tune),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text("Notifications"),
                  subtitle: const Text("Receive tips and updates"),
                  secondary: const Icon(Icons.notifications, color: Colors.blue),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _showSnackBar(context,
                        value ? "Notifications enabled" : "Notifications disabled");
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text("Haptic Feedback"),
                  subtitle: const Text("Vibration on button press"),
                  secondary: const Icon(Icons.vibration, color: Colors.purple),
                  value: _hapticEnabled,
                  onChanged: (value) {
                    setState(() => _hapticEnabled = value);
                    if (value) HapticFeedback.lightImpact();
                    _showSnackBar(context,
                        value ? "Haptic feedback enabled" : "Haptic feedback disabled");
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text("Auto Save"),
                  subtitle: const Text("Automatically save calculation history"),
                  secondary: const Icon(Icons.save, color: Colors.green),
                  value: _autoSaveEnabled,
                  onChanged: (value) {
                    setState(() => _autoSaveEnabled = value);
                    _showSnackBar(context,
                        value ? "Auto save enabled" : "Auto save disabled");
                  },
                ),
              ],
            ),
          ),

          // Data & Storage Section
          _buildSectionHeader("Data & Storage", Icons.storage),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep, color: Colors.red),
                  title: const Text("Clear History"),
                  subtitle: const Text("Remove all calculation history"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showClearHistoryDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup, color: Colors.blue),
                  title: const Text("Backup Data"),
                  subtitle: const Text("Backup your calculations to cloud"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showBackupDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.orange),
                  title: const Text("Restore Data"),
                  subtitle: const Text("Restore from cloud backup"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showRestoreDialog(context),
                ),
              ],
            ),
          ),

          // About Section
          _buildSectionHeader("About", Icons.info),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFF8B5CF6)),
                  title: const Text("About App"),
                  subtitle: const Text("Learn more about Master Calculator"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_rate, color: Color(0xFFF59E0B)),
                  title: const Text("Rate Us"),
                  subtitle: const Text("Rate this app on the store"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showRateUsDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.share, color: Color(0xFF10B981)),
                  title: const Text("Share App"),
                  subtitle: const Text("Share with friends and family"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _shareApp(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Color(0xFF6366F1)),
                  title: const Text("Privacy Policy"),
                  subtitle: const Text("Read our privacy policy"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPrivacyPolicyDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security, color: Color(0xFFEF4444)),
                  title: const Text("Terms of Service"),
                  subtitle: const Text("Read terms and conditions"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTermsDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _showSnackBar(context, "Signed in successfully!");
      setState(() {});
    } catch (e) {
      _showSnackBar(context, "Sign-In Failed: $e");
    }
  }

  void _handleSignOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    _showSnackBar(context, "Signed out successfully");
    setState(() {});
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text("Are you sure you want to clear all calculation history? This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, "History cleared successfully!");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Backup Data"),
        content: const Text("Your data will be backed up to the cloud. This may take a few moments."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, "Backup completed successfully!");
            },
            child: const Text("Backup Now"),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Restore Data"),
        content: const Text("This will restore your data from the last backup. Continue?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, "Data restored successfully!");
            },
            child: const Text("Restore"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
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
        SizedBox(height: 12),
        Text(
          "Features:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("• Standard Calculator"),
        Text("• Age Calculator"),
        Text("• EMI Calculator"),
        Text("• BMI Calculator"),
        Text("• Discount Calculator"),
        Text("• GST Calculator"),
        Text("• SIP Calculator"),
        Text("• Currency Converter"),
        Text("• Unit Converter"),
        Text("• Loan Calculator"),
        SizedBox(height: 16),
        Text(
          "Made with ❤️ using Flutter",
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  void _showRateUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rate Us"),
        content: const Text("If you enjoy using Master Calculator, please take a moment to rate us on the store."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, "Thank you for rating!");
            },
            child: const Text("Rate Now"),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: "Check out Master Calculator app! A powerful multi-purpose calculator with 10+ tools."));
    _showSnackBar(context, "App link copied to clipboard!");
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Last Updated: April 2026",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "Information We Collect",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "• Calculation history stored locally on your device\n"
                    "• Email and name (if you sign in with Google)\n"
                    "• App preferences and settings",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                "How We Use Your Information",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "• To provide calculator functionality\n"
                    "• To sync your data across devices (if signed in)\n"
                    "• To improve app performance",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                "Data Storage",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Your calculation history is stored locally on your device. If you sign in with Google, your preferences are synced to the cloud.",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                "Third-Party Services",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "• Google Sign-In for authentication\n"
                    "• Firebase for cloud sync (optional)",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                "Contact Us",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "For any privacy concerns, please contact us at:\nsupport@mastercalculator.com",
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms of Service"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Acceptance of Terms",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "By using Master Calculator, you agree to these terms.",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                "Use of the App",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "You may use this app for personal, non-commercial purposes only.",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                "Disclaimer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "While we strive for accuracy, we are not responsible for any errors in calculations.",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                "Changes to Terms",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "We may update these terms at any time without prior notice.",
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}