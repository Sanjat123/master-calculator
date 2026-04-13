import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';

class LoanCalculator extends StatefulWidget {
  const LoanCalculator({super.key});

  @override
  State<LoanCalculator> createState() => _LoanCalculatorState();
}

class _LoanCalculatorState extends State<LoanCalculator> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  String _totalPayment = "0";
  String _totalInterest = "0";

  void _calculate() {
    double principal = double.tryParse(_amountController.text) ?? 0;
    double rate = (double.tryParse(_rateController.text) ?? 0) / 100;
    double years = double.tryParse(_yearsController.text) ?? 0;

    if (principal > 0 && rate > 0 && years > 0) {
      double totalInterest = principal * rate * years;
      double totalPayment = principal + totalInterest;

      setState(() {
        _totalPayment = totalPayment.toStringAsFixed(2);
        _totalInterest = totalInterest.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Calculator"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: "Loan Amount",
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rateController,
                      decoration: const InputDecoration(
                        labelText: "Interest Rate (%)",
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _yearsController,
                      decoration: const InputDecoration(
                        labelText: "Loan Term (Years)",
                        prefixIcon: Icon(Icons.timeline),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: "Calculate",
              icon: Icons.calculate,
              onPressed: _calculate,
            ),
            if (_totalPayment != "0") ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow("Total Payment", "₹$_totalPayment", Colors.green),
                      const SizedBox(height: 16),
                      _buildInfoRow("Total Interest", "₹$_totalInterest", Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}