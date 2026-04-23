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
  final TextEditingController _tenureValueController = TextEditingController();

  String _emi = "0";
  String _totalInterest = "0";
  String _totalAmount = "0";
  bool _isLoading = false;
  String _language = "English";
  int _selectedLoanType = 0;
  bool _showAmortization = false;
  final GlobalKey _resultKey = GlobalKey();

  // Tenure selection
  String _tenureType = "Years"; // Years, Months, Days
  double _tenureYears = 1.0;
  int _tenureMonths = 12;
  int _tenureDays = 365;

  // Loan amount in rupees
  int _principalAmount = 10000;

  // Interest rate
  double _interestRate = 12.0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<Map<String, dynamic>> _amortizationSchedule = [];

  final List<Map<String, dynamic>> _loanTypes = [
    {"name": "Home Loan", "minRate": 8.0, "maxRate": 12.0, "color": const Color(0xFF6366F1), "icon": Icons.home, "maxTenureYears": 30},
    {"name": "Car Loan", "minRate": 9.0, "maxRate": 15.0, "color": const Color(0xFF10B981), "icon": Icons.directions_car, "maxTenureYears": 7},
    {"name": "Personal Loan", "minRate": 10.0, "maxRate": 18.0, "color": const Color(0xFFF59E0B), "icon": Icons.person, "maxTenureYears": 5},
    {"name": "Education Loan", "minRate": 8.5, "maxRate": 13.0, "color": const Color(0xFFEC4899), "icon": Icons.school, "maxTenureYears": 15},
    {"name": "Business Loan", "minRate": 11.0, "maxRate": 20.0, "color": const Color(0xFF8B5CF6), "icon": Icons.business, "maxTenureYears": 10},
  ];

  final Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "EMI Calculator",
      "loanAmount": "Loan Amount (₹)",
      "interestRate": "Interest Rate (%)",
      "tenure": "Tenure",
      "years": "Years",
      "months": "Months",
      "days": "Days",
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
      "enterAmount": "Enter loan amount",
      "enterRate": "Enter interest rate",
      "enterTenure": "Enter tenure",
      "minAmount": "Minimum amount: ₹10",
      "maxRate": "Maximum rate: 48%",
    },
    "Hindi": {
      "title": "ईएमआई कैलकुलेटर",
      "loanAmount": "ऋण राशि (₹)",
      "interestRate": "ब्याज दर (%)",
      "tenure": "अवधि",
      "years": "साल",
      "months": "महीने",
      "days": "दिन",
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
      "enterAmount": "ऋण राशि दर्ज करें",
      "enterRate": "ब्याज दर दर्ज करें",
      "enterTenure": "अवधि दर्ज करें",
      "minAmount": "न्यूनतम राशि: ₹10",
      "maxRate": "अधिकतम दर: 48%",
    },
  };

  String getText(String key) => _translations[_language]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _principalController.text = "10000";
    _rateController.text = "12";
    _updateTenureController();
    _calculateEMI();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureValueController.dispose();
    super.dispose();
  }

  void _updateTenureController() {
    if (_tenureType == "Years") {
      _tenureValueController.text = _tenureYears.toStringAsFixed(1);
    } else if (_tenureType == "Months") {
      _tenureValueController.text = _tenureMonths.toString();
    } else {
      _tenureValueController.text = _tenureDays.toString();
    }
  }

  double _getTotalMonths() {
    if (_tenureType == "Years") {
      return _tenureYears * 12;
    } else if (_tenureType == "Months") {
      return _tenureMonths.toDouble();
    } else {
      return _tenureDays / 30.44; // Average days in a month
    }
  }

  void _calculateEMI() async {
    double principal = double.tryParse(_principalController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double totalMonths = _getTotalMonths();

    if (principal < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimum loan amount is ₹10"), backgroundColor: Colors.red),
      );
      return;
    }

    if (rate < 0 || rate > 48) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Interest rate must be between 0% and 48%"), backgroundColor: Colors.red),
      );
      return;
    }

    if (totalMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid tenure"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100));

    if (principal > 0 && rate > 0 && totalMonths > 0) {
      double monthlyRate = rate / 12 / 100;
      double emi = (principal * monthlyRate * pow(1 + monthlyRate, totalMonths)) / (pow(1 + monthlyRate, totalMonths) - 1);
      double totalAmount = emi * totalMonths;
      double totalInterest = totalAmount - principal;

      setState(() {
        _emi = emi.toStringAsFixed(0);
        _totalInterest = totalInterest.toStringAsFixed(0);
        _totalAmount = totalAmount.toStringAsFixed(0);
        _isLoading = false;
      });

      _animationController.forward(from: 0);
      _calculateAmortization(principal, monthlyRate, totalMonths, emi);

      await HistoryService.addToHistory(
        expression: "₹${_formatNumber(principal)} at ${rate}% for ${_getTenureText()}",
        result: "Monthly EMI: ₹$_emi, Total: ₹$_totalAmount",
        calculatorType: "EMI",
      );

      HapticFeedback.mediumImpact();
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _getTenureText() {
    if (_tenureType == "Years") {
      return "${_tenureYears.toStringAsFixed(1)} years";
    } else if (_tenureType == "Months") {
      return "$_tenureMonths months";
    } else {
      return "$_tenureDays days";
    }
  }

  String _formatNumber(double value) {
    if (value >= 10000000) return "${(value / 10000000).toStringAsFixed(2)} Cr";
    if (value >= 100000) return "${(value / 100000).toStringAsFixed(2)} Lac";
    return value.toStringAsFixed(0);
  }

  void _calculateAmortization(double principal, double monthlyRate, double months, double emi) {
    List<Map<String, dynamic>> schedule = [];
    double balance = principal;
    double totalPrincipalPaid = 0;
    double totalInterestPaid = 0;
    int monthsInt = months.toInt();

    for (int i = 1; i <= monthsInt && i <= 60; i++) {
      double interestPayment = balance * monthlyRate;
      double principalPayment = emi - interestPayment;
      balance -= principalPayment;
      totalPrincipalPaid += principalPayment;
      totalInterestPaid += interestPayment;

      if (i % 12 == 0 || i == monthsInt) {
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
${getText("loanAmount")}: ₹${_formatNumber(double.parse(_principalController.text))}
${getText("interestRate")}: ${_rateController.text}%
${getText("tenure")}: ${_getTenureText()}
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
${getText("loanAmount")}: ₹${_formatNumber(double.parse(_principalController.text))}
${getText("interestRate")}: ${_rateController.text}%
${getText("tenure")}: ${_getTenureText()}
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
        ? (double.parse(_principalController.text) / double.parse(_totalAmount) * 100)
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
                          _rateController.text = _loanTypes[index]["minRate"].toString();
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
                    // Loan Amount
                    TextField(
                      controller: _principalController,
                      decoration: InputDecoration(
                        labelText: getText("loanAmount"),
                        hintText: getText("enterAmount"),
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        helperText: getText("minAmount"),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateEMI(),
                    ),
                    const SizedBox(height: 20),

                    // Interest Rate
                    TextField(
                      controller: _rateController,
                      decoration: InputDecoration(
                        labelText: getText("interestRate"),
                        hintText: getText("enterRate"),
                        prefixIcon: const Icon(Icons.percent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        helperText: getText("maxRate"),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateEMI(),
                    ),
                    const SizedBox(height: 20),

                    // Tenure Type Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildTenureButton("Years", Icons.calendar_today, accentColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTenureButton("Months", Icons.date_range, accentColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTenureButton("Days", Icons.today, accentColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Tenure Value Input
                    TextField(
                      controller: _tenureValueController,
                      decoration: InputDecoration(
                        labelText: "${getText("tenure")} (${getText(_tenureType.toLowerCase())})",
                        hintText: getText("enterTenure"),
                        prefixIcon: const Icon(Icons.timeline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (_tenureType == "Years") {
                          _tenureYears = double.tryParse(value) ?? 1;
                        } else if (_tenureType == "Months") {
                          _tenureMonths = int.tryParse(value) ?? 12;
                        } else {
                          _tenureDays = int.tryParse(value) ?? 365;
                        }
                        _calculateEMI();
                      },
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
                          "₹${_formatNumber(double.parse(_emi))}",
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
                                    Text("₹${_formatNumber(double.parse(_totalInterest))}",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
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
                                    Text("₹${_formatNumber(double.parse(_totalAmount))}",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tenure Info
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Tenure: ${_getTenureText()}",
                            style: TextStyle(fontSize: 12, color: accentColor),
                          ),
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
                                    "Balance: ₹${_formatNumber(data['balance'])}",
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
                                        Text("₹${_formatNumber(data['totalPrincipal'])}",
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(getText("interestPaid"), style: const TextStyle(fontSize: 11)),
                                        Text("₹${_formatNumber(data['totalInterest'])}",
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: data['balance'] / double.parse(_principalController.text),
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

  Widget _buildTenureButton(String type, IconData icon, Color color) {
    bool isSelected = _tenureType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tenureType = type;
          _updateTenureController();
        });
        _calculateEMI();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(
              getText(type.toLowerCase()),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
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
      {"icon": "📅", "tip": "You can choose tenure in Years, Months, or Days"},
    ]
        : [
      {"icon": "💰", "tip": "अधिक डाउन पेमेंट से आपका EMI बोझ कम होता है"},
      {"icon": "📉", "tip": "ब्याज भुगतान बचाने के लिए अपना ऋण पूर्व भुगतान करें"},
      {"icon": "🏦", "tip": "विभिन्न बैंकों में ब्याज दरों की तुलना करें"},
      {"icon": "📊", "tip": "कुल ब्याज बचाने के लिए कम अवधि चुनें"},
      {"icon": "💳", "tip": "बेहतर दरों के लिए अच्छा CIBIL स्कोर बनाए रखें"},
      {"icon": "🎯", "tip": "EMI आपकी मासिक आय के 40% से अधिक नहीं होनी चाहिए"},
      {"icon": "📅", "tip": "आप साल, महीने या दिनों में अवधि चुन सकते हैं"},
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