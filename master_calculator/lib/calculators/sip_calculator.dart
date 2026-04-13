import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/gradient_button.dart';

class SIPCalculator extends StatefulWidget {
  const SIPCalculator({super.key});

  @override
  State<SIPCalculator> createState() => _SIPCalculatorState();
}

class _SIPCalculatorState extends State<SIPCalculator> with SingleTickerProviderStateMixin {
  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  String _totalInvestment = "0";
  String _estimatedReturns = "0";
  String _totalValue = "0";
  String _language = "English";
  String _frequency = "Monthly";
  int _selectedRiskProfile = 1; // 0: Low, 1: Moderate, 2: High
  bool _isLoading = false;
  bool _showGoalPlanning = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> _yearlyProjection = [];

  // Risk profile configurations
  final List<Map<String, dynamic>> _riskProfiles = [
    {"name": "Low Risk", "rate": 8.0, "color": const Color(0xFF10B981), "icon": Icons.shield},
    {"name": "Moderate Risk", "rate": 12.0, "color": const Color(0xFFF59E0B), "icon": Icons.bar_chart},
    {"name": "High Risk", "rate": 15.0, "color": const Color(0xFFEF4444), "icon": Icons.trending_up},
  ];

  // Frequency multipliers
  final Map<String, int> _frequencyMultiplier = {
    "Monthly": 1,
    "Quarterly": 3,
    "Half-Yearly": 6,
    "Yearly": 12,
  };

