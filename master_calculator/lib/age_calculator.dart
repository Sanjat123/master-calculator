import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  State<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> {
  DateTime? _selectedDate;
  String ageResult = "Select your Birthday";

  void _calculateAge() {
    if (_selectedDate == null) return;
    DateTime today = DateTime.now();
    int years = today.year - _selectedDate!.year;
    int months = today.month - _selectedDate!.month;
    int days = today.day - _selectedDate!.day;

    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += (months < 0) ? 12 : 0;
    }

    setState(() {
      ageResult = "$years Years, $months Months old";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Age Calculator")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ageResult, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  _calculateAge();
                }
              },
              child: const Text("Pick Birth Date"),
            ),
          ],
        ),
      ),
    );
  }
}