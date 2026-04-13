import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import '../widgets/gradient_button.dart';

class GSTCalculator extends StatefulWidget {
  const GSTCalculator({super.key});

  @override
  State<GSTCalculator> createState() => _GSTCalculatorState();
}

class _GSTCalculatorState extends State<GSTCalculator> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  String _selectedType = "Inclusive";
  double _gstRate = 18;
  String _gstAmount = "0";
  String _totalAmount = "0";
  String _baseAmount = "0";
  String _language = "English";
  bool _isLoading = false;
  final GlobalKey _resultKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // HSN Code suggestions for different product categories
  final Map<String, List<Map<String, dynamic>>> _hsnCodes = {
    "0%": [
      {"code": "0401", "description": "Fresh milk and cream"},
      {"code": "1006", "description": "Rice (other than branded)"},
      {"code": "1207", "description": "Fresh vegetables"},
    ],
    "5%": [
      {"code": "0407", "description": "Eggs"},
      {"code": "0801", "description": "Cashew nuts"},
      {"code": "1905", "description": "Bread and biscuits"},
      {"code": "2106", "description": "Packed food items"},
    ],
    "12%": [
      {"code": "0406", "description": "Butter and cheese"},
      {"code": "0802", "description": "Dry fruits"},
      {"code": "2105", "description": "Ice cream"},
      {"code": "3304", "description": "Cosmetics"},
    ],
    "18%": [
      {"code": "1704", "description": "Sugar confectionery"},
      {"code": "2202", "description": "Soft drinks"},
      {"code": "3305", "description": "Hair oil and shampoo"},
      {"code": "8516", "description": "Electronic appliances"},
    ],
    "28%": [
      {"code": "2402", "description": "Cigarettes"},
      {"code": "3303", "description": "Perfumes"},
      {"code": "8703", "description": "Motor vehicles"},
      {"code": "9504", "description": "Gaming devices"},
    ],
  };

  // Language translations
  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "GST Calculator",
      "amount": "Amount",
      "gstType": "GST Type",
      "inclusive": "Inclusive (GST included)",
      "exclusive": "Exclusive (GST extra)",
      "gstRate": "GST Rate (%)",
      "calculate": "Calculate GST",
      "gstAmount": "GST Amount",
      "totalAmount": "Total Amount",
      "baseAmount": "Base Amount",
      "share": "Share Result",
      "copy": "Copy Result",
      "language": "Language",
      "hsnCode": "HSN Code",
      "description": "Description",
      "suggestedHSN": "Suggested HSN Codes",
      "gstComposition": "GST Composition",
      "cgst": "CGST",
      "sgst": "SGST",
      "igst": "IGST",
      "shareTitle": "GST Calculator Result",
      "shareMessage": "Check out my GST calculation",
      "shareSuccess": "Shared successfully!",
    },
    "Hindi": {
      "title": "जीएसटी कैलकुलेटर",
      "amount": "राशि",
      "gstType": "जीएसटी प्रकार",
      "inclusive": "समावेशी (जीएसटी शामिल)",
      "exclusive": "अनन्य (जीएसटी अतिरिक्त)",
      "gstRate": "जीएसटी दर (%)",
      "calculate": "जीएसटी गणना करें",
      "gstAmount": "जीएसटी राशि",
      "totalAmount": "कुल राशि",
      "baseAmount": "मूल राशि",
      "share": "परिणाम साझा करें",
      "copy": "परिणाम कॉपी करें",
      "language": "भाषा",
      "hsnCode": "एचएसएन कोड",
      "description": "विवरण",
      "suggestedHSN": "सुझाए गए एचएसएन कोड",
      "gstComposition": "जीएसटी संरचना",
      "cgst": "सीजीएसटी",
      "sgst": "एसजीएसटी",
      "igst": "आईजीएसटी",
      "shareTitle": "जीएसटी कैलकुलेटर परिणाम",
      "shareMessage": "मेरी जीएसटी गणना देखें",
      "shareSuccess": "सफलतापूर्वक साझा किया गया!",
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
    _amountController.dispose();
    super.dispose();
  }

  void _calculate() {
    double amount = double.tryParse(_amountController.text) ?? 0;

    if (amount > 0) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 100), () {
        double gst = 0;
        double total = 0;
        double base = 0;

        if (_selectedType == "Inclusive") {
          base = amount / (1 + _gstRate / 100);
          gst = amount - base;
          total = amount;
        } else {
          base = amount;
          gst = amount * (_gstRate / 100);
          total = amount + gst;
        }

        setState(() {
          _baseAmount = base.toStringAsFixed(2);
          _gstAmount = gst.toStringAsFixed(2);
          _totalAmount = total.toStringAsFixed(2);
          _isLoading = false;
        });

        HapticFeedback.mediumImpact();
      });
    } else {
      _showError("Please enter a valid amount");
    }
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  void _copyResult() {
    String result = """
${getText("title")} Results:
${getText("amount")}: ₹${_amountController.text}
${getText("gstType")}: ${_selectedType == "Inclusive" ? getText("inclusive") : getText("exclusive")}
${getText("gstRate")}: $_gstRate%
${getText("baseAmount")}: ₹$_baseAmount
${getText("gstAmount")}: ₹$_gstAmount
${getText("totalAmount")}: ₹$_totalAmount
    """;
    Clipboard.setData(ClipboardData(text: result));
    _showSnackBar(getText("copy"));
  }

  Future<void> _captureAndShare() async {
    try {
      setState(() => _isLoading = true);

      final RenderRepaintBoundary boundary = _resultKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final Directory directory = await getTemporaryDirectory();
      final File imagePath = await File('${directory.path}/gst_result.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
${getText("shareTitle")}:
${getText("amount")}: ₹${_amountController.text}
${getText("gstRate")}: $_gstRate%
${getText("gstAmount")}: ₹$_gstAmount
${getText("totalAmount")}: ₹$_totalAmount
---
${getText("shareMessage")}
Download Master Calculator App for more features!
      """;

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: shareText,
      );

      setState(() => _isLoading = false);
      _showSnackBar(getText("shareSuccess"));
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to capture screenshot");
    }
  }

  double _getCGST() {
    double gst = double.tryParse(_gstAmount) ?? 0;
    return gst / 2;
  }

  double _getSGST() {
    double gst = double.tryParse(_gstAmount) ?? 0;
    return gst / 2;
  }

  double _getIGST() {
    return double.tryParse(_gstAmount) ?? 0;
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
    final accentColor = const Color(0xFF6366F1);

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
          if (_gstAmount != "0")
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _captureAndShare,
              tooltip: getText("share"),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: getText("amount"),
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: getText("gstType"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Inclusive", child: Text("Inclusive (GST included)")),
                        DropdownMenuItem(value: "Exclusive", child: Text("Exclusive (GST extra)")),
                      ],
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<double>(
                      value: _gstRate,
                      decoration: InputDecoration(
                        labelText: getText("gstRate"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text("0%")),
                        DropdownMenuItem(value: 5.0, child: Text("5%")),
                        DropdownMenuItem(value: 12.0, child: Text("12%")),
                        DropdownMenuItem(value: 18.0, child: Text("18%")),
                        DropdownMenuItem(value: 28.0, child: Text("28%")),
                      ],
                      onChanged: (value) => setState(() => _gstRate = value!),
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

            if (_gstAmount != "0") ...[
              const SizedBox(height: 20),

              // Results Card (Capturable)
              RepaintBoundary(
                key: _resultKey,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withOpacity(0.05),
                            accentColor.withOpacity(0.02),
                          ],
                        ),
                      ),
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
                                  child: Icon(Icons.receipt, color: accentColor, size: 30),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getText("title"),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "GST ${_gstRate.toStringAsFixed(0)}%",
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(),

                            // Results
                            _buildResultRow(getText("baseAmount"), "₹$_baseAmount", Colors.blue),
                            const SizedBox(height: 12),
                            _buildResultRow(getText("gstAmount"), "₹$_gstAmount", const Color(0xFF8B5CF6)),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _buildResultRow(getText("totalAmount"), "₹$_totalAmount", Colors.white, isMainResult: true),
                            ),

                            const SizedBox(height: 20),
                            const Divider(),

                            // GST Composition
                            const SizedBox(height: 8),
                            Text(
                              getText("gstComposition"),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompositionCard("CGST", "₹${_getCGST().toStringAsFixed(2)}", const Color(0xFF6366F1)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildCompositionCard("SGST", "₹${_getSGST().toStringAsFixed(2)}", const Color(0xFF10B981)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildCompositionCard("IGST", "₹${_getIGST().toStringAsFixed(2)}", const Color(0xFFF59E0B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // HSN Code Suggestions
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
                          Icon(Icons.code, color: accentColor),
                          const SizedBox(width: 8),
                          Text(
                            getText("suggestedHSN"),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(_hsnCodes[_gstRate.toString() + "%"] ?? _hsnCodes["18%"]!).map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item["code"],
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item["description"],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // GST Tips
              _buildGSTTips(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color, {bool isMainResult = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isMainResult ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isMainResult ? FontWeight.w600 : FontWeight.normal,
              color: isMainResult ? Colors.white : null,
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

  Widget _buildCompositionCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildGSTTips() {
    List<Map<String, String>> tips = _language == "English"
        ? [
      {"icon": "📋", "tip": "Always keep GST invoices for input tax credit"},
      {"icon": "📅", "tip": "File GST returns on time to avoid penalties"},
      {"icon": "💳", "tip": "Use digital payments for better compliance"},
      {"icon": "🔍", "tip": "Verify GST numbers on GST portal"},
      {"icon": "📊", "tip": "Maintain proper books of accounts"},
      {"icon": "🎯", "tip": "Register for GST if turnover exceeds threshold"},
    ]
        : [
      {"icon": "📋", "tip": "इनपुट टैक्स क्रेडिट के लिए हमेशा जीएसटी चालान रखें"},
      {"icon": "📅", "tip": "जुर्माने से बचने के लिए समय पर जीएसटी रिटर्न दाखिल करें"},
      {"icon": "💳", "tip": "बेहतर अनुपालन के लिए डिजिटल भुगतान का उपयोग करें"},
      {"icon": "🔍", "tip": "जीएसटी पोर्टल पर जीएसटी नंबर सत्यापित करें"},
      {"icon": "📊", "tip": "लेखा पुस्तकों का उचित रखरखाव करें"},
      {"icon": "🎯", "tip": "यदि टर्नओवर सीमा से अधिक है तो जीएसटी पंजीकरण कराएं"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "GST Compliance Tips",
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
}