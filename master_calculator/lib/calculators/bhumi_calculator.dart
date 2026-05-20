// ===============================================================
// FINAL PROFESSIONAL BHUMI CALCULATOR
// SIMPLE + ADVANCED MODE BOTH INCLUDED
// ===============================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class BhumiCalculator extends StatefulWidget {
  const BhumiCalculator({super.key});

  @override
  State<BhumiCalculator> createState() =>
      _BhumiCalculatorState();
}

class _BhumiCalculatorState
    extends State<BhumiCalculator> {
  // ======================================================
  // CONTROLLERS
  // ======================================================

  final TextEditingController valueController =
  TextEditingController();

  final ScreenshotController screenshotController =
  ScreenshotController();

  // ======================================================
  // APP LINK
  // ======================================================

  final String appLink =
      "https://play.google.com/store/apps/details?id=com.Master.Calculator&hl=en_IN";

  // ======================================================
  // LANGUAGE
  // ======================================================

  bool isHindi = true;

  String tr(String hi, String en) {
    return isHindi ? hi : en;
  }

  // ======================================================
  // MODE
  // ======================================================

  bool isAdvancedMode = false;

  // ======================================================
  // SIMPLE MODE
  // ======================================================

  String selectedUnit = "bigha";

  Map<String, double> unitToSqFt = {
    "bigha": 27225,
    "katha": 1361.25,
    "dhur": 68.0625,
    "acre": 43560,
    "decimal": 435.6,
    "hectare": 107639,
    "sqft": 1,
    "sqm": 10.7639,
  };

  // ======================================================
  // DISTRICTS
  // ======================================================

  String selectedDistrict = "Darbhanga";

  final List<String> districts = [
    "Araria",
    "Arwal",
    "Aurangabad",
    "Banka",
    "Begusarai",
    "Bhagalpur",
    "Bhojpur",
    "Buxar",
    "Darbhanga",
    "East Champaran",
    "Gaya",
    "Gopalganj",
    "Jamui",
    "Jehanabad",
    "Kaimur",
    "Katihar",
    "Khagaria",
    "Kishanganj",
    "Lakhisarai",
    "Madhepura",
    "Madhubani",
    "Munger",
    "Muzaffarpur",
    "Nalanda",
    "Nawada",
    "Patna",
    "Purnia",
    "Rohtas",
    "Saharsa",
    "Samastipur",
    "Saran",
    "Sheikhpura",
    "Sheohar",
    "Sitamarhi",
    "Siwan",
    "Supaul",
    "Vaishali",
    "West Champaran",
  ];

  // ======================================================
  // LAGGI
  // ======================================================

  final Map<String, double> districtLaggi = {
    "Darbhanga": 4.75,
    "Madhubani": 4.75,
    "Samastipur": 4.75,
    "Sitamarhi": 4.75,
    "Muzaffarpur": 4.75,
    "Patna": 4.50,
    "Gaya": 5.50,
    "Purnia": 5.25,
  };

  double laggi = 4.75;

  // ======================================================
  // ADVANCED VALUES
  // ======================================================

  int bigha = 1;
  int katha = 0;
  int dhur = 0;

  // ======================================================
  // RESULTS
  // ======================================================

  Map<String, double> results = {};

  // ======================================================
  // INIT
  // ======================================================

  @override
  void initState() {
    super.initState();
    calculateAdvanced();
  }

  // ======================================================
  // SIMPLE CALCULATION
  // ======================================================

  void calculateSimple() {
    FocusScope.of(context).unfocus();

    double value =
        double.tryParse(valueController.text) ?? 0;

    if (value <= 0) return;

    double sqFt =
        value * unitToSqFt[selectedUnit]!;

    setState(() {
      results = {
        "bigha":
        sqFt / unitToSqFt["bigha"]!,
        "katha":
        sqFt / unitToSqFt["katha"]!,
        "dhur":
        sqFt / unitToSqFt["dhur"]!,
        "acre":
        sqFt / unitToSqFt["acre"]!,
        "decimal":
        sqFt / unitToSqFt["decimal"]!,
        "hectare":
        sqFt / unitToSqFt["hectare"]!,
        "sqft": sqFt,
        "sqm":
        sqFt / unitToSqFt["sqm"]!,
      };
    });
  }

  // ======================================================
  // ADVANCED CALCULATION
  // ======================================================

  void calculateAdvanced() {
    double totalKatha =
        (bigha * 20) +
            katha +
            (dhur / 20);

    double sqFt = totalKatha * 1361.25;

    setState(() {
      results = {
        "bigha": totalKatha / 20,
        "katha": totalKatha,
        "dhur": totalKatha * 20,
        "acre": sqFt / 43560,
        "decimal": sqFt / 435.6,
        "hectare": sqFt / 107639,
        "sqft": sqFt,
        "sqm": sqFt / 10.7639,
      };
    });
  }

  // ======================================================
  // COPY
  // ======================================================

  void copyResult() {
    String text = "";

    results.forEach((key, value) {
      text +=
      "$key : ${value.toStringAsFixed(4)}\n";
    });

    Clipboard.setData(
      ClipboardData(text: text),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr("कॉपी हो गया", "Copied"),
        ),
      ),
    );
  }

  // ======================================================
  // SHARE
  // ======================================================

  Future<void> shareResult() async {
    try {
      final image =
      await screenshotController.capture();

      if (image == null) return;

      final directory =
      await getTemporaryDirectory();

      final imagePath =
      await File(
        '${directory.path}/bhumi_result.png',
      ).create();

      await imagePath.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text:
        "${tr(
          "🌱 Master Calculator App\n\nजमीन का सटीक हिसाब अब आपके मोबाइल में।\n\n✅ बीघा • कठा • धुर कैलकुलेटर\n✅ डेसिमल और एकड़ कन्वर्टर\n✅ गांव की जमीन माप सुविधा\n✅ आसान और तेज़ उपयोग\n\n📲 और भी फीचर्स, सटीक जानकारी और बेहतर अनुभव के लिए अभी ऐप डाउनलोड करें 👇",
          "🌱 Master Calculator App\n\nAccurate land measurement now on your mobile.\n\n✅ Bigha • Katha • Dhur Calculator\n✅ Decimal & Acre Converter\n✅ Village Land Measurement Tools\n✅ Easy and Fast to Use\n\n📲 Download the app now to explore more features, accurate calculations and a better experience 👇",
        )}\n\n$appLink", );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ======================================================
  // RESULT BOX
  // ======================================================

  Widget resultBox(
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),

        border: Border.all(
          color:
          Colors.green.withOpacity(.12),
        ),
      ),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Text(
            title,

            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // COUNTER CARD
  // ======================================================

  Widget counterCard({
    required String title,
    required int value,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        border: Border.all(
          color:
          Colors.green.withOpacity(.12),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.green,
              ),

              const SizedBox(width: 8),

              Text(
                title,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const Spacer(),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [
              InkWell(
                onTap: onRemove,

                child: Container(
                  height: 52,
                  width: 52,

                  decoration: BoxDecoration(
                    color:
                    Colors.grey.shade100,

                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: const Icon(
                    Icons.remove,
                  ),
                ),
              ),

              Text(
                value.toString(),

                style: const TextStyle(
                  fontSize: 32,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              InkWell(
                onTap: onAdd,

                child: Container(
                  height: 52,
                  width: 52,

                  decoration: BoxDecoration(
                    color: Colors.green,

                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ======================================================
  // UI
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xffedf5ef),

      appBar: AppBar(
        backgroundColor:
        const Color(0xff0f3d63),

        elevation: 0,

        title: Row(
          children: [
            const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
            ),

            const SizedBox(width: 10),

            Text(
              tr(
                "भूमि कैलकुलेटर",
                "Bhumi Calculator",
              ),

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isHindi = !isHindi;
              });
            },

            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ======================================================
            // MODE SWITCH
            // ======================================================

            Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isAdvancedMode = false;
                        });
                      },

                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        decoration: BoxDecoration(
                          color: !isAdvancedMode
                              ? Colors.green
                              : Colors.transparent,

                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            tr(
                              "सिंपल",
                              "Simple",
                            ),

                            style: TextStyle(
                              color:
                              !isAdvancedMode
                                  ? Colors.white
                                  : Colors.black,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isAdvancedMode = true;
                        });
                      },

                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        decoration: BoxDecoration(
                          color: isAdvancedMode
                              ? Colors.green
                              : Colors.transparent,

                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            tr(
                              "एडवांस",
                              "Advanced",
                            ),

                            style: TextStyle(
                              color:
                              isAdvancedMode
                                  ? Colors.white
                                  : Colors.black,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======================================================
            // SIMPLE MODE
            // ======================================================

            if (!isAdvancedMode)
              buildSimpleMode(),

            // ======================================================
            // ADVANCED MODE
            // ======================================================

            if (isAdvancedMode)
              buildAdvancedMode(),

            const SizedBox(height: 24),

            // ======================================================
            // RESULT
            // ======================================================

            if (results.isNotEmpty)
              Screenshot(
                controller:
                screenshotController,

                child: buildResultCard(),
              )
          ],
        ),
      ),
    );
  }

  // ======================================================
  // SIMPLE MODE UI
  // ======================================================

  Widget buildSimpleMode() {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(28),
      ),

      child: Column(
        children: [
          TextField(
            controller: valueController,

            keyboardType:
            const TextInputType.numberWithOptions(
              decimal: true,
            ),

            decoration: InputDecoration(
              hintText: tr(
                "मान डालें",
                "Enter Value",
              ),

              filled: true,

              fillColor:
              Colors.grey.shade100,

              prefixIcon: const Icon(
                Icons.square_foot,
              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: selectedUnit,

            decoration: InputDecoration(
              filled: true,

              fillColor:
              Colors.grey.shade100,

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                borderSide: BorderSide.none,
              ),
            ),

            items: unitToSqFt.keys.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit),
              );
            }).toList(),

            onChanged: (value) {
              setState(() {
                selectedUnit = value!;
              });
            },
          ),

          const SizedBox(height: 22),

          ElevatedButton(
            onPressed: calculateSimple,

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,

              foregroundColor: Colors.white,

              minimumSize:
              const Size(double.infinity, 58),

              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
            ),

            child: Text(
              tr(
                "हिसाब करें",
                "Calculate",
              ),

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ======================================================
  // ADVANCED MODE UI
  // ======================================================

  Widget buildAdvancedMode() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(28),
      ),

      child: Column(
        children: [
          // DISTRICT

          DropdownButtonFormField<String>(
            value: selectedDistrict,

            decoration: InputDecoration(
              filled: true,

              fillColor:
              Colors.green.withOpacity(.05),

              prefixIcon: const Icon(
                Icons.location_on_rounded,
              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                borderSide: BorderSide.none,
              ),
            ),

            items: districts.map((district) {
              return DropdownMenuItem(
                value: district,
                child: Text(district),
              );
            }).toList(),

            onChanged: (value) {
              setState(() {
                selectedDistrict = value!;

                laggi =
                    districtLaggi[value] ??
                        5.0;
              });

              calculateAdvanced();
            },
          ),

          const SizedBox(height: 20),

          // LAGGI

          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color:
              Colors.green.withOpacity(.05),

              borderRadius:
              BorderRadius.circular(
                22,
              ),
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [
                    Text(
                      tr(
                        "लगी का हाथ",
                        "Laggi Hand",
                      ),

                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(
                          .10,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: Text(
                        laggi
                            .toStringAsFixed(
                          2,
                        ),

                        style:
                        const TextStyle(
                          color:
                          Colors.green,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    )
                  ],
                ),

                Slider(
                  value: laggi,

                  min: 3,
                  max: 8,

                  activeColor:
                  Colors.green,

                  onChanged: (value) {
                    setState(() {
                      laggi = value;
                    });

                    calculateAdvanced();
                  },
                ),
              ],
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

            childAspectRatio: 1.1,

            children: [
              counterCard(
                title: "बीघा",
                value: bigha,

                icon:
                Icons.agriculture_rounded,

                onAdd: () {
                  bigha++;
                  calculateAdvanced();
                },

                onRemove: () {
                  if (bigha > 0) {
                    bigha--;
                    calculateAdvanced();
                  }
                },
              ),

              counterCard(
                title: "कठा",
                value: katha,

                icon:
                Icons.crop_square_rounded,

                onAdd: () {
                  katha++;
                  calculateAdvanced();
                },

                onRemove: () {
                  if (katha > 0) {
                    katha--;
                    calculateAdvanced();
                  }
                },
              ),

              counterCard(
                title: "धुर",
                value: dhur,

                icon:
                Icons.grid_view_rounded,

                onAdd: () {
                  dhur++;
                  calculateAdvanced();
                },

                onRemove: () {
                  if (dhur > 0) {
                    dhur--;
                    calculateAdvanced();
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  // ======================================================
  // RESULT CARD
  // ======================================================

  Widget buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900,
            Colors.green.shade700,
          ],
        ),

        borderRadius:
        BorderRadius.circular(28),
      ),

      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
              ),

              const SizedBox(width: 10),

              Text(
                tr(
                  "परिणाम",
                  "Results",
                ),

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 24,
                ),
              )
            ],
          ),

          const SizedBox(height: 22),

          GridView.count(
            shrinkWrap: true,

            physics:
            const NeverScrollableScrollPhysics(),

            crossAxisCount: 2,

            crossAxisSpacing: 14,
            mainAxisSpacing: 14,

            childAspectRatio: 1.2,

            children: [
              resultBox(
                tr(
                  "बीघा",
                  "Bigha",
                ),
                results["bigha"]!
                    .toStringAsFixed(4),
              ),

              resultBox(
                tr(
                  "कठा",
                  "Katha",
                ),
                results["katha"]!
                    .toStringAsFixed(4),
              ),

              resultBox(
                tr(
                  "धुर",
                  "Dhur",
                ),
                results["dhur"]!
                    .toStringAsFixed(4),
              ),

              resultBox(
                tr(
                  "वर्ग फुट",
                  "Square Feet",
                ),
                results["sqft"]!
                    .toStringAsFixed(2),
              ),

              resultBox(
                tr(
                  "डेसिमल",
                  "Decimal",
                ),
                results["decimal"]!
                    .toStringAsFixed(4),
              ),

              resultBox(
                tr(
                  "एकड़",
                  "Acre",
                ),
                results["acre"]!
                    .toStringAsFixed(4),
              ),

              resultBox(
                tr(
                  "हेक्टेयर",
                  "Hectare",
                ),
                results["hectare"]!
                    .toStringAsFixed(4),
              ),

              resultBox(
                tr(
                  "वर्ग मीटर",
                  "Sq Meter",
                ),
                results["sqm"]!
                    .toStringAsFixed(2),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(.10),

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 30,
                ),

                const SizedBox(height: 10),

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

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: copyResult,

                  icon: const Icon(
                    Icons.copy,
                  ),

                  label: Text(
                    tr(
                      "कॉपी",
                      "Copy",
                    ),
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.white,

                    foregroundColor:
                    Colors.green,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: shareResult,

                  icon: const Icon(
                    Icons.share,
                  ),

                  label: Text(
                    tr(
                      "शेयर",
                      "Share",
                    ),
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.black,

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
                        18,
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
}