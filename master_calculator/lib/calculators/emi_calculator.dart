import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmiCalculator extends StatefulWidget {
  const EmiCalculator({super.key});

  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends State<EmiCalculator> with SingleTickerProviderStateMixin {
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();

  String _emi = "0";
  String _totalInterest = "0";
  String _totalAmount = "0";
  bool _isLoading = false;
  String _language = "English";
  int _selectedLoanType = 0;

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
      "balance": "Balance",
      "share": "Share Results",
      "copy": "Results Copied!",
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
      "copy": "कॉपी हो गया!",
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

  void _calculateEMI() {
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
      });
      _animationController.forward(from: 0);
      _calculateAmortization(p, r, t, emi);
    }
  }

  void _calculateAmortization(double principal, double monthlyRate, double months, double emi) {
    List<Map<String, dynamic>> schedule = [];
    double balance = principal;
    double totalPrincipalPaid = 0;
    double totalInterestPaid = 0;

    for (int i = 1; i <= months.toInt(); i++) {
      double interestPayment = balance * monthlyRate;
      double principalPayment = emi - interestPayment;
      balance -= principalPayment;
      totalPrincipalPaid += principalPayment;
      totalInterestPaid += interestPayment;

      if (i % 12 == 0 || i == months.toInt()) {
        schedule.add({
          'year': (i / 12).ceil(),
          'totalPrincipal': totalPrincipalPaid,
          'totalInterest': totalInterestPaid,
          'balance': balance > 0 ? balance : 0,
        });
      }
    }
    setState(() => _amortizationSchedule = schedule);
  }

  @override
  Widget build(BuildContext context) {
    final loan = _loanTypes[_selectedLoanType];
    return Scaffold(
      appBar: AppBar(
        title: Text(getText("title")),
        actions: [
          TextButton(
            onPressed: () => setState(() => _language = _language == "English" ? "Hindi" : "English"),
            child: Text(_language == "English" ? "हिंदी" : "EN", style: const TextStyle(color: Colors.blue)),
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () {
            Clipboard.setData(ClipboardData(text: "EMI: ₹$_emi\nTotal: ₹$_totalAmount"));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getText("copy"))));
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLoanTypeSelector(),
            const SizedBox(height: 20),
            _buildInputSection(loan),
            const SizedBox(height: 25),
            ScaleTransition(scale: _scaleAnimation, child: _buildResultSection(loan)),
            const SizedBox(height: 25),
            _buildAmortizationTable(loan),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTypeSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _loanTypes.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedLoanType == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(_loanTypes[index]["name"]),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  _selectedLoanType = index;
                  _rateSlider = _loanTypes[index]["minRate"];
                });
                _calculateEMI();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection(Map<String, dynamic> loan) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSliderRow(getText("principal"), "₹", _principalSlider, 10000, 10000000, (val) {
              setState(() => _principalSlider = val);
              _calculateEMI();
            }, loan["color"]),
            const Divider(height: 30),
            _buildSliderRow(getText("interestRate"), "%", _rateSlider, loan["minRate"], loan["maxRate"], (val) {
              setState(() => _rateSlider = val);
              _calculateEMI();
            }, loan["color"]),
            const Divider(height: 30),
            _buildSliderRow(getText("tenure"), "Y", _tenureSlider, 1, loan["maxTenure"].toDouble(), (val) {
              setState(() => _tenureSlider = val);
              _calculateEMI();
            }, loan["color"]),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, String unit, double value, double min, double max, Function(double) onChanged, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${value.toStringAsFixed(value > 100 ? 0 : 1)} $unit", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: value, min: min, max: max, activeColor: color, onChanged: onChanged),
      ],
    );
  }

  Widget _buildResultSection(Map<String, dynamic> loan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: loan["color"].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: loan["color"].withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(getText("monthlyEMI"), style: const TextStyle(fontSize: 16)),
          Text("₹$_emi", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: loan["color"])),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallResult(getText("totalInterest"), "₹$_totalInterest", Colors.red),
              _buildSmallResult(getText("totalAmount"), "₹$_totalAmount", Colors.green),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallResult(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildAmortizationTable(Map<String, dynamic> loan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getText("amortization"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._amortizationSchedule.map((data) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${getText("year")} ${data['year']}"),
              Text("Bal: ₹${data['balance'].toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }
}