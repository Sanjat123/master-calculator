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

class LoanCalculator extends StatefulWidget {
  const LoanCalculator({super.key});

  @override
  State<LoanCalculator> createState() => _LoanCalculatorState();
}

class _LoanCalculatorState extends State<LoanCalculator> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  String _totalPayment = "0";
  String _totalInterest = "0";
  String _monthlyPayment = "0";
  String _language = "English";
  int _selectedLoanType = 0;
  bool _isLoading = false;
  bool _showAmortization = false;
  final GlobalKey _resultKey = GlobalKey();

  double _amountSlider = 500000;
  double _rateSlider = 10.0;
  double _yearsSlider = 5.0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<Map<String, dynamic>> _amortizationSchedule = [];

  final List<Map<String, dynamic>> _loanTypes = [
    {"name": "Personal Loan", "minRate": 10.0, "maxRate": 18.0, "color": const Color(0xFF6366F1), "icon": Icons.person, "maxYears": 5},
    {"name": "Home Loan", "minRate": 8.0, "maxRate": 12.0, "color": const Color(0xFF10B981), "icon": Icons.home, "maxYears": 30},
    {"name": "Car Loan", "minRate": 9.0, "maxRate": 15.0, "color": const Color(0xFFF59E0B), "icon": Icons.directions_car, "maxYears": 7},
    {"name": "Education Loan", "minRate": 8.5, "maxRate": 13.0, "color": const Color(0xFFEC4899), "icon": Icons.school, "maxYears": 15},
    {"name": "Business Loan", "minRate": 11.0, "maxRate": 20.0, "color": const Color(0xFF8B5CF6), "icon": Icons.business, "maxYears": 10},
  ];

  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "Loan Calculator",
      "loanAmount": "Loan Amount",
      "interestRate": "Interest Rate (%)",
      "loanTerm": "Loan Term (Years)",
      "calculate": "Calculate",
      "totalPayment": "Total Payment",
      "totalInterest": "Total Interest",
      "monthlyPayment": "Monthly Payment",
      "loanType": "Loan Type",
      "amortization": "Amortization Schedule",
      "year": "Year",
      "principalPaid": "Principal Paid",
      "interestPaid": "Interest Paid",
      "balance": "Remaining Balance",
      "share": "Share Results",
      "copy": "Copy Results",
      "language": "Language",
      "loanSummary": "Loan Summary",
      "paymentBreakdown": "Payment Breakdown",
      "principalAmount": "Principal Amount",
      "tips": "Smart Borrowing Tips",
      "enterValid": "Please fill all fields correctly",
      "savedToHistory": "Saved to history",
      "shareTitle": "Loan Calculation Results",
      "shareMessage": "Check out my loan calculation from Master Calculator",
      "totalPaymentLabel": "Total Payment",
      "interestAmount": "Interest Amount",
    },
    "Hindi": {
      "title": "ऋण कैलकुलेटर",
      "loanAmount": "ऋण राशि",
      "interestRate": "ब्याज दर (%)",
      "loanTerm": "ऋण अवधि (वर्ष)",
      "calculate": "गणना करें",
      "totalPayment": "कुल भुगतान",
      "totalInterest": "कुल ब्याज",
      "monthlyPayment": "मासिक भुगतान",
      "loanType": "ऋण प्रकार",
      "amortization": "परिशोधन अनुसूची",
      "year": "वर्ष",
      "principalPaid": "मूलधन भुगतान",
      "interestPaid": "ब्याज भुगतान",
      "balance": "शेष राशि",
      "share": "परिणाम साझा करें",
      "copy": "परिणाम कॉपी करें",
      "language": "भाषा",
      "loanSummary": "ऋण सारांश",
      "paymentBreakdown": "भुगतान विवरण",
      "principalAmount": "मूल राशि",
      "tips": "स्मार्ट उधार युक्तियाँ",
      "enterValid": "कृपया सभी फ़ील्ड सही भरें",
      "savedToHistory": "इतिहास में सहेजा गया",
      "shareTitle": "ऋण गणना परिणाम",
      "shareMessage": "मास्टर कैलकुलेटर से मेरी ऋण गणना देखें",
      "totalPaymentLabel": "कुल भुगतान",
      "interestAmount": "ब्याज राशि",
    },
  };

  String getText(String key) => _translations[_language]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();

    _amountController.text = _amountSlider.toStringAsFixed(0);
    _rateController.text = _rateSlider.toStringAsFixed(1);
    _yearsController.text = _yearsSlider.toStringAsFixed(1);
    _calculate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _calculate() async {
    double principal = _amountSlider;
    double annualRate = _rateSlider;
    double years = _yearsSlider;

    if (principal > 0 && annualRate > 0 && years > 0) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 100));

      double monthlyRate = annualRate / 100 / 12;
      int months = (years * 12).toInt();

      double emi = 0;
      if (monthlyRate > 0) {
        emi = principal * monthlyRate * pow(1 + monthlyRate, months) / (pow(1 + monthlyRate, months) - 1);
      } else {
        emi = principal / months;
      }

      double totalPayment = emi * months;
      double totalInterest = totalPayment - principal;

      setState(() {
        _monthlyPayment = emi.toStringAsFixed(0);
        _totalPayment = totalPayment.toStringAsFixed(0);
        _totalInterest = totalInterest.toStringAsFixed(0);
        _isLoading = false;
      });

      _calculateAmortization(principal, monthlyRate, months, emi);

      // Save to history
      await HistoryService.addToHistory(
        expression: "${_loanTypes[_selectedLoanType]["name"]}: ₹${principal.toStringAsFixed(0)} at ${annualRate}% for ${years} years",
        result: "Monthly: ₹$_monthlyPayment, Total: ₹$_totalPayment",
        calculatorType: "Loan",
      );

      HapticFeedback.mediumImpact();
    } else {
      _showError(getText("enterValid"));
    }
  }

  void _calculateAmortization(double principal, double monthlyRate, int months, double emi) {
    List<Map<String, dynamic>> schedule = [];
    double balance = principal;
    double totalPrincipalPaid = 0;
    double totalInterestPaid = 0;

    for (int i = 1; i <= months && i <= 60; i++) {
      double interestPayment = balance * monthlyRate;
      double principalPayment = emi - interestPayment;
      balance -= principalPayment;
      totalPrincipalPaid += principalPayment;
      totalInterestPaid += interestPayment;

      if (i % 12 == 0 || i == months) {
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

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  void _onLoanTypeChanged(int index) {
    setState(() {
      _selectedLoanType = index;
      _rateSlider = _loanTypes[index]["minRate"];
      _rateController.text = _rateSlider.toStringAsFixed(1);

      double maxYears = _loanTypes[index]["maxYears"].toDouble();
      if (_yearsSlider > maxYears) {
        _yearsSlider = maxYears;
        _yearsController.text = _yearsSlider.toStringAsFixed(1);
      }
    });
    _calculate();
  }

  void _copyResult() {
    String result = """
${getText("title")} Results:
${getText("loanAmount")}: ₹${_amountSlider.toStringAsFixed(0)}
${getText("interestRate")}: ${_rateSlider}%
${getText("loanTerm")}: ${_yearsSlider} years
${getText("monthlyPayment")}: ₹$_monthlyPayment
${getText("totalInterest")}: ₹$_totalInterest
${getText("totalPayment")}: ₹$_totalPayment
    """;
    Clipboard.setData(ClipboardData(text: result));
    _showSnackBar(getText("copy"));
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
      final File imagePath = await File('${directory.path}/loan_result.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
${getText("shareTitle")}:
${getText("loanAmount")}: ₹${_amountSlider.toStringAsFixed(0)}
${getText("interestRate")}: ${_rateSlider}%
${getText("loanTerm")}: ${_yearsSlider} years
${getText("monthlyPayment")}: ₹$_monthlyPayment
${getText("totalInterest")}: ₹$_totalInterest
${getText("totalPayment")}: ₹$_totalPayment
---
${getText("shareMessage")}
      """;

      await Share.shareXFiles([XFile(imagePath.path)], text: shareText);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _copyResult();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLoanType = _loanTypes[_selectedLoanType];
    final accentColor = currentLoanType["color"];

    double principalPercent = double.tryParse(_totalPayment) != 0
        ? (_amountSlider / double.parse(_totalPayment) * 100)
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
            onPressed: _toggleLanguage,
            tooltip: getText("language"),
          ),
          if (_totalPayment != "0") ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResults,
              tooltip: getText("share"),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyResult,
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
                      onSelected: (val) => _onLoanTypeChanged(index),
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
                    _buildSliderRow(
                      getText("loanAmount"),
                      "₹",
                      _amountSlider,
                      10000,
                      10000000,
                          (val) {
                        setState(() => _amountSlider = val);
                        _amountController.text = val.toStringAsFixed(0);
                        _calculate();
                      },
                      accentColor,
                      isDark,
                    ),
                    const Divider(height: 30),
                    _buildSliderRow(
                      getText("interestRate"),
                      "%",
                      _rateSlider,
                      currentLoanType["minRate"],
                      currentLoanType["maxRate"],
                          (val) {
                        setState(() => _rateSlider = val);
                        _rateController.text = val.toStringAsFixed(1);
                        _calculate();
                      },
                      accentColor,
                      isDark,
                    ),
                    const Divider(height: 30),
                    _buildSliderRow(
                      getText("loanTerm"),
                      "Y",
                      _yearsSlider,
                      1,
                      currentLoanType["maxYears"].toDouble(),
                          (val) {
                        setState(() => _yearsSlider = val);
                        _yearsController.text = val.toStringAsFixed(1);
                        _calculate();
                      },
                      accentColor,
                      isDark,
                    ),
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
              onPressed: _calculate,
            ),

            if (_totalPayment != "0") ...[
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
                        // Monthly Payment
                        Text(getText("monthlyPayment"), style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text(
                          "₹$_monthlyPayment",
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

                        // Total Interest and Total Payment
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
                                    Text(getText("totalPayment"), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    const SizedBox(height: 4),
                                    Text("₹$_totalPayment", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
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
                                value: data['balance'] / _amountSlider,
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

              // Smart Borrowing Tips
              _buildTips(accentColor),
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

  Widget _buildTips(Color accentColor) {
    List<Map<String, String>> tips = _language == "English"
        ? [
      {"icon": "📊", "tip": "Compare interest rates from multiple lenders before applying"},
      {"icon": "💰", "tip": "Make a larger down payment to reduce loan burden"},
      {"icon": "📉", "tip": "Prepay your loan when possible to save on interest"},
      {"icon": "📅", "tip": "Choose shorter tenure to save total interest"},
      {"icon": "💳", "tip": "Maintain a good CIBIL score for better rates"},
      {"icon": "🎯", "tip": "EMI should not exceed 40% of your monthly income"},
    ]
        : [
      {"icon": "📊", "tip": "आवेदन करने से पहले कई ऋणदाताओं से ब्याज दरों की तुलना करें"},
      {"icon": "💰", "tip": "ऋण बोझ कम करने के लिए बड़ा डाउन पेमेंट करें"},
      {"icon": "📉", "tip": "ब्याज बचाने के लिए संभव होने पर अपने ऋण का पूर्व भुगतान करें"},
      {"icon": "📅", "tip": "कुल ब्याज बचाने के लिए कम अवधि चुनें"},
      {"icon": "💳", "tip": "बेहतर दरों के लिए अच्छा CIBIL स्कोर बनाए रखें"},
      {"icon": "🎯", "tip": "EMI आपकी मासिक आय के 40% से अधिक नहीं होनी चाहिए"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getText("tips"),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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