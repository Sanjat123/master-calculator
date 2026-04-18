import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';


class StandardCalculator extends StatefulWidget {
  const StandardCalculator({super.key});

  @override
  State<StandardCalculator> createState() => _StandardCalculatorState();
}

class _StandardCalculatorState extends State<StandardCalculator> {
  String _equation = "";
  String _result = "";
  String _expression = "";
  bool _isRadians = false;

  @override
  void initState() {
    super.initState();
    _equation = "";
    _result = "0";
  }

  void _buttonPressed(String buttonText) {
    HapticFeedback.lightImpact();
    setState(() {
      if (buttonText == "AC") {
        _equation = "";
        _result = "0";
      }
      else if (buttonText == "C") {
        if (_equation.isNotEmpty) {
          _equation = _equation.substring(0, _equation.length - 1);
        }
        if (_equation.isEmpty) {
          _result = "0";
        }
      }
      else if (buttonText == "=") {
        _calculateResult();
      }
      else if (buttonText == "sin") {
        _equation += "sin(";
      }
      else if (buttonText == "cos") {
        _equation += "cos(";
      }
      else if (buttonText == "tan") {
        _equation += "tan(";
      }
      else if (buttonText == "log") {
        _equation += "log(";
      }
      else if (buttonText == "ln") {
        _equation += "ln(";
      }
      else if (buttonText == "√") {
        _equation += "√(";
      }
      else if (buttonText == "x²") {
        _equation += "^2";
      }
      else if (buttonText == "x³") {
        _equation += "^3";
      }
      else if (buttonText == "1/x") {
        _equation += "^-1";
      }
      else if (buttonText == "π") {
        _equation += "3.14159";
      }
      else if (buttonText == "e") {
        _equation += "2.71828";
      }
      else if (buttonText == "(") {
        _equation += "(";
      }
      else if (buttonText == ")") {
        _equation += ")";
      }
      else if (buttonText == "rad") {
        _isRadians = !_isRadians;
      }
      else {
        _equation += buttonText;
      }

      // Update result while typing
      if (buttonText != "=" && _equation.isNotEmpty) {
        _calculateLiveResult();
      }
    });
  }

  void _calculateLiveResult() {
    if (_equation.isEmpty) {
      _result = "0";
      return;
    }

    String expression = _equation;
    expression = expression.replaceAll('×', '*');
    expression = expression.replaceAll('÷', '/');
    expression = expression.replaceAll('√', 'sqrt');
    expression = expression.replaceAll('π', '3.14159265359');
    expression = expression.replaceAll('e', '2.71828182846');

    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) {
        _result = "Error";
      } else {
        if (eval == eval.roundToDouble()) {
          _result = eval.round().toString();
        } else {
          _result = eval.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
      }
    } catch (e) {
      _result = "0";
    }
  }

  void _calculateResult() {
    if (_equation.isEmpty) {
      _result = "0";
      return;
    }

    String expression = _equation;
    expression = expression.replaceAll('×', '*');
    expression = expression.replaceAll('÷', '/');
    expression = expression.replaceAll('√', 'sqrt');
    expression = expression.replaceAll('π', '3.14159265359');
    expression = expression.replaceAll('e', '2.71828182846');

    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) {
        _result = "Error";
      } else {
        if (eval == eval.roundToDouble()) {
          _result = eval.round().toString();
        } else {
          _result = eval.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
      }
    } catch (e) {
      _result = "Error";
    }
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!"), duration: Duration(seconds: 1)),
    );
  }

  Widget _buildButton(String text, Color color, {double flex = 1, Color? textColor}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          child: InkWell(
            onTap: () => _buttonPressed(text),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 65,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: text.length > 2 ? 18 : 24,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text(
                _isRadians ? "RAD" : "DEG",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyResult,
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Section
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Equation Display
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _equation.isEmpty ? " " : _equation,
                    style: TextStyle(
                      fontSize: 28,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Result Display
                Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(thickness: 1),

          // Scientific Functions Row 1
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildButton("sin", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("cos", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("tan", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("log", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("ln", const Color(0xFF8B5CF6), flex: 1),
              ],
            ),
          ),

          // Scientific Functions Row 2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildButton("√", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("x²", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("x³", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("1/x", const Color(0xFF8B5CF6), flex: 1),
                _buildButton("rad", const Color(0xFF8B5CF6), flex: 1),
              ],
            ),
          ),

          // Constants Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildButton("π", const Color(0xFF10B981), flex: 1),
                _buildButton("e", const Color(0xFF10B981), flex: 1),
                _buildButton("(", const Color(0xFF6366F1), flex: 1),
                _buildButton(")", const Color(0xFF6366F1), flex: 1),
                _buildButton("%", const Color(0xFFF59E0B), flex: 1),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Main Calculator Buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Row 1: AC, C, ÷
                  Row(
                    children: [
                      _buildButton("AC", const Color(0xFFEF4444), flex: 1),
                      _buildButton("C", const Color(0xFFF59E0B), flex: 1),
                      _buildButton("÷", const Color(0xFF6366F1), flex: 1),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Row 2: 7, 8, 9, ×
                  Row(
                    children: [
                      _buildButton("7", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("8", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("9", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("×", const Color(0xFF6366F1), flex: 1),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Row 3: 4, 5, 6, -
                  Row(
                    children: [
                      _buildButton("4", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("5", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("6", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("-", const Color(0xFF6366F1), flex: 1),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Row 4: 1, 2, 3, +
                  Row(
                    children: [
                      _buildButton("1", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("2", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("3", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("+", const Color(0xFF6366F1), flex: 1),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Row 5: 0, ., =
                  Row(
                    children: [
                      _buildButton("0", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 2, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton(".", isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), flex: 1, textColor: isDark ? Colors.white : Colors.black87),
                      _buildButton("=", const Color(0xFF22C55E), flex: 1),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}