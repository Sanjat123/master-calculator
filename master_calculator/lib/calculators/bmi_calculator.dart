import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/gradient_button.dart';
import '../services/history_service.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> with SingleTickerProviderStateMixin {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();

  String _bmi = "0";
  String _category = "";
  String _advice = "";
  String _language = "English";
  String _unitSystem = "Metric";
  double _bmiValue = 0;
  bool _isLoading = false;
  final GlobalKey _resultKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String _idealWeightRange = "";
  String _bodyFatEstimate = "";
  String _healthScore = "";
  String _waterIntake = "";
  String _calorieNeeds = "";

  Map<String, Map<String, String>> _translations = {
    "English": {
      "title": "BMI Calculator",
      "height": "Height",
      "weight": "Weight",
      "age": "Age (optional)",
      "waist": "Waist Circumference (cm)",
      "calculate": "Calculate BMI",
      "bmi": "BMI",
      "idealWeight": "Ideal Weight Range",
      "bodyFat": "Estimated Body Fat",
      "healthScore": "Health Score",
      "waterIntake": "Daily Water Intake",
      "calorieNeeds": "Daily Calorie Needs",
      "tips": "Health Tips",
      "bmiScale": "BMI Scale",
      "underweight": "Underweight",
      "normal": "Normal weight",
      "overweight": "Overweight",
      "obese": "Obese",
      "share": "Share Results",
      "copy": "Copy Results",
      "language": "Language",
      "unitSystem": "Unit System",
      "metric": "Metric (cm/kg)",
      "imperial": "Imperial (ft/in/lbs)",
      "heightFt": "Height (ft)",
      "heightIn": "Height (in)",
      "weightLbs": "Weight (lbs)",
      "waistIn": "Waist (in)",
      "savedToHistory": "Saved to history",
      "shareTitle": "BMI Results",
      "shareMessage": "Check out my BMI results from Master Calculator",
    },
    "Hindi": {
      "title": "बीएमआई कैलकुलेटर",
      "height": "ऊंचाई",
      "weight": "वजन",
      "age": "आयु (वैकल्पिक)",
      "waist": "कमर की परिधि (सेंटीमीटर)",
      "calculate": "बीएमआई गणना करें",
      "bmi": "बीएमआई",
      "idealWeight": "आदर्श वजन सीमा",
      "bodyFat": "अनुमानित शरीर में वसा",
      "healthScore": "स्वास्थ्य स्कोर",
      "waterIntake": "दैनिक पानी की मात्रा",
      "calorieNeeds": "दैनिक कैलोरी आवश्यकता",
      "tips": "स्वास्थ्य सुझाव",
      "bmiScale": "बीएमआई पैमाना",
      "underweight": "कम वजन",
      "normal": "सामान्य वजन",
      "overweight": "अधिक वजन",
      "obese": "मोटापा",
      "share": "परिणाम साझा करें",
      "copy": "परिणाम कॉपी करें",
      "language": "भाषा",
      "unitSystem": "इकाई प्रणाली",
      "metric": "मीट्रिक (सेमी/किग्रा)",
      "imperial": "इंपीरियल (फुट/इंच/पाउंड)",
      "heightFt": "ऊंचाई (फुट)",
      "heightIn": "ऊंचाई (इंच)",
      "weightLbs": "वजन (पाउंड)",
      "waistIn": "कमर (इंच)",
      "savedToHistory": "इतिहास में सहेजा गया",
      "shareTitle": "बीएमआई परिणाम",
      "shareMessage": "मास्टर कैलकुलेटर से मेरे बीएमआई परिणाम देखें",
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
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  void _calculateBMI() async {
    double height = 0;
    double weight = 0;
    double waist = double.tryParse(_waistController.text) ?? 0;
    int age = int.tryParse(_ageController.text) ?? 30;

    if (_unitSystem == "Metric") {
      height = double.tryParse(_heightController.text) ?? 0;
      weight = double.tryParse(_weightController.text) ?? 0;
    } else {
      double heightFt = double.tryParse(_heightController.text) ?? 0;
      double heightIn = double.tryParse(_weightController.text) ?? 0;
      height = (heightFt * 30.48) + (heightIn * 2.54);
      weight = double.tryParse(_weightController.text) ?? 0;
    }

    if (height > 0 && weight > 0) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(milliseconds: 100));

      double bmi = weight / ((height / 100) * (height / 100));
      _bmiValue = bmi;

      setState(() {
        _bmi = bmi.toStringAsFixed(1);
        _setCategory(bmi);
        _calculateHealthMetrics(bmi, age, waist, height);
        _isLoading = false;
      });

      // Save to history
      await HistoryService.addToHistory(
        expression: "Height: ${_heightController.text}${_unitSystem == "Metric" ? "cm" : "ft"}, Weight: ${_weightController.text}${_unitSystem == "Metric" ? "kg" : "lbs"}",
        result: "BMI: $_bmi ($_category)",
        calculatorType: "BMI",
      );

      _showSnackBar(getText("savedToHistory"));
      HapticFeedback.mediumImpact();
    } else {
      _showError("Please enter valid height and weight");
    }
  }

  void _setCategory(double bmi) {
    if (bmi < 18.5) {
      _category = getText("underweight");
      _advice = _language == "English"
          ? "You may need to gain some weight. Consider nutrient-rich foods like nuts, avocados, and whole grains. Consult a nutritionist for a personalized plan."
          : "आपको कुछ वजन बढ़ाने की आवश्यकता हो सकती है। नट्स, एवोकाडो और साबुत अनाज जैसे पोषक तत्वों से भरपूर खाद्य पदार्थों पर विचार करें। व्यक्तिगत योजना के लिए पोषण विशेषज्ञ से सलाह लें।";
    } else if (bmi < 25) {
      _category = getText("normal");
      _advice = _language == "English"
          ? "Excellent! You're in a healthy weight range. Maintain with a balanced diet rich in fruits, vegetables, lean proteins, and regular exercise (150 mins/week)."
          : "उत्कृष्ट! आप स्वस्थ वजन सीमा में हैं। फलों, सब्जियों, दुबले प्रोटीन से भरपूर संतुलित आहार और नियमित व्यायाम (150 मिनट/सप्ताह) के साथ बनाए रखें।";
    } else if (bmi < 30) {
      _category = getText("overweight");
      _advice = _language == "English"
          ? "Consider a weight management plan. Focus on portion control, increase physical activity, reduce processed foods, and stay hydrated. A 5-10% weight loss can improve health."
          : "वजन प्रबंधन योजना पर विचार करें। भाग नियंत्रण पर ध्यान दें, शारीरिक गतिविधि बढ़ाएं, प्रसंस्कृत खाद्य पदार्थ कम करें और हाइड्रेटेड रहें। 5-10% वजन घटाने से स्वास्थ्य में सुधार हो सकता है।";
    } else {
      _category = getText("obese");
      _advice = _language == "English"
          ? "Please consult a healthcare provider for a comprehensive weight management plan. Consider dietary changes, regular exercise, and professional guidance for sustainable results."
          : "कृपया व्यापक वजन प्रबंधन योजना के लिए स्वास्थ्य सेवा प्रदाता से परामर्श लें। स्थायी परिणामों के लिए आहार परिवर्तन, नियमित व्यायाम और पेशेवर मार्गदर्शन पर विचार करें।";
    }
  }

  void _calculateHealthMetrics(double bmi, int age, double waist, double height) {
    double heightInMeters = (double.tryParse(_heightController.text) ?? 0) / 100;
    double minIdealWeight = 18.5 * heightInMeters * heightInMeters;
    double maxIdealWeight = 24.9 * heightInMeters * heightInMeters;
    _idealWeightRange = "${minIdealWeight.toStringAsFixed(1)} - ${maxIdealWeight.toStringAsFixed(1)} kg";

    double bodyFat = (1.20 * bmi) + (0.23 * age) - 10.8 - 5.4;
    bodyFat = max(10, min(50, bodyFat));
    _bodyFatEstimate = "${bodyFat.toStringAsFixed(1)}%";

    int healthScore = 100;
    if (bmi < 18.5) healthScore -= 20;
    else if (bmi > 25 && bmi < 30) healthScore -= 15;
    else if (bmi >= 30) healthScore -= 30;
    if (waist > 80) healthScore -= 10;
    healthScore = max(0, min(100, healthScore));
    _healthScore = "$healthScore/100";

    double weight = double.tryParse(_weightController.text) ?? 0;
    double waterML = weight * 30;
    _waterIntake = "${(waterML / 1000).toStringAsFixed(1)} L";

    double bmr = 10 * weight + 6.25 * (double.tryParse(_heightController.text) ?? 0) - 5 * age;
    double calories = bmr * 1.375;
    _calorieNeeds = "${calories.round()} kcal/day";
  }

  Color _getCategoryColor() {
    if (_bmiValue < 18.5) return Colors.orange;
    if (_bmiValue < 25) return Colors.green;
    if (_bmiValue < 30) return Colors.orange.shade700;
    if (_bmiValue >= 30) return Colors.red;
    return Colors.grey;
  }

  double _getBMIPercentage() {
    if (_bmiValue < 18.5) return (_bmiValue / 18.5) * 0.25;
    if (_bmiValue < 25) return 0.25 + ((_bmiValue - 18.5) / 6.5) * 0.5;
    if (_bmiValue < 30) return 0.75 + ((_bmiValue - 25) / 5) * 0.25;
    return 1.0;
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
      final File imagePath = await File('${directory.path}/bmi_result.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
${getText("shareTitle")}:
BMI: $_bmi ($_category)
Ideal Weight: $_idealWeightRange
Body Fat: $_bodyFatEstimate
Health Score: $_healthScore
Water Intake: $_waterIntake
Daily Calories: $_calorieNeeds
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
BMI Calculator Results:
BMI: $_bmi ($_category)
Ideal Weight: $_idealWeightRange
Body Fat: $_bodyFatEstimate
Health Score: $_healthScore
Water Intake: $_waterIntake
Daily Calories: $_calorieNeeds
$_advice
      """;
      await Share.share(results);
    }
  }

  void _copyResults() {
    String results = """
BMI Calculator Results:
BMI: $_bmi ($_category)
Ideal Weight: $_idealWeightRange
Body Fat: $_bodyFatEstimate
Health Score: $_healthScore
Water Intake: $_waterIntake
Daily Calories: $_calorieNeeds
$_advice
    """;
    Clipboard.setData(ClipboardData(text: results));
    _showSnackBar("Results copied to clipboard!");
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

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
      if (_bmi != "0") {
        _setCategory(_bmiValue);
      }
    });
  }

  void _toggleUnitSystem() {
    setState(() {
      _unitSystem = _unitSystem == "Metric" ? "Imperial" : "Metric";
      _heightController.clear();
      _weightController.clear();
      _bmi = "0";
      _category = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();

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
            icon: const Icon(Icons.straighten),
            onPressed: _toggleUnitSystem,
            tooltip: getText("unitSystem"),
          ),
          if (_bmi != "0") ...[
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info, size: 16, color: const Color(0xFF6366F1)),
                  const SizedBox(width: 4),
                  Text(
                    _unitSystem == "Metric" ? getText("metric") : getText("imperial"),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_unitSystem == "Metric") ...[
                      TextField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          labelText: "${getText("height")} (cm)",
                          prefixIcon: const Icon(Icons.height),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: "${getText("weight")} (kg)",
                          prefixIcon: const Icon(Icons.fitness_center),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _heightController,
                              decoration: InputDecoration(
                                labelText: getText("heightFt"),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              decoration: InputDecoration(
                                labelText: getText("heightIn"),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: getText("weightLbs"),
                          prefixIcon: const Icon(Icons.fitness_center),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: getText("age"),
                        prefixIcon: const Icon(Icons.cake),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _waistController,
                      decoration: InputDecoration(
                        labelText: _unitSystem == "Metric" ? getText("waist") : getText("waistIn"),
                        prefixIcon: const Icon(Icons.straighten),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            GradientButton(
              text: getText("calculate"),
              icon: Icons.calculate,
              isLoading: _isLoading,
              onPressed: _calculateBMI,
            ),

            if (_bmi != "0") ...[
              const SizedBox(height: 20),

              RepaintBoundary(
                key: _resultKey,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor.withOpacity(0.2),
                                  categoryColor.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(color: categoryColor, width: 4),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _bmi,
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: categoryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    getText("bmi"),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: categoryColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              _category,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getText("bmiScale"), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: const LinearGradient(
                                    colors: [Colors.orange, Colors.green, Colors.orange, Colors.red],
                                    stops: [0.25, 0.5, 0.75, 1.0],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: _getBMIPercentage() * MediaQuery.of(context).size.width * 0.7,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: categoryColor,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(getText("underweight"), style: const TextStyle(fontSize: 10)),
                                  Text(getText("normal"), style: const TextStyle(fontSize: 10)),
                                  Text(getText("overweight"), style: const TextStyle(fontSize: 10)),
                                  Text(getText("obese"), style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard(getText("idealWeight"), _idealWeightRange, Icons.fitness_center, Colors.blue),
                  _buildMetricCard(getText("bodyFat"), _bodyFatEstimate, Icons.analytics, Colors.purple),
                  _buildMetricCard(getText("healthScore"), _healthScore, Icons.health_and_safety, Colors.green),
                  _buildMetricCard(getText("waterIntake"), _waterIntake, Icons.water_drop, Colors.cyan),
                  _buildMetricCard(getText("calorieNeeds"), _calorieNeeds, Icons.local_fire_department, Colors.orange),
                ],
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: const Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Text(
                            getText("tips"),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _advice,
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildQuickTips(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTips() {
    List<Map<String, String>> tips = _language == "English"
        ? [
      {"icon": "🥗", "tip": "Eat a balanced diet with fruits, vegetables, and lean proteins"},
      {"icon": "🏃", "tip": "Exercise for at least 30 minutes, 5 days a week"},
      {"icon": "💧", "tip": "Drink adequate water throughout the day"},
      {"icon": "😴", "tip": "Get 7-9 hours of quality sleep each night"},
      {"icon": "🧘", "tip": "Practice stress management through meditation or yoga"},
      {"icon": "📱", "tip": "Track your meals and activity using apps"},
    ]
        : [
      {"icon": "🥗", "tip": "फलों, सब्जियों और दुबले प्रोटीन के साथ संतुलित आहार लें"},
      {"icon": "🏃", "tip": "सप्ताह में 5 दिन कम से कम 30 मिनट व्यायाम करें"},
      {"icon": "💧", "tip": "दिन भर में पर्याप्त पानी पीें"},
      {"icon": "😴", "tip": "प्रत्येक रात 7-9 घंटे की गुणवत्तापूर्ण नींद लें"},
      {"icon": "🧘", "tip": "ध्यान या योग के माध्यम से तनाव प्रबंधन का अभ्यास करें"},
      {"icon": "📱", "tip": "ऐप्स का उपयोग करके अपने भोजन और गतिविधि को ट्रैक करें"},
    ];

    return Column(
      children: [
        const SizedBox(height: 8),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
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