  // Language translations
  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "SIP Calculator",
      "monthlyInvestment": "Monthly Investment",
      "expectedReturn": "Expected Return Rate (%)",
      "timePeriod": "Time Period (Years)",
      "goalAmount": "Goal Amount (Optional)",
      "calculate": "Calculate Returns",
      "totalInvestment": "Total Investment",
      "estimatedReturns": "Estimated Returns",
      "totalValue": "Total Value",
      "wealthGained": "Wealth Gained",
      "investmentFrequency": "Investment Frequency",
      "riskProfile": "Risk Profile",
      "goalPlanning": "Goal Planning",
      "monthlySIP": "Monthly SIP Needed",
      "yearlyProjection": "Year-wise Projection",
      "year": "Year",
      "investment": "Investment",
      "returns": "Returns",
      "value": "Value",
      "share": "Share Results",
      "copy": "Copy Results",
      "language": "Language",
      "powerOfCompounding": "Power of Compounding",
      "investedAmount": "Invested Amount",
      "wealthCreated": "Wealth Created",
      "tips": "Smart Investing Tips",
      "enterValid": "Please fill all fields correctly",
    },
    "Hindi": {
      "title": "एसआईपी कैलकुलेटर",
      "monthlyInvestment": "मासिक निवेश",
      "expectedReturn": "अपेक्षित रिटर्न दर (%)",
      "timePeriod": "समय अवधि (वर्ष)",
      "goalAmount": "लक्ष्य राशि (वैकल्पिक)",
      "calculate": "रिटर्न गणना करें",
      "totalInvestment": "कुल निवेश",
      "estimatedReturns": "अनुमानित रिटर्न",
      "totalValue": "कुल मूल्य",
      "wealthGained": "अर्जित धन",
      "investmentFrequency": "निवेश आवृत्ति",
      "riskProfile": "जोखिम प्रोफ़ाइल",
      "goalPlanning": "लक्ष्य योजना",
      "monthlySIP": "आवश्यक मासिक एसआईपी",
      "yearlyProjection": "वार्षिक अनुमान",
      "year": "वर्ष",
      "investment": "निवेश",
      "returns": "रिटर्न",
      "value": "मूल्य",
      "share": "परिणाम साझा करें",
      "copy": "परिणाम कॉपी करें",
      "language": "भाषा",
      "powerOfCompounding": "चक्रवृद्धि की शक्ति",
      "investedAmount": "निवेशित राशि",
      "wealthCreated": "अर्जित धन",
      "tips": "स्मार्ट निवेश युक्तियाँ",
      "enterValid": "कृपया सभी फ़ील्ड सही भरें",
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

    // Set default values
    _monthlyController.text = "5000";
    _rateController.text = "12";
    _yearsController.text = "10";
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthlyController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _calculate() {
    double monthly = double.tryParse(_monthlyController.text) ?? 0;
    double annualRate = _getRiskAdjustedRate();
    double years = double.tryParse(_yearsController.text) ?? 0;

    if (monthly > 0 && annualRate > 0 && years > 0) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 100), () {
        double rate = annualRate / 100 / 12;
        double months = years * 12;

        double futureValue = monthly * ((pow(1 + rate, months) - 1) / rate) * (1 + rate);
        double totalInvestment = monthly * months;
        double estimatedReturns = futureValue - totalInvestment;

        setState(() {
          _totalInvestment = totalInvestment.toStringAsFixed(2);
          _estimatedReturns = estimatedReturns.toStringAsFixed(2);
          _totalValue = futureValue.toStringAsFixed(2);
          _isLoading = false;
        });

        _calculateYearlyProjection(monthly, annualRate, years);
        HapticFeedback.mediumImpact();
      });
    } else {
      _showError(getText("enterValid"));
    }
  }

  void _calculateYearlyProjection(double monthly, double annualRate, double years) {
    List<Map<String, dynamic>> projection = [];
    double totalInvestment = 0;
    double rate = annualRate / 100 / 12;

    for (int year = 1; year <= years.toInt(); year++) {
      int months = year * 12;
      double futureValue = monthly * ((pow(1 + rate, months) - 1) / rate) * (1 + rate);
      double invested = monthly * months;
      double returns = futureValue - invested;

      projection.add({
        'year': year,
        'investment': invested,
        'returns': returns,
        'value': futureValue,
      });
    }

    setState(() {
      _yearlyProjection = projection;
    });
  }

  double _getRiskAdjustedRate() {
    if (_selectedRiskProfile == 0) return _riskProfiles[0]["rate"];
    if (_selectedRiskProfile == 1) return _riskProfiles[1]["rate"];
    return _riskProfiles[2]["rate"];
  }

  void _calculateGoal() {
    double goal = double.tryParse(_goalController.text) ?? 0;
    double annualRate = _getRiskAdjustedRate();
    double years = double.tryParse(_yearsController.text) ?? 0;

    if (goal > 0 && annualRate > 0 && years > 0) {
      double rate = annualRate / 100 / 12;
      double months = years * 12;

      // Calculate required monthly SIP to achieve goal
      double requiredSIP = goal * rate / ((pow(1 + rate, months) - 1) * (1 + rate));

      setState(() {
        _monthlyController.text = requiredSIP.toStringAsFixed(0);
      });
      _calculate();
    }
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  void _toggleGoalPlanning() {
    setState(() {
      _showGoalPlanning = !_showGoalPlanning;
      if (!_showGoalPlanning) {
        _goalController.clear();
      }
    });
  }

  void _copyResult() {
    String result = """
${getText("title")} Results:
${getText("monthlyInvestment")}: ₹${_monthlyController.text}
${getText("expectedReturn")}: ${_getRiskAdjustedRate()}%
${getText("timePeriod")}: ${_yearsController.text} years
${getText("totalInvestment")}: ₹$_totalInvestment
${getText("estimatedReturns")}: ₹$_estimatedReturns
${getText("totalValue")}: ₹$_totalValue
    """;
    Clipboard.setData(ClipboardData(text: result));
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
    final currentRisk = _riskProfiles[_selectedRiskProfile];
    final accentColor = currentRisk["color"];

    double totalInv = double.tryParse(_totalInvestment) ?? 0;
    double totalRet = double.tryParse(_estimatedReturns) ?? 0;
    double totalVal = double.tryParse(_totalValue) ?? 0;
    double investedPercent = totalVal > 0 ? (totalInv / totalVal * 100) : 0;
    double returnsPercent = totalVal > 0 ? (totalRet / totalVal * 100) : 0;

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
          if (_totalValue != "0")
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _copyResult,
              tooltip: getText("share"),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Risk Profile Selector
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getText("riskProfile"),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_riskProfiles.length, (index) {
                      final risk = _riskProfiles[index];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRiskProfile = index;
                                _rateController.text = risk["rate"].toString();
                              });
                              _calculate();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRiskProfile == index
                                    ? risk["color"].withOpacity(0.2)
                                    : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedRiskProfile == index
                                      ? risk["color"]
                                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(risk["icon"],
                                      color: _selectedRiskProfile == index ? risk["color"] : null,
                                      size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    risk["name"],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _selectedRiskProfile == index ? risk["color"] : null,
                                      fontWeight: _selectedRiskProfile == index ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Input Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _monthlyController,
                      decoration: InputDecoration(
                        labelText: getText("monthlyInvestment"),
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixText: "₹",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rateController,
                      decoration: InputDecoration(
                        labelText: getText("expectedReturn"),
                        prefixIcon: const Icon(Icons.trending_up),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixText: "%",
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _yearsController,
                      decoration: InputDecoration(
                        labelText: getText("timePeriod"),
                        prefixIcon: const Icon(Icons.timeline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixText: "yrs",
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    // Goal Planning Toggle
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(getText("goalPlanning")),
                      subtitle: const Text("Calculate SIP needed to reach your goal"),
                      value: _showGoalPlanning,
                      onChanged: (_) => _toggleGoalPlanning(),
                      activeColor: accentColor,
                    ),

                    if (_showGoalPlanning) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _goalController,
                        decoration: InputDecoration(
                          labelText: getText("goalAmount"),
                          prefixIcon: const Icon(Icons.flag),  // Changed from Icons.target to Icons.flag
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixText: "₹",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _calculateGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Calculate Required SIP"),
                      ),
                    ],
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

            if (_totalValue != "0") ...[
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
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.trending_up, color: accentColor, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getText("powerOfCompounding"),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${getText("timePeriod")}: ${_yearsController.text} years",
                                    style: TextStyle(fontSize: 12, color: accentColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),

                        // Wealth Gained Highlight
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentColor, accentColor.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                getText("wealthGained"),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "₹$_estimatedReturns",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Investment Breakdown Chart
                        Column(
                          children: [
                            Text(
                              getText("powerOfCompounding"),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                                value: investedPercent / 100,
                                                strokeWidth: 12,
                                                backgroundColor: Colors.grey.shade200,
                                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${investedPercent.toStringAsFixed(1)}%",
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                                Text(getText("investedAmount"), style: const TextStyle(fontSize: 10)),
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
                                                value: returnsPercent / 100,
                                                strokeWidth: 12,
                                                backgroundColor: Colors.grey.shade200,
                                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${returnsPercent.toStringAsFixed(1)}%",
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                                Text(getText("wealthCreated"), style: const TextStyle(fontSize: 10)),
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
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),

                        // Results
                        _buildResultCard(getText("totalInvestment"), "₹$_totalInvestment", Colors.blue, Icons.account_balance_wallet),
                        const SizedBox(height: 12),
                        _buildResultCard(getText("estimatedReturns"), "₹$_estimatedReturns", const Color(0xFF10B981), Icons.trending_up),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildResultCard(getText("totalValue"), "₹$_totalValue", Colors.white, Icons.account_balance, isMainResult: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Yearly Projection
              if (_yearlyProjection.isNotEmpty) ...[
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
                            Icon(Icons.calendar_today, color: accentColor),
                            const SizedBox(width: 8),
                            Text(
                              getText("yearlyProjection"),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 350,
                          child: ListView.builder(
                            itemCount: _yearlyProjection.length,
                            itemBuilder: (context, index) {
                              final year = _yearlyProjection[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.05),
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
                                          "₹${year['value'].toStringAsFixed(0)}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
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
                                              Text(getText("investment"), style: const TextStyle(fontSize: 11)),
                                              Text("₹${year['investment'].toStringAsFixed(0)}",
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(getText("returns"), style: const TextStyle(fontSize: 11)),
                                              Text("₹${year['returns'].toStringAsFixed(0)}",
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Progress bar for each year
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: year['value'] / _yearlyProjection.last['value'],
                                      backgroundColor: Colors.grey.shade200,
                                      color: accentColor,
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

              // Smart Investing Tips
              const SizedBox(height: 16),
              _buildTips(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, Color color, IconData icon, {bool isMainResult = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isMainResult ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isMainResult ? FontWeight.w600 : FontWeight.normal,
                color: isMainResult ? Colors.white : null,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isMainResult ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    List<Map<String, String>> tips = _language == "English"
        ? [
      {"icon": "📈", "tip": "Start early to benefit from the power of compounding"},
      {"icon": "💰", "tip": "Increase your SIP amount annually by 10-15%"},
      {"icon": "🎯", "tip": "Set clear financial goals before investing"},
      {"icon": "📊", "tip": "Diversify your investments across different asset classes"},
      {"icon": "🔄", "tip": "Review and rebalance your portfolio annually"},
      {"icon": "💡", "tip": "Stay invested for long term to maximize returns"},
    ]
        : [
      {"icon": "📈", "tip": "चक्रवृद्धि की शक्ति से लाभ उठाने के लिए जल्दी शुरू करें"},
      {"icon": "💰", "tip": "अपनी एसआईपी राशि सालाना 10-15% बढ़ाएं"},
      {"icon": "🎯", "tip": "निवेश से पहले स्पष्ट वित्तीय लक्ष्य निर्धारित करें"},
      {"icon": "📊", "tip": "विभिन्न परिसंपत्ति वर्गों में अपने निवेश में विविधता लाएं"},
      {"icon": "🔄", "tip": "अपने पोर्टफोलियो की सालाना समीक्षा और पुनर्संतुलन करें"},
      {"icon": "💡", "tip": "रिटर्न को अधिकतम करने के लिए दीर्घकालिक निवेश करें"},
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