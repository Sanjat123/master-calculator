import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../widgets/gradient_button.dart';
import '../services/history_service.dart';

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  State<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> with SingleTickerProviderStateMixin {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _result = "Select date range";
  Map<String, dynamic> _ageDetails = {};
  String _language = "English";
  bool _isLoading = false;
  bool _showAgeRange = false;
  RangeValues _ageRange = const RangeValues(0, 100);
  final GlobalKey _resultKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Language-specific texts
  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "Age Calculator",
      "fromDate": "From Date",
      "toDate": "To Date",
      "selectFromDate": "Select Start Date",
      "selectToDate": "Select End Date",
      "years": "Years",
      "months": "Months",
      "days": "Days",
      "totalDays": "Total Days",
      "totalMonths": "Total Months",
      "nextBirthday": "Next Birthday",
      "daysRemaining": "days remaining",
      "selectDateRange": "Select Date Range",
      "calculate": "Calculate Age",
      "selectedFromDate": "Selected From Date",
      "selectedToDate": "Selected To Date",
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
      "savedToHistory": "Saved to history",
      "shareTitle": "Age Details",
      "shareMessage": "Check out my age details from Master Calculator",
      "ageRange": "Age Range",
      "filterByAge": "Filter by Age",
      "minAge": "Min Age",
      "maxAge": "Max Age",
      "peopleInRange": "People in this age range",
      "ageDistribution": "Age Distribution",
      "dateRange": "Date Range",
      "swapDates": "Swap Dates",
      "clearDates": "Clear Dates",
    },
    "Hindi": {
      "title": "आयु कैलकुलेटर",
      "fromDate": "प्रारंभ तिथि",
      "toDate": "अंतिम तिथि",
      "selectFromDate": "प्रारंभ तिथि चुनें",
      "selectToDate": "अंतिम तिथि चुनें",
      "years": "साल",
      "months": "महीने",
      "days": "दिन",
      "totalDays": "कुल दिन",
      "totalMonths": "कुल महीने",
      "nextBirthday": "अगला जन्मदिन",
      "daysRemaining": "दिन शेष",
      "selectDateRange": "तिथि सीमा चुनें",
      "calculate": "आयु गणना करें",
      "selectedFromDate": "चयनित प्रारंभ तिथि",
      "selectedToDate": "चयनित अंतिम तिथि",
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
      "savedToHistory": "इतिहास में सहेजा गया",
      "shareTitle": "आयु विवरण",
      "shareMessage": "मास्टर कैलकुलेटर से मेरी आयु विवरण देखें",
      "ageRange": "आयु सीमा",
      "filterByAge": "आयु के अनुसार फ़िल्टर करें",
      "minAge": "न्यूनतम आयु",
      "maxAge": "अधिकतम आयु",
      "peopleInRange": "इस आयु सीमा में लोग",
      "ageDistribution": "आयु वितरण",
      "dateRange": "तिथि सीमा",
      "swapDates": "तिथियां बदलें",
      "clearDates": "तिथियां साफ़ करें",
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

    // Set default dates
    _toDate = DateTime.now();
    _fromDate = DateTime.now().subtract(const Duration(days: 365 * 25));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateAge() async {
    if (_fromDate == null || _toDate == null) {
      _showSnackBar("Please select both dates");
      return;
    }

    if (_fromDate!.isAfter(_toDate!)) {
      _showSnackBar("From date cannot be after To date");
      return;
    }

    setState(() => _isLoading = true);

    DateTime start = _fromDate!;
    DateTime end = _toDate!;

    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;
    int totalDays = end.difference(start).inDays;
    int totalMonths = (years * 12) + months;
    int totalWeeks = (totalDays / 7).floor();
    int totalHours = totalDays * 24;
    int totalMinutes = totalHours * 60;
    int totalSeconds = totalMinutes * 60;

    if (days < 0) {
      months--;
      days += DateTime(end.year, end.month, 0).day;
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
        'zodiac': _getZodiacSign(start),
        'birthstone': _getBirthstone(start),
        'generation': _getGeneration(years),
        'dayOfWeek': DateFormat('EEEE').format(start),
        'lifePercentage': _getLifePercentage(years),
        'daysUntilNext': _getDaysUntilNextBirthday(),
      };
      _isLoading = false;
    });

    // Save to history
    await HistoryService.addToHistory(
      expression: "From ${DateFormat('dd/MM/yyyy').format(_fromDate!)} to ${DateFormat('dd/MM/yyyy').format(_toDate!)}",
      result: "$years years $months months $days days",
      calculatorType: "Age",
    );

    _showSnackBar(getText("savedToHistory"));
    HapticFeedback.mediumImpact();
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
    double lifeExpectancy = 72.0;
    double percentage = (age / lifeExpectancy) * 100;
    return percentage.toStringAsFixed(1) + "%";
  }

  int _getDaysUntilNextBirthday() {
    if (_fromDate == null) return 0;
    DateTime today = DateTime.now();
    DateTime nextBirthday = DateTime(today.year, _fromDate!.month, _fromDate!.day);
    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(today.year + 1, _fromDate!.month, _fromDate!.day);
    }
    return nextBirthday.difference(today).inDays;
  }

  void _swapDates() {
    setState(() {
      DateTime? temp = _fromDate;
      _fromDate = _toDate;
      _toDate = temp;
    });
    _calculateAge();
  }

  void _clearDates() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _result = "Select date range";
      _ageDetails = {};
    });
  }

  Future<void> _shareAge() async {
    try {
      setState(() => _isLoading = true);

      final RenderRepaintBoundary boundary = _resultKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory directory = await getTemporaryDirectory();
      final File imagePath = await File('${directory.path}/age_result.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
${getText("shareTitle")}:
From: ${DateFormat('dd MMMM yyyy').format(_fromDate!)}
To: ${DateFormat('dd MMMM yyyy').format(_toDate!)}
${_result}
---
${getText("shareMessage")}
      """;

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: shareText,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      String message = "From: ${DateFormat('dd/MM/yyyy').format(_fromDate!)} To: ${DateFormat('dd/MM/yyyy').format(_toDate!)}\n$_result";
      await Share.share(message);
    }
  }

  void _copyAge() {
    String message = "From: ${DateFormat('dd/MM/yyyy').format(_fromDate!)} To: ${DateFormat('dd/MM/yyyy').format(_toDate!)}\n$_result";
    Clipboard.setData(ClipboardData(text: message));
    _showSnackBar(getText("copy"));
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
      if (_fromDate != null && _toDate != null) {
        _calculateAge();
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  String _getAgeCategory(int age) {
    if (age < 13) return "Child (बच्चा)";
    if (age < 20) return "Teenager (किशोर)";
    if (age < 30) return "Young Adult (युवा)";
    if (age < 50) return "Adult (वयस्क)";
    if (age < 65) return "Middle Age (मध्यम आयु)";
    return "Senior (वरिष्ठ)";
  }

  Future<void> _selectFromDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: _toDate ?? DateTime.now(),
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
      setState(() => _fromDate = picked);
      if (_toDate != null && _fromDate!.isBefore(_toDate!)) {
        _calculateAge();
      }
    }
  }

  Future<void> _selectToDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(1900),
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
      setState(() => _toDate = picked);
      if (_fromDate != null && _fromDate!.isBefore(_toDate!)) {
        _calculateAge();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int currentAge = _ageDetails.isNotEmpty ? _ageDetails['years'] : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(getText("title")),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: getText("language"),
          ),
          if (_fromDate != null && _toDate != null) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareAge,
              tooltip: getText("share"),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyAge,
              tooltip: getText("copy"),
            ),
          ],
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Range Selection Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range, color: const Color(0xFF6366F1)),
                          const SizedBox(width: 8),
                          Text(
                            getText("dateRange"),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // From Date
                      InkWell(
                        onTap: _selectFromDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: const Color(0xFF6366F1), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getText("fromDate"),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _fromDate != null
                                          ? DateFormat('dd MMMM yyyy').format(_fromDate!)
                                          : getText("selectFromDate"),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: _fromDate != null ? null : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Swap Button
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert, color: Color(0xFF6366F1)),
                          onPressed: _swapDates,
                          tooltip: getText("swapDates"),
                        ),
                      ),

                      // To Date
                      InkWell(
                        onTap: _selectToDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: const Color(0xFF6366F1), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getText("toDate"),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _toDate != null
                                          ? DateFormat('dd MMMM yyyy').format(_toDate!)
                                          : getText("selectToDate"),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: _toDate != null ? null : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Clear Button
                      if (_fromDate != null || _toDate != null)
                        TextButton.icon(
                          onPressed: _clearDates,
                          icon: const Icon(Icons.clear, size: 16),
                          label: Text(getText("clearDates")),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Main Result Card
              RepaintBoundary(
                key: _resultKey,
                child: Container(
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
                      const Icon(Icons.date_range, size: 60, color: Colors.white),
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
              ),
              const SizedBox(height: 20),

              // Age Category Badge
              if (_ageDetails.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category, size: 16, color: const Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      Text(
                        _getAgeCategory(currentAge),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Calculate Button
              GradientButton(
                text: getText("calculate"),
                icon: Icons.calculate,
                isLoading: _isLoading,
                onPressed: _calculateAge,
              ),

              const SizedBox(height: 16),

              // Selected Dates Display
              if (_fromDate != null && _toDate != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: const Color(0xFF6366F1)),
                            const SizedBox(width: 8),
                            Text(
                              getText("selectedFromDate"),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('dd MMMM yyyy').format(_fromDate!),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: const Color(0xFF6366F1)),
                            const SizedBox(width: 8),
                            Text(
                              getText("selectedToDate"),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('dd MMMM yyyy').format(_toDate!),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
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
    if (_fromDate == null || _toDate == null) return "";

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