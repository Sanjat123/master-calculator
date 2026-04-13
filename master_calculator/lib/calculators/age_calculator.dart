import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../widgets/gradient_button.dart';

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  State<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  String _result = "Select your birth date";
  Map<String, dynamic> _ageDetails = {};
  String _language = "English"; // English or Hindi
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Language-specific texts
  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "Age Calculator",
      "selectDate": "Select your birth date",
      "years": "Years",
      "months": "Months",
      "days": "Days",
      "totalDays": "Total Days",
      "totalMonths": "Total Months",
      "nextBirthday": "Next Birthday",
      "daysRemaining": "days remaining",
      "selectBirthDate": "Select Birth Date",
      "recalculate": "Recalculate Age",
      "selectedDate": "Selected Date",
      "weeks": "Weeks",
      "hours": "Hours",
      "minutes": "Minutes",
      "seconds": "Seconds",
      "zodiac": "Zodiac Sign",
      "birthstone": "Birthstone",
      "generation": "Generation",
      "lifeExpectancy": "Life Expectancy",
      "percentageLived": "Percentage of Life Lived",
      "dayOfWeek": "Day of Week",
      "daysUntilNext": "Days until next birthday",
      "share": "Share Age",
      "copy": "Copy Age",
      "language": "Language",
      "english": "English",
      "hindi": "Hindi",
      "ageDetails": "Age Details",
      "additionalInfo": "Additional Information",
    },
    "Hindi": {
      "title": "आयु कैलकुलेटर",
      "selectDate": "अपनी जन्म तिथि चुनें",
      "years": "साल",
      "months": "महीने",
      "days": "दिन",
      "totalDays": "कुल दिन",
      "totalMonths": "कुल महीने",
      "nextBirthday": "अगला जन्मदिन",
      "daysRemaining": "दिन शेष",
      "selectBirthDate": "जन्म तिथि चुनें",
      "recalculate": "आयु पुनः गणना करें",
      "selectedDate": "चयनित तिथि",
      "weeks": "सप्ताह",
      "hours": "घंटे",
      "minutes": "मिनट",
      "seconds": "सेकंड",
      "zodiac": "राशि चिन्ह",
      "birthstone": "जन्म रत्न",
      "generation": "पीढ़ी",
      "lifeExpectancy": "जीवन प्रत्याशा",
      "percentageLived": "जीवन का प्रतिशत",
      "dayOfWeek": "सप्ताह का दिन",
      "daysUntilNext": "अगले जन्मदिन तक दिन",
      "share": "आयु साझा करें",
      "copy": "आयु कॉपी करें",
      "language": "भाषा",
      "english": "अंग्रेजी",
      "hindi": "हिंदी",
      "ageDetails": "आयु विवरण",
      "additionalInfo": "अतिरिक्त जानकारी",
    },
  };

  String getText(String key) {
    return _translations[_language]?[key] ?? _translations["English"]![key]!;
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

  void _calculateAge() {
    if (_selectedDate == null) return;

    DateTime today = DateTime.now();
    int years = today.year - _selectedDate!.year;
    int months = today.month - _selectedDate!.month;
    int days = today.day - _selectedDate!.day;
    int totalDays = today.difference(_selectedDate!).inDays;
    int totalMonths = (years * 12) + months;
    int totalWeeks = (totalDays / 7).floor();
    int totalHours = totalDays * 24;
    int totalMinutes = totalHours * 60;
    int totalSeconds = totalMinutes * 60;

    if (days < 0) {
      months--;
      days += DateTime(today.year, today.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      _result = "$years ${getText('years')}, $months ${getText('months')}, $days ${getText('days')}";
      _ageDetails = {
        'years': years,
        'months': months,
        'days': days,
        'totalDays': totalDays,
        'totalMonths': totalMonths,
        'totalWeeks': totalWeeks,
        'totalHours': totalHours,
        'totalMinutes': totalMinutes,
        'totalSeconds': totalSeconds,
        'zodiac': _getZodiacSign(_selectedDate!),
        'birthstone': _getBirthstone(_selectedDate!),
        'generation': _getGeneration(years),
        'dayOfWeek': DateFormat('EEEE').format(_selectedDate!),
        'lifePercentage': _getLifePercentage(years),
        'daysUntilNext': _getDaysUntilNextBirthday(),
      };
    });
  }

  String _getZodiacSign(DateTime date) {
    int day = date.day;
    int month = date.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "♈ Aries (मेष)";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "♉ Taurus (वृषभ)";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "♊ Gemini (मिथुन)";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "♋ Cancer (कर्क)";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "♌ Leo (सिंह)";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "♍ Virgo (कन्या)";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "♎ Libra (तुला)";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return "♏ Scorpio (वृश्चिक)";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "♐ Sagittarius (धनु)";
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return "♑ Capricorn (मकर)";
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "♒ Aquarius (कुंभ)";
    return "♓ Pisces (मीन)";
  }

  String _getBirthstone(DateTime date) {
    int month = date.month;
    Map<int, String> stones = {
      1: "💎 Garnet (गोमेद)",
      2: "💜 Amethyst (एमिथिस्ट)",
      3: "💙 Aquamarine (एक्वामरीन)",
      4: "💎 Diamond (हीरा)",
      5: "💚 Emerald (पन्ना)",
      6: "🤍 Pearl (मोती)",
      7: "❤️ Ruby (माणिक्य)",
      8: "💚 Peridot (पेरिडॉट)",
      9: "💙 Sapphire (नीलम)",
      10: "💗 Opal (ओपल)",
      11: "💛 Topaz (पुखराज)",
      12: "💙 Turquoise (फिरोजा)",
    };
    return stones[month] ?? "Unknown";
  }

  String _getGeneration(int age) {
    int birthYear = DateTime.now().year - age;
    if (birthYear >= 1997) return "Gen Z (जनरेशन Z)";
    if (birthYear >= 1981) return "Millennial (मिलेनियल)";
    if (birthYear >= 1965) return "Gen X (जनरेशन X)";
    if (birthYear >= 1946) return "Baby Boomer (बेबी बूमर)";
    return "Silent Generation (साइलेंट जनरेशन)";
  }

  String _getLifePercentage(int age) {
    double lifeExpectancy = 72.0; // Average global life expectancy
    double percentage = (age / lifeExpectancy) * 100;
    return percentage.toStringAsFixed(1) + "%";
  }

  int _getDaysUntilNextBirthday() {
    if (_selectedDate == null) return 0;
    DateTime today = DateTime.now();
    DateTime nextBirthday = DateTime(today.year, _selectedDate!.month, _selectedDate!.day);
    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(today.year + 1, _selectedDate!.month, _selectedDate!.day);
    }
    return nextBirthday.difference(today).inDays;
  }

  void _shareAge() {
    String message = "I am ${_ageDetails['years']} years, ${_ageDetails['months']} months, and ${_ageDetails['days']} days old!";
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(getText("copy")), duration: const Duration(seconds: 1)),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
      if (_selectedDate != null) {
        _calculateAge();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(getText("title")),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Language Toggle Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.language),
              onPressed: _toggleLanguage,
              tooltip: getText("language"),
            ),
          ),
          // Share Button
          if (_ageDetails.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareAge,
              tooltip: getText("share"),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Result Card
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cake, size: 60, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Age Details Section
              if (_ageDetails.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: const Color(0xFF6366F1)),
                            const SizedBox(width: 8),
                            Text(
                              getText("ageDetails"),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(getText("totalDays"), "${_ageDetails['totalDays']} ${getText('days')}", Icons.calendar_today),
                        const Divider(),
                        _buildDetailRow(getText("totalMonths"), "${_ageDetails['totalMonths']} ${getText('months')}", Icons.date_range),
                        const Divider(),
                        _buildDetailRow(getText("weeks"), "${_ageDetails['totalWeeks']} ${getText('weeks')}", Icons.weekend),
                        const Divider(),
                        _buildDetailRow(getText("hours"), NumberFormat("#,###").format(_ageDetails['totalHours']), Icons.access_time),
                        const Divider(),
                        _buildDetailRow(getText("minutes"), NumberFormat("#,###").format(_ageDetails['totalMinutes']), Icons.timer),
                        const Divider(),
                        _buildDetailRow(getText("seconds"), NumberFormat("#,###").format(_ageDetails['totalSeconds']), Icons.av_timer),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Additional Information Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.stars, color: const Color(0xFFF59E0B)),
                            const SizedBox(width: 8),
                            Text(
                              getText("additionalInfo"),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(getText("zodiac"), _ageDetails['zodiac'], Icons.star),
                        const Divider(),
                        _buildDetailRow(getText("birthstone"), _ageDetails['birthstone'], Icons.diamond),
                        const Divider(),
                        _buildDetailRow(getText("generation"), _ageDetails['generation'], Icons.people),
                        const Divider(),
                        _buildDetailRow(getText("dayOfWeek"), _ageDetails['dayOfWeek'], Icons.calendar_view_day),
                        const Divider(),
                        _buildDetailRow(getText("daysUntilNext"), "${_ageDetails['daysUntilNext']} ${getText('daysRemaining')}", Icons.celebration),
                        const Divider(),
                        _buildDetailRow(getText("lifeExpectancy"), _ageDetails['lifePercentage'], Icons.favorite),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Gradient Button
              GradientButton(
                text: _selectedDate == null ? getText("selectBirthDate") : getText("recalculate"),
                icon: Icons.calendar_month,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF6366F1),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                    _calculateAge();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Selected Date Display
              if (_selectedDate != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: const Color(0xFF6366F1)),
                    title: Text(getText("selectedDate")),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(_selectedDate!)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate!,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                          _calculateAge();
                        }
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Fun Fact
              if (_ageDetails.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getFunFact(),
                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF6366F1)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getFunFact() {
    if (_selectedDate == null) return "";

    int age = _ageDetails['years'];
    if (age == 0) return "🎉 Welcome to the world! You're a newborn!";
    if (age == 1) return "👶 You've taken your first steps into toddlerhood!";
    if (age == 5) return "📚 Time for kindergarten! Learning begins!";
    if (age == 10) return "🎮 Double digits! The fun has just begun!";
    if (age == 13) return "📱 Welcome to your teenage years!";
    if (age == 18) return "🎓 Congratulations! You're now an adult!";
    if (age == 21) return "🥳 You can legally drink in most countries!";
    if (age == 30) return "💼 Welcome to your thirties! Prime time!";
    if (age == 40) return "🏆 Life begins at 40! You're experienced!";
    if (age == 50) return "🌟 Golden jubilee! Half a century young!";
    if (age == 60) return "🎖️ Senior citizen benefits await!";
    if (age == 70) return "💎 Platinum milestone! Seven decades!";
    if (age == 80) return "👑 Octogenarian! Respect and wisdom!";
    if (age == 90) return "🏅 Nonagenarian! A true inspiration!";
    if (age == 100) return "🎊 Centenarian! What an incredible journey!";

    if (age % 5 == 0) return "🎯 Milestone birthday! Celebrate this special year!";
    if (_ageDetails['totalDays'] > 10000) return "🌍 You've lived over 10,000 days! Amazing!";
    if (_ageDetails['totalHours'] > 100000) return "⏰ You've experienced over 100,000 hours of life!";

    return "✨ Every day is a new adventure! Make it count!";
  }
}