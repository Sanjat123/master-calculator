import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class BhumiCalculator extends StatefulWidget {
  const BhumiCalculator({super.key});

  @override
  State<BhumiCalculator> createState() => _BhumiCalculatorState();
}

class _BhumiCalculatorState extends State<BhumiCalculator> {
  final TextEditingController _valueController = TextEditingController();

  final ScreenshotController _screenshotController =
  ScreenshotController();

  bool _isHindi = true;

  String _selectedUnit = "bigha";

  Map<String, double> _results = {};

  final String appLink =
      "https://play.google.com/store/apps/details?id=com.Master.Calculator&hl=en_IN";

  // =========================
  // CONVERSION DATA
  // =========================

  final Map<String, double> unitToSqFt = {
    "bigha": 27225,
    "katha": 1361.25,
    "dhur": 68.0625,
    "acre": 43560,
    "decimal": 435.6,
    "hectare": 107639,
    "sqft": 1,
    "sqm": 10.7639,
  };

  // =========================
  // LANGUAGE
  // =========================

  final Map<String, Map<String, String>> labels = {
    "hi": {
      "title": "भूमि माप कैलकुलेटर",
      "subtitle": "गांव की जमीन का सही हिसाब",
      "enterValue": "मान डालें",
      "selectUnit": "इकाई चुनें",
      "calculate": "हिसाब करें",
      "clear": "रीसेट",
      "result": "परिणाम",
      "copy": "कॉपी करें",
      "share": "शेयर करें",
      "download": "डाउनलोड करें",
      "bigha": "बीघा",
      "katha": "कठा",
      "dhur": "धुर",
      "acre": "एकड़",
      "decimal": "डेसिमल",
      "hectare": "हेक्टेयर",
      "sqft": "वर्ग फुट",
      "sqm": "वर्ग मीटर",
      "language": "English",
      "copied": "कॉपी हो गया",
      "shareText":
      "यह जमीन का हिसाब Master Calculator App से निकाला गया है 👇",
    },
    "en": {
      "title": "Land Area Calculator",
      "subtitle": "Easy village land calculator",
      "enterValue": "Enter Value",
      "selectUnit": "Select Unit",
      "calculate": "Calculate",
      "clear": "Reset",
      "result": "Results",
      "copy": "Copy",
      "share": "Share",
      "download": "Download App",
      "bigha": "Bigha",
      "katha": "Katha",
      "dhur": "Dhur",
      "acre": "Acre",
      "decimal": "Decimal",
      "hectare": "Hectare",
      "sqft": "Square Feet",
      "sqm": "Square Meter",
      "language": "हिंदी",
      "copied": "Copied Successfully",
      "shareText":
      "This land result was calculated using Master Calculator App 👇",
    }
  };

  String tr(String key) {
    return labels[_isHindi ? "hi" : "en"]![key] ?? key;
  }

  // =========================
  // CALCULATE
  // =========================

