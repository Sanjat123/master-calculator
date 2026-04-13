import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../widgets/gradient_button.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = "USD";
  String _toCurrency = "INR";
  String _result = "0";
  String _language = "English";
  List<String> _favoriteCurrencies = ["USD", "EUR", "GBP", "INR", "JPY"];
  List<String> _recentConversions = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Enhanced currency data with full names and flags
  final Map<String, Map<String, dynamic>> _currencies = {
    "USD": {"rate": 1.0, "name": "US Dollar", "symbol": "\$", "flag": "🇺🇸", "code": "USD"},
    "INR": {"rate": 83.5, "name": "Indian Rupee", "symbol": "₹", "flag": "🇮🇳", "code": "INR"},
    "EUR": {"rate": 0.92, "name": "Euro", "symbol": "€", "flag": "🇪🇺", "code": "EUR"},
    "GBP": {"rate": 0.79, "name": "British Pound", "symbol": "£", "flag": "🇬🇧", "code": "GBP"},
    "JPY": {"rate": 150.2, "name": "Japanese Yen", "symbol": "¥", "flag": "🇯🇵", "code": "JPY"},
    "CAD": {"rate": 1.36, "name": "Canadian Dollar", "symbol": "C\$", "flag": "🇨🇦", "code": "CAD"},
    "AUD": {"rate": 1.52, "name": "Australian Dollar", "symbol": "A\$", "flag": "🇦🇺", "code": "AUD"},
    "CNY": {"rate": 7.20, "name": "Chinese Yuan", "symbol": "¥", "flag": "🇨🇳", "code": "CNY"},
    "AED": {"rate": 3.67, "name": "UAE Dirham", "symbol": "د.إ", "flag": "🇦🇪", "code": "AED"},
    "SAR": {"rate": 3.75, "name": "Saudi Riyal", "symbol": "﷼", "flag": "🇸🇦", "code": "SAR"},
    "CHF": {"rate": 0.91, "name": "Swiss Franc", "symbol": "CHF", "flag": "🇨🇭", "code": "CHF"},
    "SGD": {"rate": 1.35, "name": "Singapore Dollar", "symbol": "S\$", "flag": "🇸🇬", "code": "SGD"},
    "NZD": {"rate": 1.65, "name": "New Zealand Dollar", "symbol": "NZ\$", "flag": "🇳🇿", "code": "NZD"},
    "MXN": {"rate": 16.80, "name": "Mexican Peso", "symbol": "\$", "flag": "🇲🇽", "code": "MXN"},
    "BRL": {"rate": 5.05, "name": "Brazilian Real", "symbol": "R\$", "flag": "🇧🇷", "code": "BRL"},
    "ZAR": {"rate": 18.50, "name": "South African Rand", "symbol": "R", "flag": "🇿🇦", "code": "ZAR"},
    "RUB": {"rate": 92.00, "name": "Russian Ruble", "symbol": "₽", "flag": "🇷🇺", "code": "RUB"},
    "KRW": {"rate": 1330.00, "name": "South Korean Won", "symbol": "₩", "flag": "🇰🇷", "code": "KRW"},
  };

  // Language translations
  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "Currency Converter",
      "amount": "Amount",
      "from": "From",
      "to": "To",
      "convert": "Convert",
      "result": "Converted Amount",
      "exchangeRate": "Exchange Rate",
      "favorites": "Favorite Currencies",
      "recent": "Recent Conversions",
      "swap": "Swap Currencies",
      "copy": "Copy Result",
      "share": "Share",
      "language": "Language",
      "enterAmount": "Enter amount",
      "invalidAmount": "Please enter a valid amount",
      "copied": "Copied to clipboard!",
      "historicalRates": "Historical Rates",
      "last30Days": "Last 30 Days Trend",
    },
    "Hindi": {
      "title": "मुद्रा परिवर्तक",
      "amount": "राशि",
      "from": "से",
      "to": "को",
      "convert": "बदलें",
      "result": "परिवर्तित राशि",
      "exchangeRate": "विनिमय दर",
      "favorites": "पसंदीदा मुद्राएं",
      "recent": "हाल के रूपांतरण",
      "swap": "मुद्राएं बदलें",
      "copy": "परिणाम कॉपी करें",
      "share": "साझा करें",
      "language": "भाषा",
      "enterAmount": "राशि दर्ज करें",
      "invalidAmount": "कृपया वैध राशि दर्ज करें",
      "copied": "क्लिपबोर्ड पर कॉपी किया गया!",
      "historicalRates": "ऐतिहासिक दरें",
      "last30Days": "पिछले 30 दिनों का रुझान",
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
    _loadRecentConversions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadRecentConversions() {
    // In a real app, load from SharedPreferences
    _recentConversions = [
      "100 USD → INR",
      "50 EUR → GBP",
      "1000 JPY → USD",
    ];
  }

  void _convert() {
    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > 0) {
      double inUSD = amount / _currencies[_fromCurrency]!["rate"]!;
      double converted = inUSD * _currencies[_toCurrency]!["rate"]!;

      setState(() {
        _result = "${_currencies[_toCurrency]!["symbol"]} ${converted.toStringAsFixed(2)}";

        // Add to recent conversions
        String recent = "${_currencies[_fromCurrency]!["symbol"]}${amount.toStringAsFixed(2)} ${_fromCurrency} → ${_currencies[_toCurrency]!["symbol"]}${converted.toStringAsFixed(2)} ${_toCurrency}";
        _recentConversions.insert(0, recent);
        if (_recentConversions.length > 5) _recentConversions.removeLast();
      });

      HapticFeedback.lightImpact();
    } else {
      _showError(getText("invalidAmount"));
    }
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      if (_amountController.text.isNotEmpty) {
        _convert();
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    _showSnackBar(getText("copied"));
  }

  void _shareResult() {
    String shareText = """
Currency Conversion Result:
${_currencies[_fromCurrency]!["symbol"]} ${_amountController.text} $_fromCurrency = $_result $_toCurrency
Exchange Rate: 1 $_fromCurrency = ${(_currencies[_toCurrency]!["rate"]! / _currencies[_fromCurrency]!["rate"]!).toStringAsFixed(4)} $_toCurrency
    """;
    Clipboard.setData(ClipboardData(text: shareText));
    _showSnackBar(getText("copied"));
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  void _toggleFavorite(String currency) {
    setState(() {
      if (_favoriteCurrencies.contains(currency)) {
        _favoriteCurrencies.remove(currency);
      } else {
        _favoriteCurrencies.add(currency);
      }
    });
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
    final exchangeRate = (_currencies[_toCurrency]!["rate"]! / _currencies[_fromCurrency]!["rate"]!).toStringAsFixed(4);

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
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryDialog(),
            tooltip: getText("historicalRates"),
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
              // Main Conversion Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Amount Input
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: getText("amount"),
                          hintText: getText("enterAmount"),
                          prefixIcon: Icon(_currencies[_fromCurrency]!["symbol"] == "₹"
                              ? Icons.currency_rupee
                              : Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (_) => _convert(),
                      ),
                      const SizedBox(height: 20),

                      // Currency Selection Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencySelector(
                                _fromCurrency,
                                    (value) => setState(() => _fromCurrency = value!),
                                getText("from")
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.swap_horiz, color: Color(0xFF6366F1)),
                              onPressed: _swapCurrencies,
                              tooltip: getText("swap"),
                            ),
                          ),
                          Expanded(
                            child: _buildCurrencySelector(
                                _toCurrency,
                                    (value) => setState(() => _toCurrency = value!),
                                getText("to")
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Convert Button
                      GradientButton(
                        text: getText("convert"),
                        icon: Icons.currency_exchange,
                        onPressed: _convert,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Result Card
              if (_result != "0") ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          getText("result"),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "1 $_fromCurrency = $exchangeRate $_toCurrency",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: _copyResult,
                              tooltip: getText("copy"),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.share, size: 20),
                              onPressed: _shareResult,
                              tooltip: getText("share"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Favorite Currencies Section
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getText("favorites"),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _favoriteCurrencies.length,
                        itemBuilder: (context, index) {
                          String code = _favoriteCurrencies[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: _buildFavoriteChip(code),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Conversions Section
              if (_recentConversions.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getText("recent"),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._recentConversions.map((conversion) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.history, size: 16, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  conversion,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.repeat, size: 16),
                                onPressed: () {
                                  // Parse and reuse conversion
                                  _amountController.text = conversion.split(" ")[0].replaceAll(RegExp(r'[^0-9.]'), '');
                                  _convert();
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],

              // Currency Information Grid
              const SizedBox(height: 8),
              Text(
                "Popular Currencies",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: ["USD", "EUR", "GBP", "JPY", "CAD", "AUD"].map((code) {
                  return _buildCurrencyInfoCard(code);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(String value, Function(String?) onChanged, String label) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _currencies.keys.map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Row(
            children: [
              Text(_currencies[currency]!["flag"]),
              const SizedBox(width: 8),
              Text(currency),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFavoriteChip(String code) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_currencies[code]!["flag"]),
          const SizedBox(width: 4),
          Text(code),
        ],
      ),
      selected: true,
      onSelected: (_) {
        setState(() {
          _fromCurrency = code;
          if (_amountController.text.isNotEmpty) _convert();
        });
      },
      backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
      selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
      shape: StadiumBorder(
        side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.5)),
      ),
    );
  }

  Widget _buildCurrencyInfoCard(String code) {
    final currency = _currencies[code]!;
    final rateToUSD = currency["rate"];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            _toCurrency = code;
            if (_amountController.text.isNotEmpty) _convert();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(currency["flag"], style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                "1 USD = ${rateToUSD.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Historical Exchange Rates",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Last 30 days trend for USD/INR:"),
              const SizedBox(height: 16),
              Container(
                height: 200,
                child: CustomPaint(
                  painter: _TrendLinePainter(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "💡 Tip: Exchange rates fluctuate daily. For the best rates, consider monitoring trends before converting large amounts.",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for trend line graph
class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Sample trend data (simulated)
    List<double> values = [83.2, 83.5, 83.8, 83.3, 83.1, 83.4, 83.6, 83.9, 83.7, 83.5];

    Path path = Path();
    double stepX = size.width / (values.length - 1);
    double minY = values.reduce((a, b) => a < b ? a : b);
    double maxY = values.reduce((a, b) => a > b ? a : b);
    double range = maxY - minY;

    for (int i = 0; i < values.length; i++) {
      double x = i * stepX;
      double y = size.height - ((values[i] - minY) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill area under curve
    Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}