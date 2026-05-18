import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BhumiCalculator extends StatefulWidget {
  const BhumiCalculator({super.key});

  @override
  State<BhumiCalculator> createState() => _BhumiCalculatorState();
}

class _BhumiCalculatorState extends State<BhumiCalculator> {
  // Input Controllers
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();

  // Results
  double _sqFt = 0;
  double _bigha = 0;
  double _katha = 0;
  double _dhur = 0;
  double _decimal = 0;

  // Bihar/UP Standard (Varies by region, but these are most common)
  // 1 Katha = 1361.25 sq ft (Standard in many parts of Bihar)
  final double _sqFtPerKatha = 1361.25;
  final double _sqFtPerDecimal = 435.6;

  void _calculateLand() {
    double length = double.tryParse(_lengthController.text) ?? 0;
    double width = double.tryParse(_widthController.text) ?? 0;

    setState(() {
      _sqFt = length * width;

      // Calculate Katha & Dhur
      // 1 Bigha = 20 Katha, 1 Katha = 20 Dhur
      double totalKatha = _sqFt / _sqFtPerKatha;
      _bigha = (totalKatha / 20).floorToDouble();
      _katha = (totalKatha % 20).floorToDouble();

      // 1 Katha has 20 Dhur, so we take the remaining katha and multiply by 20
      double remainingKatha = totalKatha - (totalKatha.floorToDouble());
      _dhur = double.parse((remainingKatha * 20).toStringAsFixed(2));

      // Decimal calculation
      _decimal = double.parse((_sqFt / _sqFtPerDecimal).toStringAsFixed(2));
    });
    HapticFeedback.mediumImpact();
  }

  void _clear() {
    _lengthController.clear();
    _widthController.clear();
    setState(() {
      _sqFt = 0; _bigha = 0; _katha = 0; _dhur = 0; _decimal = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Bhumi Calculator (Jamin)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputCard(isDark),
            const SizedBox(height: 25),
            if (_sqFt > 0) _buildResultCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Lumbai aur Choudai (Feet mein)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _lengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Lumbai (Length in ft)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _widthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Choudai (Width in ft)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _calculateLand,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(15)),
                    child: const Text("Calculate", style: TextStyle(color: Colors.white)))),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _clear,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(15)),
                    child: const Text("Clear", style: TextStyle(color: Colors.white))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(bool isDark) {
    return Column(
      children: [
        _resultRow("Total Area:", "${_sqFt.toStringAsFixed(2)} Sq. Ft", Colors.blue),
        const Divider(),
        _resultRow("Bigha:", "${_bigha.toInt()}", Colors.orange),
        _resultRow("Katha:", "${_katha.toInt()}", Colors.orange),
        _resultRow("Dhur:", "$_dhur", Colors.orange),
        const Divider(),
        _resultRow("Decimal:", "$_decimal", Colors.teal),
      ],
    );
  }

  Widget _resultRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}