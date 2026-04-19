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
  final GlobalKey _resultKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      "swapUnits": "Swap Units",
      "clearAll": "Clear All",
      "history": "History",
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
      "swapUnits": "इकाइयां बदलें",
      "clearAll": "सभी साफ़ करें",
      "history": "इतिहास",
    },
  };

  String getText(String key) {
    return _translations[_language]?[key] ?? _translations["English"]![key]!;
  }

  // Complete unit conversions Data Structure
  final Map<String, Map<String, dynamic>> _categories = {
    "Length": {
      "icon": Icons.straighten_rounded,
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
      },
    },
    "Weight": {
      "icon": Icons.monitor_weight_rounded,
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
      },
    },
    "Temperature": {
      "icon": Icons.thermostat_rounded,
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
      },
    },
    "Speed": {
      "icon": Icons.speed_rounded,
      "color": const Color(0xFF8B5CF6),
      "units": {
        "Meter/Second": 1.0,
        "Kilometer/Hour": 3.6,
        "Mile/Hour": 2.23694,
        "Knot": 1.94384,
        "Foot/Second": 3.28084,
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
      },
    },
    "Data": {
      "icon": Icons.data_usage_rounded,
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
    "Pressure": {
      "icon": Icons.speed_outlined,
      "color": const Color(0xFF14B8A6),
      "units": {
        "Pascal": 1.0,
        "Kilopascal": 0.001,
        "Bar": 0.00001,
        "PSI": 0.000145038,
      },
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _valueController.addListener(_performConversion);
    _loadFavorites();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _loadFavorites() {
    // Load favorites from SharedPreferences
    _favorites = [];
  }

  void _performConversion() {
    if (_valueController.text.isEmpty) {
      setState(() => _result = "0");
      return;
    }

    double value = double.tryParse(_valueController.text) ?? 0;

    if (_categories[_category]!["isSpecial"] == true) {
      _convertTemperature(value);
    } else {
      _convertStandard(value);
    }
  }

  void _convertStandard(double value) {
    try {
      double fromRate = _categories[_category]!["units"][_fromUnit];
      double toRate = _categories[_category]!["units"][_toUnit];
      double converted = (value / fromRate) * toRate;
      setState(() => _result = _formatResult(converted));
    } catch (e) {
      setState(() => _result = "Error");
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
      setState(() => _result = converted.toStringAsFixed(2));
    } catch (e) {
      setState(() => _result = "Error");
    }
  }

  String _formatResult(double value) {
    if (value == 0) return "0";
    if (value.abs() >= 1e6 || value.abs() <= 1e-4) return value.toStringAsExponential(3);
    return value.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _convert() async {
    double value = double.tryParse(_valueController.text) ?? 0;
    if (value == 0 && _valueController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid value"), backgroundColor: Colors.red),
      );
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved to history"), duration: Duration(seconds: 1)),
    );
  }

  void _swapUnits() {
    setState(() {
      String temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _performConversion();
    HapticFeedback.mediumImpact();
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: "$_result $_toUnit"));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!"), duration: Duration(seconds: 1)),
    );
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

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  void _toggleFavorite() {
    String favorite = "$_category: $_fromUnit to $_toUnit";
    if (_favorites.contains(favorite)) {
      setState(() => _favorites.remove(favorite));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from favorites"), duration: Duration(seconds: 1)),
      );
    } else {
      setState(() => _favorites.add(favorite));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to favorites"), duration: Duration(seconds: 1)),
      );
    }
  }

  String _getConversionRate() {
    if (_categories[_category]!["isSpecial"] == true) {
      if (_fromUnit == "Celsius" && _toUnit == "Fahrenheit") return "°F = (°C × 9/5) + 32";
      if (_fromUnit == "Fahrenheit" && _toUnit == "Celsius") return "°C = (°F - 32) × 5/9";
      if (_fromUnit == "Celsius" && _toUnit == "Kelvin") return "K = °C + 273.15";
      return "Special formula";
    }
    double rate = _categories[_category]!["units"][_toUnit] / _categories[_category]!["units"][_fromUnit];
    return _formatResult(rate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _categories[_category]!["color"];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(getText("title"), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
            tooltip: getText("history"),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Category Selector
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.keys.map((String key) {
                    bool isSelected = _category == key;
                    var cat = _categories[key]!;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _category = key;
                          _fromUnit = cat["units"].keys.first;
                          _toUnit = cat["units"].keys.last;
                        });
                        _performConversion();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        width: 85,
                        decoration: BoxDecoration(
                          color: isSelected ? cat["color"] : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected ? [BoxShadow(color: cat["color"].withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
                          border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat["icon"], color: isSelected ? Colors.white : cat["color"], size: 28),
                            const SizedBox(height: 5),
                            Text(key, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 25),

              // Converter Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 4,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _valueController,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: "0.00",
                          labelText: getText("value"),
                          prefixIcon: Icon(Icons.edit_note_rounded, color: accentColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildUnitDropdown(true, accentColor, isDark)),
                          IconButton(
                            onPressed: _swapUnits,
                            icon: Icon(Icons.swap_horizontal_circle_rounded, color: accentColor, size: 40),
                            tooltip: getText("swapUnits"),
                          ),
                          Expanded(child: _buildUnitDropdown(false, accentColor, isDark)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: getText("convert"),
                        icon: Icons.calculate,
                        isLoading: _isLoading,
                        onPressed: _convert,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Result Box
              RepaintBoundary(
                key: _resultKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      Text(getText("result").toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      FittedBox(
                        child: Text("$_result $_toUnit", style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "1 $_fromUnit = ${_getConversionRate()} $_toUnit",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionButton(Icons.copy_all_rounded, getText("copy"), _copyResult),
                          const SizedBox(width: 15),
                          _actionButton(Icons.share_rounded, getText("share"), _shareResult),
                          const SizedBox(width: 15),
                          _actionButton(Icons.star_border, getText("favorites"), _toggleFavorite),
                        ],
                      )
                    ],
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
              const SizedBox(height: 20),
              _buildQuickConversions(accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown(bool isFrom, Color color, bool isDark) {
    String currentValue = isFrom ? _fromUnit : _toUnit;

    List<DropdownMenuItem<String>> menuItems = (_categories[_category]!["units"] as Map<String, dynamic>)
        .keys
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: color),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: menuItems,
          onChanged: (val) {
            setState(() {
              if (isFrom) _fromUnit = val!;
              else _toUnit = val!;
            });
            _performConversion();
          },
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
        const SizedBox(height: 12),
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
                style: TextStyle(fontSize: 12, color: accentColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}