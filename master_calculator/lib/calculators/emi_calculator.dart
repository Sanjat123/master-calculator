import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/gradient_button.dart';
import '../services/history_service.dart';

class EMICalculator extends StatefulWidget {
  const EMICalculator({super.key});

  @override
  State<EMICalculator> createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> with SingleTickerProviderStateMixin {
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();

  String _emi = "0";
  String _totalInterest = "0";
  String _totalAmount = "0";
  bool _isLoading = false;
  String _language = "English";
  int _selectedLoanType = 0;
  bool _showAmortization = false;
  final GlobalKey _resultKey = GlobalKey();

  double _principalSlider = 500000;
  double _rateSlider = 10.0;
  double _tenureSlider = 5.0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<Map<String, dynamic>> _amortizationSchedule = [];

  final List<Map<String, dynamic>> _loanTypes = [
    {"name": "Home Loan", "minRate": 8.0, "maxRate": 12.0, "color": const Color(0xFF6366F1), "icon": Icons.home, "maxTenure": 30},
    {"name": "Car Loan", "minRate": 9.0, "maxRate": 15.0, "color": const Color(0xFF10B981), "icon": Icons.directions_car, "maxTenure": 7},
    {"name": "Personal Loan", "minRate": 10.0, "maxRate": 18.0, "color": const Color(0xFFF59E0B), "icon": Icons.person, "maxTenure": 5},
    {"name": "Education Loan", "minRate": 8.5, "maxRate": 13.0, "color": const Color(0xFFEC4899), "icon": Icons.school, "maxTenure": 15},
  ];

  final Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "EMI Calculator",
      "principal": "Principal Amount",
      "interestRate": "Interest Rate (%)",
      "tenure": "Tenure (Years)",
      "calculate": "Calculate EMI",
      "monthlyEMI": "Monthly EMI",
      "totalInterest": "Total Interest",
      "totalAmount": "Total Amount",
      "loanType": "Loan Type",
      "amortization": "Amortization Schedule",
      "year": "Year",
      "principalPaid": "Principal Paid",
      "interestPaid": "Interest Paid",
      "balance": "Remaining Balance",
      "share": "Share Results",
      "copy": "Copy Results",
      "savedToHistory": "Saved to history",
      "shareTitle": "EMI Calculation Results",
      "shareMessage": "Check out my EMI calculation from Master Calculator",
      "principalAmount": "Principal Amount",
      "interestRateLabel": "Interest Rate",
      "tenureLabel": "Loan Tenure",
      "paymentBreakdown": "Payment Breakdown",
      "totalPayment": "Total Payment",
    },
    "Hindi": {
      "title": "ईएमआई कैलकुलेटर",
      "principal": "मूल राशि",
      "interestRate": "ब्याज दर (%)",
      "tenure": "अवधि (वर्ष)",
      "calculate": "ईएमआई गणना करें",
      "monthlyEMI": "मासिक ईएमआई",
      "totalInterest": "कुल ब्याज",
      "totalAmount": "कुल राशि",
      "loanType": "ऋण प्रकार",
      "amortization": "परिशोधन अनुसूची",
      "year": "वर्ष",
      "principalPaid": "मूलधन भुगतान",
      "interestPaid": "ब्याज भुगतान",
      "balance": "शेष राशि",
      "share": "परिणाम साझा करें",
      "copy": "परिणाम कॉपी करें",
      "savedToHistory": "इतिहास में सहेजा गया",
      "shareTitle": "ईएमआई गणना परिणाम",
      "shareMessage": "मास्टर कैलकुलेटर से मेरी ईएमआई गणना देखें",
      "principalAmount": "मूल राशि",
      "interestRateLabel": "ब्याज दर",
      "tenureLabel": "ऋण अवधि",
      "paymentBreakdown": "भुगतान विवरण",
      "totalPayment": "कुल भुगतान",
    },
  };

  String getText(String key) => _translations[_language]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _principalController.text = _principalSlider.toStringAsFixed(0);
    _rateController.text = _rateSlider.toStringAsFixed(1);
    _tenureController.text = _tenureSlider.toStringAsFixed(1);
    _calculateEMI();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateEMI() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100));

    double p = _principalSlider;
    double r = _rateSlider / 12 / 100;
    double t = _tenureSlider * 12;

    if (p > 0 && r > 0 && t > 0) {
      double emi = (p * r * pow(1 + r, t)) / (pow(1 + r, t) - 1);
      double totalAmount = emi * t;
      double totalInterest = totalAmount - p;

      setState(() {
        _emi = emi.toStringAsFixed(0);
        _totalInterest = totalInterest.toStringAsFixed(0);
        _totalAmount = totalAmount.toStringAsFixed(0);
        _isLoading = false;
      });

      _animationController.forward(from: 0);
      _calculateAmortization(p, r, t, emi);

      // Save to history
      await HistoryService.addToHistory(
        expression: "${_loanTypes[_selectedLoanType]["name"]}: ₹${_principalSlider.toStringAsFixed(0)} at ${_rateSlider}% for ${_tenureSlider} years",
        result: "Monthly EMI: ₹$_emi, Total: ₹$_totalAmount",
        calculatorType: "EMI",
      );

      HapticFeedback.mediumImpact();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _calculateAmortization(double principal, double monthlyRate, double months, double emi) {
    List<Map<String, dynamic>> schedule = [];
    double balance = principal;
    double totalPrincipalPaid = 0;
    double totalInterestPaid = 0;

    for (int i = 1; i <= months.toInt() && i <= 60; i++) {
      double interestPayment = balance * monthlyRate;
      double principalPayment = emi - interestPayment;
      balance -= principalPayment;
      totalPrincipalPaid += principalPayment;
      totalInterestPaid += interestPayment;

      if (i % 12 == 0 || i == months.toInt()) {
        schedule.add({
          'year': (i / 12).ceil(),
          'principal': principalPayment,
          'interest': interestPayment,
          'totalPrincipal': totalPrincipalPaid,
          'totalInterest': totalInterestPaid,
          'balance': balance > 0 ? balance : 0,
        });
      }
    }
    setState(() => _amortizationSchedule = schedule);
  }

  void _copyResults() {
    String results = """
${getText("title")} Results:
${getText("principalAmount")}: ₹${_principalSlider.toStringAsFixed(0)}
${getText("interestRateLabel")}: ${_rateSlider}%
${getText("tenureLabel")}: ${_tenureSlider} years
${getText("monthlyEMI")}: ₹$_emi
${getText("totalInterest")}: ₹$_totalInterest
${getText("totalAmount")}: ₹$_totalAmount
    """;
    Clipboard.setData(ClipboardData(text: results));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getText("copy")), duration: const Duration(seconds: 1)));
  }

  Future<void> _shareResults() async {
    try {
      setState(() => _isLoading = true);

      final RenderRepaintBoundary boundary = _resultKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory directory = await getTemporaryDirectory();
      final File imagePath = await File('${directory.path}/emi_result.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
${getText("shareTitle")}:
${getText("principalAmount")}: ₹${_principalSlider.toStringAsFixed(0)}
${getText("interestRateLabel")}: ${_rateSlider}%
${getText("tenureLabel")}: ${_tenureSlider} years
${getText("monthlyEMI")}: ₹$_emi
${getText("totalInterest")}: ₹$_totalInterest
${getText("totalAmount")}: ₹$_totalAmount
---
${getText("shareMessage")}
      """;

      await Share.shareXFiles([XFile(imagePath.path)], text: shareText);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _copyResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loan = _loanTypes[_selectedLoanType];
    final accentColor = loan["color"];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double principalPercent = double.tryParse(_totalAmount) != 0
        ? (_principalSlider / double.parse(_totalAmount) * 100)
        : 0;
    double interestPercent = 100 - principalPercent;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(getText("title")),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => setState(() => _language = _language == "English" ? "Hindi" : "English"),
          ),
          if (_emi != "0") ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResults,
              tooltip: getText("share"),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyResults,
              tooltip: getText("copy"),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loan Type Selector
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _loanTypes.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedLoanType == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(_loanTypes[index]["name"]),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          _selectedLoanType = index;
                          _rateSlider = _loanTypes[index]["minRate"];
                          _rateController.text = _rateSlider.toStringAsFixed(1);
                          if (_tenureSlider > _loanTypes[index]["maxTenure"]) {
                            _tenureSlider = _loanTypes[index]["maxTenure"].toDouble();
                            _tenureController.text = _tenureSlider.toStringAsFixed(1);
                          }
                        });
                        _calculateEMI();
                      },
                      avatar: Icon(_loanTypes[index]["icon"], size: 16),
                      selectedColor: accentColor.withOpacity(0.2),
                      checkmarkColor: accentColor,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Input Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSliderRow(getText("principal"), "₹", _principalSlider, 10000, 10000000, (val) {
                      setState(() => _principalSlider = val);
                      _principalController.text = val.toStringAsFixed(0);
                      _calculateEMI();
                    }, accentColor, isDark),
                    const Divider(height: 30),
                    _buildSliderRow(getText("interestRate"), "%", _rateSlider, loan["minRate"], loan["maxRate"], (val) {
                      setState(() => _rateSlider = val);
                      _rateController.text = val.toStringAsFixed(1);
                      _calculateEMI();
                    }, accentColor, isDark),
                    const Divider(height: 30),
                    _buildSliderRow(getText("tenure"), "Y", _tenureSlider, 1, loan["maxTenure"].toDouble(), (val) {
                      setState(() => _tenureSlider = val);
                      _tenureController.text = val.toStringAsFixed(1);
                      _calculateEMI();
                    }, accentColor, isDark),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Calculate Button
            GradientButton(
              text: getText("calculate"),
              icon: Icons.calculate,
              isLoading: _isLoading,
              onPressed: _calculateEMI,
            ),

            if (_emi != "0") ...[
              const SizedBox(height: 20),

              // Result Section
              RepaintBoundary(
                key: _resultKey,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor.withOpacity(0.1), accentColor.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        // Monthly EMI
                        Text(getText("monthlyEMI"), style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text(
                          "₹$_emi",
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: accentColor),
                        ),
                        const SizedBox(height: 24),

                        // Payment Breakdown Chart
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: principalPercent / 100,
                                          strokeWidth: 10,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${principalPercent.toStringAsFixed(1)}%",
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentColor),
                                            ),
                                            const Text("Principal", style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: interestPercent / 100,
                                          strokeWidth: 10,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${interestPercent.toStringAsFixed(1)}%",
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                                            ),
                                            const Text("Interest", style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Total Interest and Total Amount
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(getText("totalInterest"), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    const SizedBox(height: 4),
                                    Text("₹$_totalInterest", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(getText("totalAmount"), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    const SizedBox(height: 4),
                                    Text("₹$_totalAmount", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Amortization Schedule Toggle
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(Icons.table_chart, color: accentColor),
                  title: const Text("Amortization Schedule"),
                  trailing: Icon(_showAmortization ? Icons.expand_less : Icons.expand_more),
                  onTap: () => setState(() => _showAmortization = !_showAmortization),
                ),
              ),

              if (_showAmortization && _amortizationSchedule.isNotEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Year-wise Breakdown",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ..._amortizationSchedule.map((data) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${getText("year")} ${data['year']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Balance: ₹${data['balance'].toStringAsFixed(0)}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(getText("principalPaid"), style: const TextStyle(fontSize: 11)),
                                        Text("₹${data['totalPrincipal'].toStringAsFixed(0)}",
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(getText("interestPaid"), style: const TextStyle(fontSize: 11)),
                                        Text("₹${data['totalInterest'].toStringAsFixed(0)}",
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: data['balance'] / _principalSlider,
                                backgroundColor: Colors.grey.shade200,
                                color: accentColor,
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // EMI Tips
              _buildEMITips(accentColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, String unit, double value, double min, double max, Function(double) onChanged, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${value.toStringAsFixed(value > 100 ? 0 : 1)} $unit",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: color,
          inactiveColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          divisions: 100,
          label: "${value.toStringAsFixed(1)} $unit",
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEMITips(Color accentColor) {
    List<Map<String, String>> tips = _language == "English"
        ? [
      {"icon": "💰", "tip": "Higher down payment reduces your EMI burden"},
      {"icon": "📉", "tip": "Prepay your loan to save on interest payments"},
      {"icon": "🏦", "tip": "Compare interest rates across different banks"},
      {"icon": "📊", "tip": "Choose shorter tenure to save total interest"},
      {"icon": "💳", "tip": "Maintain good CIBIL score for better rates"},
      {"icon": "🎯", "tip": "EMI should not exceed 40% of your monthly income"},
    ]
        : [
      {"icon": "💰", "tip": "अधिक डाउन पेमेंट से आपका EMI बोझ कम होता है"},
      {"icon": "📉", "tip": "ब्याज भुगतान बचाने के लिए अपना ऋण पूर्व भुगतान करें"},
      {"icon": "🏦", "tip": "विभिन्न बैंकों में ब्याज दरों की तुलना करें"},
      {"icon": "📊", "tip": "कुल ब्याज बचाने के लिए कम अवधि चुनें"},
      {"icon": "💳", "tip": "बेहतर दरों के लिए अच्छा CIBIL स्कोर बनाए रखें"},
      {"icon": "🎯", "tip": "EMI आपकी मासिक आय के 40% से अधिक नहीं होनी चाहिए"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Smart Loan Tips",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(tip["icon"]!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip["tip"]!,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}