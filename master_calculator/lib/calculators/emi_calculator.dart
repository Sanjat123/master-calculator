import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/gradient_button.dart';

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
  int _selectedLoanType = 0; // 0: Home, 1: Car, 2: Personal, 3: Education
  double _principalSlider = 500000;
  double _rateSlider = 10.0;
  double _tenureSlider = 5.0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  List<Map<String, dynamic>> _amortizationSchedule = [];

  // Loan type configurations
  final List<Map<String, dynamic>> _loanTypes = [
    {"name": "Home Loan", "minRate": 8.0, "maxRate": 12.0, "color": Color(0xFF6366F1), "icon": Icons.home, "maxTenure": 30},
    {"name": "Car Loan", "minRate": 9.0, "maxRate": 15.0, "color": Color(0xFF10B981), "icon": Icons.directions_car, "maxTenure": 7},
    {"name": "Personal Loan", "minRate": 10.0, "maxRate": 18.0, "color": Color(0xFFF59E0B), "icon": Icons.person, "maxTenure": 5},
    {"name": "Education Loan", "minRate": 8.5, "maxRate": 13.0, "color": Color(0xFFEC4899), "icon": Icons.school, "maxTenure": 15},
  ];

  // Language translations
  Map<String, Map<String, String>> _translations = {
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
      "balance": "Balance",
      "share": "Share Results",
      "copy": "Copy Results",
      "language": "Language",
      "enterValid": "Please fill all fields correctly",
      "emiChart": "EMI Breakdown",
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
      "language": "भाषा",
      "enterValid": "कृपया सभी फ़ील्ड सही भरें",
      "emiChart": "ईएमआई विवरण",
    },
  };

  String getText(String key) {
    return _translations[_language]?[key] ?? _translations["English"]![key]!;
  }

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

    // Initialize controllers with slider values
    _principalController.text = _principalSlider.toStringAsFixed(0);
    _rateController.text = _rateSlider.toStringAsFixed(1);
    _tenureController.text = _tenureSlider.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateEMI() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 100), () {
      double p = double.tryParse(_principalController.text) ?? 0;
      double r = (double.tryParse(_rateController.text) ?? 0) / 12 / 100;
      double t = (double.tryParse(_tenureController.text) ?? 0) * 12;

      if (p > 0 && r > 0 && t > 0) {
        double emi = (p * r * pow(1 + r, t)) / (pow(1 + r, t) - 1);
        double totalAmount = emi * t;
        double totalInterest = totalAmount - p;

        setState(() {
          _emi = emi.toStringAsFixed(2);
          _totalInterest = totalInterest.toStringAsFixed(2);
          _totalAmount = totalAmount.toStringAsFixed(2);
          _isLoading = false;
        });

        _calculateAmortization(p, r, t, emi);
        HapticFeedback.mediumImpact();
      } else {
        setState(() => _isLoading = false);
        _showError(getText("enterValid"));
      }
    });
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
          'balance': balance > 0 ? balance : 0,
          'totalPrincipal': totalPrincipalPaid,
          'totalInterest': totalInterestPaid,
        });
      }
    }

    setState(() {
      _amortizationSchedule = schedule;
    });
  }

  void _updateFromSliders() {
    setState(() {
      _principalController.text = _principalSlider.toStringAsFixed(0);
      _rateController.text = _rateSlider.toStringAsFixed(1);
      _tenureController.text = _tenureSlider.toStringAsFixed(1);
    });
    _calculateEMI();
  }

  void _onLoanTypeChanged(int index) {
    setState(() {
      _selectedLoanType = index;
      _rateSlider = _loanTypes[index]["minRate"];
      _rateController.text = _rateSlider.toStringAsFixed(1);

      // Adjust max tenure based on loan type
      double maxTenure = _loanTypes[index]["maxTenure"].toDouble();
      if (_tenureSlider > maxTenure) {
        _tenureSlider = maxTenure;
        _tenureController.text = _tenureSlider.toStringAsFixed(1);
      }
    });
    _calculateEMI();
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  void _shareResults() {
    String results = """
${getText("title")} Results:
${getText("principal")}: ₹${double.tryParse(_principalController.text) ?? 0}
${getText("interestRate")}: ${_rateController.text}%
${getText("tenure")}: ${_tenureController.text} years
${getText("monthlyEMI")}: ₹$_emi
${getText("totalInterest")}: ₹$_totalInterest
${getText("totalAmount")}: ₹$_totalAmount
    """;
    Clipboard.setData(ClipboardData(text: results));
    _showSnackBar(getText("copy"));
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
          if (_emi != "0")
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResults,
              tooltip: getText("share"),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loan Type Selector
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getText("loanType"),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _loanTypes.length,
                      itemBuilder: (context, index) {
                        final loanType = _loanTypes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(loanType["name"]),
                            selected: _selectedLoanType == index,
                            onSelected: (_) => _onLoanTypeChanged(index),
                            avatar: Icon(loanType["icon"], size: 18),
                            selectedColor: loanType["color"].withOpacity(0.2),
                            checkmarkColor: loanType["color"],
                            labelStyle: TextStyle(
                              color: _selectedLoanType == index ? loanType["color"] : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Input Card with Sliders
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Principal Amount Slider
                    Text(
                      "${getText("principal")}: ₹${_principalSlider.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Slider(
                      value: _principalSlider,
                      min: 10000,
                      max: 10000000,
                      divisions: 100,
                      label: "₹${_principalSlider.toStringAsFixed(0)}",
                      onChanged: (value) {
                        setState(() {
                          _principalSlider = value;
                          _principalController.text = value.toStringAsFixed(0);
                        });
                        _calculateEMI();
                      },
                      activeColor: currentLoanType["color"],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₹10K", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text("₹1Cr", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Interest Rate Slider
                    Text(
                      "${getText("interestRate")}: ${_rateSlider.toStringAsFixed(1)}%",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Slider(
                      value: _rateSlider,
                      min: currentLoanType["minRate"],
                      max: currentLoanType["maxRate"],
                      divisions: 100,
                      label: "${_rateSlider.toStringAsFixed(1)}%",
                      onChanged: (value) {
                        setState(() {
                          _rateSlider = value;
                          _rateController.text = value.toStringAsFixed(1);
                        });
                        _calculateEMI();
                      },
                      activeColor: currentLoanType["color"],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${currentLoanType["minRate"]}%", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text("${currentLoanType["maxRate"]}%", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tenure Slider
                    Text(
                      "${getText("tenure")}: ${_tenureSlider.toStringAsFixed(1)} years",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Slider(
                      value: _tenureSlider,
                      min: 1,
                      max: currentLoanType["maxTenure"].toDouble(),
                      divisions: currentLoanType["maxTenure"] * 2,
                      label: "${_tenureSlider.toStringAsFixed(1)} years",
                      onChanged: (value) {
                        setState(() {
                          _tenureSlider = value;
                          _tenureController.text = value.toStringAsFixed(1);
                        });
                        _calculateEMI();
                      },
                      activeColor: currentLoanType["color"],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("1 year", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text("${currentLoanType["maxTenure"]} years", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
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

              // Animated Results
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // EMI Breakdown Chart
                        _buildEMIChart(),

                        const SizedBox(height: 20),

                        // Main Results
                        _buildResultCard(getText("monthlyEMI"), "₹$_emi", const Color(0xFF10B981), Icons.credit_card),
                        const SizedBox(height: 12),
                        _buildResultCard(getText("totalInterest"), "₹$_totalInterest", const Color(0xFFEF4444), Icons.trending_up),
                        const SizedBox(height: 12),
                        _buildResultCard(getText("totalAmount"), "₹$_totalAmount", currentLoanType["color"], Icons.account_balance_wallet),
                      ],
                    ),
                  ),
                ),
              ),

              // Amortization Schedule
              if (_amortizationSchedule.isNotEmpty) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.table_chart, color: currentLoanType["color"]),
                            const SizedBox(width: 8),
                            Text(
                              getText("amortization"),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: _amortizationSchedule.length,
                            itemBuilder: (context, index) {
                              final year = _amortizationSchedule[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: currentLoanType["color"].withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${getText("year")} ${year['year']}",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "₹${year['balance'].toStringAsFixed(0)}",
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
                                              Text("₹${year['totalPrincipal'].toStringAsFixed(0)}",
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(getText("interestPaid"), style: const TextStyle(fontSize: 11)),
                                              Text("₹${year['totalInterest'].toStringAsFixed(0)}",
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // EMI Tips
              const SizedBox(height: 16),
              _buildEMITips(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEMIChart() {
    double total = double.tryParse(_totalAmount) ?? 0;
    double principal = double.tryParse(_principalController.text) ?? 0;
    double interest = double.tryParse(_totalInterest) ?? 0;

    return Column(
      children: [
        const Text(
          "EMI Breakdown",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
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
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            value: principal / total,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${((principal / total) * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            value: interest / total,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${((interest / total) * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(width: 4),
            const Text("Principal", style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(width: 4),
            const Text("Interest", style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildEMITips() {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(tip["icon"]!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tip["tip"]!,
                    style: const TextStyle(fontSize: 12),
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