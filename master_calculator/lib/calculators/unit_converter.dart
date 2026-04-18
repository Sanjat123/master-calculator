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

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> with SingleTickerProviderStateMixin {
  final TextEditingController _valueController = TextEditingController();
  String _category = "Length";
  String _fromUnit = "Meter";
  String _toUnit = "Kilometer";
  String _result = "0";
  String _language = "English";
  List<String> _favorites = [];
  bool _showFavorites = false;
  bool _isLoading = false;
  double _inputValue = 0;
  final GlobalKey _resultKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Complete unit conversions
  final Map<String, Map<String, dynamic>> _categories = {
    "Length": {
      "icon": Icons.straighten,
      "color": const Color(0xFF6366F1),
      "units": {
        "Meter": 1.0,
        "Kilometer": 0.001,
        "Centimeter": 100.0,
        "Millimeter": 1000.0,
        "Micrometer": 1000000.0,
        "Nanometer": 1000000000.0,
        "Mile": 0.000621371,
        "Yard": 1.09361,
        "Foot": 3.28084,
        "Inch": 39.3701,
        "Nautical Mile": 0.000539957,
        "Light Year": 1.057e-16,
      },
    },
    "Weight": {
      "icon": Icons.fitness_center,
      "color": const Color(0xFF10B981),
      "units": {
        "Kilogram": 1.0,
        "Gram": 1000.0,
        "Milligram": 1000000.0,
        "Microgram": 1e9,
        "Metric Ton": 0.001,
        "Pound": 2.20462,
        "Ounce": 35.274,
        "Stone": 0.157473,
        "US Ton": 0.00110231,
      },
    },
    "Temperature": {
      "icon": Icons.thermostat,
      "color": const Color(0xFFEF4444),
      "units": {
        "Celsius": "C",
        "Fahrenheit": "F",
        "Kelvin": "K",
      },
      "isSpecial": true,
    },
    "Area": {
      "icon": Icons.crop_square,
      "color": const Color(0xFFF59E0B),
      "units": {
        "Square Meter": 1.0,
        "Square Kilometer": 0.000001,
        "Square Centimeter": 10000.0,
        "Square Millimeter": 1e6,
        "Square Mile": 3.861e-7,
        "Square Yard": 1.19599,
        "Square Foot": 10.7639,
        "Square Inch": 1550.0,
        "Acre": 0.000247105,
        "Hectare": 0.0001,
      },
    },
    "Volume": {
      "icon": Icons.water_drop,
      "color": const Color(0xFF06B6D4),
      "units": {
        "Liter": 1.0,
        "Milliliter": 1000.0,
        "Cubic Meter": 0.001,
        "Cubic Centimeter": 1000.0,
        "Cubic Foot": 0.0353147,
        "Cubic Inch": 61.0237,
        "Gallon (US)": 0.264172,
        "Gallon (UK)": 0.219969,
        "Quart (US)": 1.05669,
        "Pint (US)": 2.11338,
        "Fluid Ounce (US)": 33.814,
      },
    },
    "Speed": {
      "icon": Icons.speed,
      "color": const Color(0xFF8B5CF6),
      "units": {
        "Meter/Second": 1.0,
        "Kilometer/Hour": 3.6,
        "Mile/Hour": 2.23694,
        "Knot": 1.94384,
        "Foot/Second": 3.28084,
        "Mach": 0.00293858,
        "Speed of Light": 3.3356e-9,
      },
    },
    "Time": {
      "icon": Icons.access_time,
      "color": const Color(0xFFEC4899),
      "units": {
        "Second": 1.0,
        "Millisecond": 1000.0,
        "Microsecond": 1e6,
        "Nanosecond": 1e9,
        "Minute": 0.0166667,
        "Hour": 0.000277778,
        "Day": 1.15741e-5,
        "Week": 1.65344e-6,
        "Month": 3.805e-7,
        "Year": 3.171e-8,
      },
    },
    "Energy": {
      "icon": Icons.bolt,
      "color": const Color(0xFFF97316),
      "units": {
        "Joule": 1.0,
        "Kilojoule": 0.001,
        "Calorie": 0.239006,
        "Kilocalorie": 0.000239006,
        "Watt Hour": 0.000277778,
        "Kilowatt Hour": 2.77778e-7,
        "Electronvolt": 6.242e+18,
        "BTU": 0.000947817,
      },
    },
    "Pressure": {
      "icon": Icons.speed_outlined,
      "color": const Color(0xFF14B8A6),
      "units": {
        "Pascal": 1.0,
        "Kilopascal": 0.001,
        "Bar": 0.00001,
        "Millibar": 0.01,
        "Atmosphere": 9.86923e-6,
        "PSI": 0.000145038,
        "Torr": 0.00750062,
        "MMHG": 0.00750062,
      },
    },
    "Data": {
      "icon": Icons.storage,
      "color": const Color(0xFF3B82F6),
      "units": {
        "Byte": 1.0,
        "Kilobyte": 0.001,
        "Megabyte": 0.000001,
        "Gigabyte": 1e-9,
        "Terabyte": 1e-12,
        "Petabyte": 1e-15,
        "Bit": 8.0,
        "Kilobit": 0.008,
        "Megabit": 0.000008,
        "Gigabit": 8e-9,
      },
    },
  };

  // Language translations
  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "Unit Converter",
      "category": "Category",
      "value": "Value to Convert",
      "from": "From",
      "to": "To",
      "convert": "Convert",
      "result": "Converted Value",
      "favorites": "Favorites",
      "addFavorite": "Add to Favorites",
      "removeFavorite": "Remove from Favorites",
      "copy": "Copy Result",
      "share": "Share",
      "language": "Language",
      "enterValue": "Enter value to convert",
      "copied": "Copied to clipboard!",
      "quickConversions": "Quick Conversions",
      "savedToHistory": "Saved to history",
      "shareTitle": "Unit Conversion Result",
      "shareMessage": "Check out my unit conversion from Master Calculator",
    },
    "Hindi": {
      "title": "यूनिट कनवर्टर",
      "category": "श्रेणी",
      "value": "मान कनवर्ट करें",
      "from": "से",
      "to": "को",
      "convert": "बदलें",
      "result": "परिवर्तित मान",
      "favorites": "पसंदीदा",
      "addFavorite": "पसंदीदा में जोड़ें",
      "removeFavorite": "पसंदीदा से हटाएं",
      "copy": "परिणाम कॉपी करें",
      "share": "साझा करें",
      "language": "भाषा",
      "enterValue": "कनवर्ट करने के लिए मान दर्ज करें",
      "copied": "क्लिपबोर्ड पर कॉपी किया गया!",
      "quickConversions": "त्वरित रूपांतरण",
      "savedToHistory": "इतिहास में सहेजा गया",
      "shareTitle": "यूनिट रूपांतरण परिणाम",
      "shareMessage": "मास्टर कैलकुलेटर से मेरा यूनिट रूपांतरण देखें",
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
    _valueController.addListener(_onValueChanged);
    _loadFavorites();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _valueController.removeListener(_onValueChanged);
    _valueController.dispose();
    super.dispose();
  }

  void _loadFavorites() {
    // Load from SharedPreferences in real app
    _favorites = ["Length: Meter to Kilometer", "Weight: Kilogram to Pound"];
  }

  void _onValueChanged() {
    _performConversion();
  }

  void _performConversion() {
    double value = double.tryParse(_valueController.text) ?? 0;
    _inputValue = value;

    if (_categories[_category]!["isSpecial"] == true) {
      _convertTemperature(value);
    } else {
      _convertStandard(value);
    }
  }

  void _convertStandard(double value) {
    if (value == 0) {
      setState(() {
        _result = "0";
      });
      return;
    }

    try {
      double inBase = value / _categories[_category]!["units"][_fromUnit];
      double converted = inBase * _categories[_category]!["units"][_toUnit];
      setState(() {
        _result = _formatResult(converted);
      });
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  void _convertTemperature(double value) {
    double converted = 0;
    try {
      if (_fromUnit == "Celsius") {
        if (_toUnit == "Fahrenheit") converted = (value * 9/5) + 32;
        else if (_toUnit == "Kelvin") converted = value + 273.15;
        else converted = value;
      } else if (_fromUnit == "Fahrenheit") {
        if (_toUnit == "Celsius") converted = (value - 32) * 5/9;
        else if (_toUnit == "Kelvin") converted = (value - 32) * 5/9 + 273.15;
        else converted = value;
      } else if (_fromUnit == "Kelvin") {
        if (_toUnit == "Celsius") converted = value - 273.15;
        else if (_toUnit == "Fahrenheit") converted = (value - 273.15) * 9/5 + 32;
        else converted = value;
      }
      setState(() {
        _result = converted.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  String _formatResult(double value) {
    if (value >= 1e6 || value <= 1e-6) {
      return value.toStringAsExponential(4);
    }
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _convert() async {
    double value = double.tryParse(_valueController.text) ?? 0;
    if (value == 0 && _valueController.text.isNotEmpty) {
      _showError(getText("enterValue"));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100));
    _performConversion();
    setState(() => _isLoading = false);

    // Save to history
    await HistoryService.addToHistory(
      expression: "${_valueController.text} $_fromUnit to $_toUnit",
      result: "$_result $_toUnit",
      calculatorType: "Unit",
    );

    HapticFeedback.lightImpact();
    _showSnackBar(getText("savedToHistory"));
  }

  void _toggleFavorite() {
    String favorite = "$_category: $_fromUnit to $_toUnit";
    if (_favorites.contains(favorite)) {
      setState(() {
        _favorites.remove(favorite);
      });
      _showSnackBar(getText("removeFavorite"));
    } else {
      setState(() {
        _favorites.add(favorite);
      });
      _showSnackBar(getText("addFavorite"));
    }
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: "$_result $_toUnit"));
    _showSnackBar(getText("copied"));
  }

  Future<void> _shareResult() async {
    try {
      setState(() => _isLoading = true);

      final RenderRepaintBoundary boundary = _resultKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory directory = await getTemporaryDirectory();
      final File imagePath = await File('${directory.path}/unit_result.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
${getText("shareTitle")}:
${_valueController.text} $_fromUnit = $_result $_toUnit
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

  void _swapUnits() {
    setState(() {
      String temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _performConversion();
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
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

  String _getConversionRate() {
    if (_categories[_category]!["isSpecial"] == true) {
      if (_fromUnit == "Celsius" && _toUnit == "Fahrenheit") return "°F = (°C × 9/5) + 32";
      if (_fromUnit == "Fahrenheit" && _toUnit == "Celsius") return "°C = (°F - 32) × 5/9";
      if (_fromUnit == "Celsius" && _toUnit == "Kelvin") return "K = °C + 273.15";
      if (_fromUnit == "Kelvin" && _toUnit == "Celsius") return "°C = K - 273.15";
      return "Special formula";
    }
    double rate = _categories[_category]!["units"][_toUnit] / _categories[_category]!["units"][_fromUnit];
    return _formatResult(rate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCategory = _categories[_category]!;
    final accentColor = currentCategory["color"];

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
          IconButton(
            icon: Icon(_showFavorites ? Icons.star : Icons.star_border),
            onPressed: () => setState(() => _showFavorites = !_showFavorites),
            tooltip: getText("favorites"),
          ),
          if (_result != "0") ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResult,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Selector
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.keys.length,
                itemBuilder: (context, index) {
                  String key = _categories.keys.elementAt(index);
                  var category = _categories[key]!;
                  bool isSelected = _category == key;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _category = key;
                        _fromUnit = _categories[key]!["units"].keys.first;
                        _toUnit = _categories[key]!["units"].keys.last;
                      });
                      _performConversion();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category["color"].withOpacity(0.2)
                            : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? category["color"]
                              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category["icon"],
                              color: isSelected ? category["color"] : null,
                              size: 28),
                          const SizedBox(height: 6),
                          Text(
                            key,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? category["color"] : null,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Main Converter Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Value Input
                    TextField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        labelText: getText("value"),
                        hintText: "Enter value (e.g., 100)",
                        prefixIcon: Icon(Icons.numbers, color: accentColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // From/To Units
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getText("from"), style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _fromUnit,
                                    isExpanded: true,
                                    items: _categories[_category]!["units"].keys.map((unit) {
                                      return DropdownMenuItem(value: unit, child: Text(unit));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _fromUnit = value!);
                                      _performConversion();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          child: IconButton(
                            icon: const Icon(Icons.swap_horiz),
                            onPressed: _swapUnits,
                            color: accentColor,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getText("to"), style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _toUnit,
                                    isExpanded: true,
                                    items: _categories[_category]!["units"].keys.map((unit) {
                                      return DropdownMenuItem(value: unit, child: Text(unit));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _toUnit = value!);
                                      _performConversion();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Favorite Button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _favorites.contains("$_category: $_fromUnit to $_toUnit")
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _favorites.contains("$_category: $_fromUnit to $_toUnit")
                              ? getText("removeFavorite")
                              : getText("addFavorite"),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Convert Button
            GradientButton(
              text: getText("convert"),
              icon: Icons.calculate,
              isLoading: _isLoading,
              onPressed: _convert,
            ),

            // Result Card
            const SizedBox(height: 20),
            RepaintBoundary(
              key: _resultKey,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.1),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          getText("result"),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$_result $_toUnit",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: _copyResult,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "1 $_fromUnit = ${_getConversionRate()} $_toUnit",
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Favorites Section
            if (_showFavorites && _favorites.isNotEmpty) ...[
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
                          Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            getText("favorites"),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._favorites.map((favorite) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.star, size: 16, color: Colors.amber),
                            title: Text(favorite, style: const TextStyle(fontSize: 14)),
                            trailing: const Icon(Icons.arrow_forward, size: 16),
                            onTap: () {
                              var parts = favorite.split(": ");
                              var conversion = parts[1].split(" to ");
                              setState(() {
                                _category = parts[0];
                                _fromUnit = conversion[0];
                                _toUnit = conversion[1];
                              });
                              _performConversion();
                            },
                            dense: true,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],

            // Quick Conversions
            const SizedBox(height: 16),
            _buildQuickConversions(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickConversions(Color accentColor) {
    List<Map<String, String>> quickConversions = _language == "English"
        ? [
      {"from": "1 km", "to": "miles", "result": "0.621 miles"},
      {"from": "1 kg", "to": "lbs", "result": "2.205 lbs"},
      {"from": "1 ft", "to": "cm", "result": "30.48 cm"},
      {"from": "1 gal", "to": "L", "result": "3.785 L"},
      {"from": "32°F", "to": "°C", "result": "0°C"},
      {"from": "1 inch", "to": "cm", "result": "2.54 cm"},
    ]
        : [
      {"from": "1 km", "to": "miles", "result": "0.621 मील"},
      {"from": "1 kg", "to": "lbs", "result": "2.205 पाउंड"},
      {"from": "1 ft", "to": "cm", "result": "30.48 सेमी"},
      {"from": "1 gal", "to": "L", "result": "3.785 लीटर"},
      {"from": "32°F", "to": "°C", "result": "0°C"},
      {"from": "1 inch", "to": "cm", "result": "2.54 सेमी"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getText("quickConversions"),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickConversions.map((conv) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                "${conv["from"]} = ${conv["result"]}",
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}