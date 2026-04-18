import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/gradient_button.dart';
import '../services/history_service.dart';

class DiscountCalculator extends StatefulWidget {
  const DiscountCalculator({super.key});

  @override
  State<DiscountCalculator> createState() => _DiscountCalculatorState();
}

class _DiscountCalculatorState extends State<DiscountCalculator> with SingleTickerProviderStateMixin {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  String _savedAmount = "0";
  String _finalPrice = "0";
  String _priceAfterDiscount = "0";
  String _taxAmount = "0";
  String _totalSavings = "0";
  String _language = "English";
  String _discountType = "Percentage";
  int _selectedIndex = 0;
  bool _isLoading = false;
  final GlobalKey _resultKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "Discount Calculator",
      "originalPrice": "Original Price",
      "discount": "Discount",
      "percentage": "Percentage (%)",
      "fixedAmount": "Fixed Amount (₹)",
      "tax": "Tax Rate (%)",
      "calculate": "Calculate Discount",
      "youSave": "You Save",
      "finalPrice": "Final Price",
      "priceAfterDiscount": "Price After Discount",
      "taxAmount": "Tax Amount",
      "totalSavings": "Total Savings",
      "effectiveDiscount": "Effective Discount",
      "share": "Share Results",
      "copy": "Copy Results",
      "language": "Language",
      "basic": "Basic",
      "advanced": "Advanced",
      "enterValidAmount": "Please enter valid amount",
      "savingsTip": "You're saving",
      "originalPriceTag": "Original Price",
      "discountTag": "Discount Applied",
      "taxTag": "Tax Applied",
      "finalPriceTag": "You Pay",
      "savedToHistory": "Saved to history",
      "shareTitle": "Discount Calculation",
      "shareMessage": "Check out my discount calculation from Master Calculator",
    },
    "Hindi": {
      "title": "डिस्काउंट कैलकुलेटर",
      "originalPrice": "मूल कीमत",
      "discount": "छूट",
      "percentage": "प्रतिशत (%)",
      "fixedAmount": "निर्धारित राशि (₹)",
      "tax": "कर दर (%)",
      "calculate": "छूट गणना करें",
      "youSave": "आप बचाते हैं",
      "finalPrice": "अंतिम कीमत",
      "priceAfterDiscount": "छूट के बाद कीमत",
      "taxAmount": "कर राशि",
      "totalSavings": "कुल बचत",
      "effectiveDiscount": "प्रभावी छूट",
      "share": "परिणाम साझा करें",
      "copy": "परिणाम कॉपी करें",
      "language": "भाषा",
      "basic": "सरल",
      "advanced": "उन्नत",
      "enterValidAmount": "कृपया वैध राशि दर्ज करें",
      "savingsTip": "आप बचा रहे हैं",
      "originalPriceTag": "मूल कीमत",
      "discountTag": "छूट लागू",
      "taxTag": "कर लागू",
      "finalPriceTag": "आप भुगतान करें",
      "savedToHistory": "इतिहास में सहेजा गया",
      "shareTitle": "छूट गणना",
      "shareMessage": "मास्टर कैलकुलेटर से मेरी छूट गणना देखें",
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _calculate() async {
    double price = double.tryParse(_priceController.text) ?? 0;
    double discountValue = double.tryParse(_discountController.text) ?? 0;
    double taxRate = double.tryParse(_taxController.text) ?? 0;

    if (price <= 0) {
      _showError(getText("enterValidAmount"));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100));

    double discountAmount = 0;

    if (_discountType == "Percentage") {
      discountAmount = price * (discountValue / 100);
    } else {
      discountAmount = discountValue;
    }

    double priceAfterDiscount = price - discountAmount;
    double taxAmount = priceAfterDiscount * (taxRate / 100);
    double finalPrice = priceAfterDiscount + taxAmount;
    double totalSavings = discountAmount;

    setState(() {
      _savedAmount = _formatCurrency(discountAmount);
      _priceAfterDiscount = _formatCurrency(priceAfterDiscount);
      _taxAmount = _formatCurrency(taxAmount);
      _finalPrice = _formatCurrency(finalPrice);
      _totalSavings = _formatCurrency(totalSavings);
      _isLoading = false;
    });

    // Save to history
    await HistoryService.addToHistory(
      expression: "Original: ${_formatCurrency(price)}, Discount: ${_discountType == "Percentage" ? "$discountValue%" : _formatCurrency(discountValue)}",
      result: "Final Price: $_finalPrice, You Save: $_savedAmount",
      calculatorType: "Discount",
    );

    HapticFeedback.mediumImpact();
    _showSnackBar(getText("savedToHistory"));
  }

  String _formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(2)}";
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  void _toggleDiscountType() {
    setState(() {
      _discountType = _discountType == "Percentage" ? "Fixed Amount" : "Percentage";
      _discountController.clear();
    });
  }

  void _copyResults() {
    String results = """
${getText("title")} Results:
${getText("originalPrice")}: ${_formatCurrency(double.tryParse(_priceController.text) ?? 0)}
${getText("discount")}: ${_discountController.text}${_discountType == "Percentage" ? "%" : ""}
${getText("youSave")}: $_savedAmount
${getText("finalPrice")}: $_finalPrice
${getText("totalSavings")}: $_totalSavings
    """;
    Clipboard.setData(ClipboardData(text: results));
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
      final File imagePath = await File('${directory.path}/discount_result.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
${getText("shareTitle")}:
${getText("originalPrice")}: ${_formatCurrency(double.tryParse(_priceController.text) ?? 0)}
${getText("discount")}: ${_discountController.text}${_discountType == "Percentage" ? "%" : ""}
${getText("youSave")}: $_savedAmount
${getText("finalPrice")}: $_finalPrice
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
      String results = """
${getText("title")} Results:
${getText("originalPrice")}: ${_formatCurrency(double.tryParse(_priceController.text) ?? 0)}
${getText("discount")}: ${_discountController.text}${_discountType == "Percentage" ? "%" : ""}
${getText("youSave")}: $_savedAmount
${getText("finalPrice")}: $_finalPrice
      """;
      await Share.share(results);
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
    final price = double.tryParse(_priceController.text) ?? 0;
    final discountPercent = _discountType == "Percentage"
        ? (double.tryParse(_discountController.text) ?? 0)
        : (price > 0 ? ((double.tryParse(_discountController.text) ?? 0) / price * 100) : 0);

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
          if (_savedAmount != "0") ...[
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
            // Mode Selector
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeButton(getText("basic"), 0, isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeButton(getText("advanced"), 1, isDark),
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
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: getText("originalPrice"),
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Discount Type Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _discountType == "Percentage" ? null : _toggleDiscountType,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _discountType == "Percentage"
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                getText("percentage"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _discountType == "Percentage"
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _discountType == "Fixed Amount" ? null : _toggleDiscountType,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _discountType == "Fixed Amount"
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                getText("fixedAmount"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _discountType == "Fixed Amount"
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _discountController,
                      decoration: InputDecoration(
                        labelText: "${getText("discount")} (${_discountType == "Percentage" ? "%" : "₹"})",
                        prefixIcon: const Icon(Icons.local_offer),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    if (_selectedIndex == 1) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _taxController,
                        decoration: InputDecoration(
                          labelText: getText("tax"),
                          prefixIcon: const Icon(Icons.receipt),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            GradientButton(
              text: getText("calculate"),
              icon: Icons.calculate,
              isLoading: _isLoading,
              onPressed: _calculate,
            ),

            if (_savedAmount != "0") ...[
              const SizedBox(height: 20),

              RepaintBoundary(
                key: _resultKey,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Savings Ring Chart
                          _buildSavingsRing(price, discountPercent.toDouble()),

                          const SizedBox(height: 20),

                          // Main Results
                          _buildResultCard(getText("youSave"), _savedAmount, Colors.green, Icons.savings),
                          const SizedBox(height: 12),

                          _buildResultCard(getText("priceAfterDiscount"), _priceAfterDiscount, const Color(0xFF6366F1), Icons.currency_rupee),

                          if (_selectedIndex == 1 && _taxAmount != "0") ...[
                            const SizedBox(height: 12),
                            _buildResultCard(getText("taxAmount"), _taxAmount, Colors.orange, Icons.receipt),
                          ],

                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildResultCard(getText("finalPrice"), _finalPrice, Colors.white, Icons.payment, isMainResult: true),
                          ),

                          if (_selectedIndex == 1) ...[
                            const SizedBox(height: 12),
                            _buildResultCard(getText("totalSavings"), _totalSavings, const Color(0xFF8B5CF6), Icons.trending_down),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Savings Tip Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.1),
                      const Color(0xFF059669).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, color: Color(0xFF10B981), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${getText("savingsTip")} ${_savedAmount}!",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSavingsMessage(discountPercent.toDouble()),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Price Comparison Slider
            if (_savedAmount != "0" && price > 0)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _buildPriceComparison(price, double.tryParse(_finalPrice.replaceAll('₹', '')) ?? 0),
              ),

            // Discount Tips
            const SizedBox(height: 16),
            _buildDiscountTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, int index, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? const Color(0xFF6366F1)
              : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedIndex == index
                ? const Color(0xFF6366F1)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: FontWeight.w500,
          ),
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

  Widget _buildSavingsRing(double price, double discountPercent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: discountPercent / 100,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            Column(
              children: [
                Text(
                  "${discountPercent.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getText("effectiveDiscount"),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "${getText("originalPriceTag")}: ${_formatCurrency(price)}",
          style: TextStyle(
            fontSize: 12,
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceComparison(double original, double finalPrice) {
    double percentage = ((original - finalPrice) / original * 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Price Comparison",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFEF4444),
                const Color(0xFFF59E0B),
                const Color(0xFF10B981),
              ],
              stops: [0, percentage / 100, 1],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _formatCurrency(original),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _formatCurrency(finalPrice),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountTips() {
    List<Map<String, String>> tips = _language == "English"
        ? [
      {"icon": "🎯", "tip": "Compare prices across multiple stores before buying"},
      {"icon": "📧", "tip": "Subscribe to newsletters for exclusive discount codes"},
      {"icon": "💳", "tip": "Use cashback credit cards for additional savings"},
      {"icon": "🛍️", "tip": "Shop during seasonal sales for maximum discounts"},
      {"icon": "🎫", "tip": "Look for coupon codes before checking out"},
      {"icon": "📱", "tip": "Use mobile apps for app-exclusive deals"},
    ]
        : [
      {"icon": "🎯", "tip": "खरीदने से पहले कई स्टोर में कीमतों की तुलना करें"},
      {"icon": "📧", "tip": "विशेष छूट कोड के लिए न्यूज़लेटर की सदस्यता लें"},
      {"icon": "💳", "tip": "अतिरिक्त बचत के लिए कैशबैक क्रेडिट कार्ड का उपयोग करें"},
      {"icon": "🛍️", "tip": "अधिकतम छूट के लिए मौसमी बिक्री के दौरान खरीदारी करें"},
      {"icon": "🎫", "tip": "चेकआउट से पहले कूपन कोड देखें"},
      {"icon": "📱", "tip": "ऐप-एक्सक्लूसिव डील के लिए मोबाइल ऐप का उपयोग करें"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Smart Shopping Tips",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

  String _getSavingsMessage(double discountPercent) {
    if (discountPercent >= 50) {
      return _language == "English"
          ? "🎉 Amazing deal! You're saving more than half!"
          : "🎉 अद्भुत सौदा! आप आधे से अधिक बचा रहे हैं!";
    } else if (discountPercent >= 30) {
      return _language == "English"
          ? "👍 Great discount! Smart shopping decision!"
          : "👍 बड़ी छूट! स्मार्ट शॉपिंग निर्णय!";
    } else if (discountPercent >= 10) {
      return _language == "English"
          ? "💰 Good savings! Every rupee counts!"
          : "💰 अच्छी बचत! हर रुपया मायने रखता है!";
    } else {
      return _language == "English"
          ? "💡 Look for coupons or wait for sales for better deals!"
          : "💡 बेहतर सौदों के लिए कूपन देखें या बिक्री की प्रतीक्षा करें!";
    }
  }
}