  void _calculate() {
    FocusScope.of(context).unfocus();

    double value = double.tryParse(_valueController.text) ?? 0;

    if (value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isHindi
                ? "कृपया सही मान डालें"
                : "Please enter valid value",
          ),
        ),
      );

      return;
    }

    double sqFt = value * unitToSqFt[_selectedUnit]!;

    setState(() {
      _results = {
        "bigha": sqFt / unitToSqFt["bigha"]!,
        "katha": sqFt / unitToSqFt["katha"]!,
        "dhur": sqFt / unitToSqFt["dhur"]!,
        "acre": sqFt / unitToSqFt["acre"]!,
        "decimal": sqFt / unitToSqFt["decimal"]!,
        "hectare": sqFt / unitToSqFt["hectare"]!,
        "sqft": sqFt,
        "sqm": sqFt / unitToSqFt["sqm"]!,
      };
    });

    HapticFeedback.mediumImpact();
  }

  // =========================
  // CLEAR
  // =========================

  void _clear() {
    _valueController.clear();

    setState(() {
      _results.clear();
    });

    HapticFeedback.lightImpact();
  }

  // =========================
  // COPY
  // =========================

  void _copyResult() {
    if (_results.isEmpty) return;

    String text = "";

    _results.forEach((key, value) {
      text += "${tr(key)} : ${value.toStringAsFixed(4)}\n";
    });

    Clipboard.setData(
      ClipboardData(text: text),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr("copied")),
      ),
    );
  }

  // =========================
  // SHARE SCREENSHOT
  // =========================

  Future<void> _shareResult() async {
    try {
      final image = await _screenshotController.capture();

      if (image == null) return;

      final directory =
      await getTemporaryDirectory();

      final imagePath =
      await File('${directory.path}/land_result.png')
          .create();

      await imagePath.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text:
        "${tr("shareText")}\n\n$appLink",
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xff101418) : const Color(0xffedf5ef),

      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,

        title: Text(
          tr("title"),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isHindi = !_isHindi;
              });
            },
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            label: Text(
              tr("language"),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),

      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            children: [
              _buildInputCard(isDark),

              const SizedBox(height: 24),

              if (_results.isNotEmpty)
                Screenshot(
                  controller: _screenshotController,
                  child: _buildResultCard(isDark),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // INPUT CARD
  // =========================

  Widget _buildInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color:
        isDark ? const Color(0xff1d232a) : Colors.white,

        borderRadius:
        BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(.08),
            offset: const Offset(0, 6),
          )
        ],
      ),

      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),

            decoration: BoxDecoration(
              color:
              Colors.green.withOpacity(.10),

              borderRadius:
              BorderRadius.circular(50),
            ),

            child: Text(
              tr("subtitle"),

              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tr("enterValue"),

              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _valueController,

            keyboardType:
            const TextInputType.numberWithOptions(
              decimal: true,
            ),

            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : Colors.black,
            ),

            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d*'),
              )
            ],

            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? const Color(0xff2c3440)
                  : Colors.grey.shade100,

              hintText: "0",

              prefixIcon: const Icon(
                Icons.square_foot,
              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tr("selectUnit"),

              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff2c3440)
                  : Colors.grey.shade100,

              borderRadius:
              BorderRadius.circular(18),
            ),

            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUnit,

                dropdownColor: isDark
                    ? const Color(0xff2c3440)
                    : Colors.white,

                isExpanded: true,

                style: TextStyle(
                  fontSize: 18,
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),

                items:
                unitToSqFt.keys.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(tr(unit)),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                flex: 2,

                child: ElevatedButton(
                  onPressed: _calculate,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green,

                    foregroundColor:
                    Colors.white,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: Text(
                    tr("calculate"),

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: _clear,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.redAccent,

                    foregroundColor:
                    Colors.white,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: Text(
                    tr("clear"),

                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // =========================
  // RESULT CARD
  // =========================

  Widget _buildResultCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color:
        isDark ? const Color(0xff1d232a) : Colors.white,

        borderRadius:
        BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(.08),
            offset: const Offset(0, 6),
          )
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Colors.green.shade700,
              ),

              const SizedBox(width: 10),

              Text(
                tr("result"),

                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,

            padding:
            const EdgeInsets.symmetric(
              vertical: 15,
            ),

            decoration: BoxDecoration(
              color:
              Colors.green.withOpacity(.10),

              borderRadius:
              BorderRadius.circular(18),
            ),

            child: Center(
              child: Text(
                "${_valueController.text} ${tr(_selectedUnit)}",

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,

            physics:
            const NeverScrollableScrollPhysics(),

            crossAxisCount: 2,

            crossAxisSpacing: 14,
            mainAxisSpacing: 14,

            childAspectRatio: 1.55,

            children:
            _results.entries.map((entry) {
              return _resultBox(
                tr(entry.key),
                entry.value.toStringAsFixed(4),
                isDark,
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,

            padding:
            const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade500,
                ],
              ),

              borderRadius:
              BorderRadius.circular(18),
            ),

            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 30,
                ),

                const SizedBox(height: 8),

                const Text(
                  "Master Calculator App",

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  appLink,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyResult,

                  icon: const Icon(Icons.copy),

                  label: Text(tr("copy")),

                  style: OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareResult,

                  icon: const Icon(Icons.share),

                  label: Text(tr("share")),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green,

                    foregroundColor:
                    Colors.white,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // =========================
  // RESULT BOX
  // =========================

  Widget _resultBox(
      String title,
      String value,
      bool isDark,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff2b323c)
            : Colors.grey.shade50,

        borderRadius:
        BorderRadius.circular(22),

        border: Border.all(
          color:
          Colors.grey.withOpacity(.15),
        ),
      ),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Text(
            title,

            style: TextStyle(
              fontSize: 18,
              color: isDark
                  ? Colors.white70
                  : Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}