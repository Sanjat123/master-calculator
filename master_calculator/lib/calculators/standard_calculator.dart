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
  String _result = "0";
  bool _isScientific = false;
  bool _isSecondFunction = false;
  bool _isRadians = true;

  void _buttonPressed(String buttonText) {
    HapticFeedback.lightImpact();
    setState(() {
      if (buttonText == "AC") {
        _equation = "";
        _result = "0";
        _isSecondFunction = false;
      } else if (buttonText == "C") {
        if (_equation.isNotEmpty) {
          _equation = _equation.substring(0, _equation.length - 1);
        }
        if (_equation.isEmpty) _result = "0";
      } else if (buttonText == "2nd") {
        _isSecondFunction = !_isSecondFunction;
        return;
      } else if (buttonText == "=") {
        _calculateResult(finalEval: true);
      } else if (buttonText == "deg" || buttonText == "rad") {
        _isRadians = !_isRadians;
      } else {
        _handleScientificInput(buttonText);
      }

      if (buttonText != "=" && _equation.isNotEmpty) {
        _calculateResult(finalEval: false);
      }
    });
  }

  void _handleScientificInput(String btn) {
    switch (btn) {
      case "sin": _equation += _isSecondFunction ? "asin(" : "sin("; break;
      case "cos": _equation += _isSecondFunction ? "acos(" : "cos("; break;
      case "tan": _equation += _isSecondFunction ? "atan(" : "tan("; break;
      case "log": _equation += _isSecondFunction ? "10^" : "log("; break;
      case "ln": _equation += _isSecondFunction ? "exp(" : "ln("; break;
      case "√": _equation += _isSecondFunction ? "cbrt(" : "sqrt("; break;
      case "x²": _equation += "^2"; break;
      case "x³": _equation += "^3"; break;
      case "xʸ": _equation += "^"; break;
      case "π": _equation += "pi"; break;
      case "e": _equation += "e"; break;
      default: _equation += btn;
    }
    if (_isSecondFunction) _isSecondFunction = false;
  }

  void _calculateResult({required bool finalEval}) {
    try {
      String expression = _equation
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('√', 'sqrt')
          .replaceAll('%', '/100');

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      String formatted = _formatResult(eval);
      if (finalEval) {
        _equation = formatted;
        _result = "";
      } else {
        _result = formatted;
      }
    } catch (e) {
      if (finalEval) _result = "Error";
    }
  }

  String _formatResult(double eval) {
    if (eval.isNaN || eval.isInfinite) return "Error";
    if (eval == eval.roundToDouble()) return eval.round().toString();
    return eval.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  Widget _buildButton(String text, Color color, {double flex = 1, Color? textColor, double? height}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _buttonPressed(text),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: height ?? 60,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.white,
                  ),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_isScientific ? "Scientific" : "Standard"),
        actions: [
          Switch(
            value: _isScientific,
            onChanged: (v) => setState(() => _isScientific = v),
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(_equation, style: TextStyle(fontSize: 30, color: isDark ? Colors.grey : Colors.blueGrey)),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_result, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            // Scientific Panel (Only shown if _isScientific is true)
            if (_isScientific)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Row(children: [
                      _buildButton("2nd", _isSecondFunction ? Colors.orange : Colors.indigo, height: 45),
                      _buildButton("deg", Colors.blueGrey, height: 45),
                      _buildButton("sin", Colors.deepPurple, height: 45),
                      _buildButton("cos", Colors.deepPurple, height: 45),
                      _buildButton("tan", Colors.deepPurple, height: 45),
                    ]),
                    Row(children: [
                      _buildButton("xʸ", Colors.indigo, height: 45),
                      _buildButton("log", Colors.indigo, height: 45),
                      _buildButton("ln", Colors.indigo, height: 45),
                      _buildButton("(", Colors.blueGrey, height: 45),
                      _buildButton(")", Colors.blueGrey, height: 45),
                    ]),
                    Row(children: [
                      _buildButton("√", Colors.teal, height: 45),
                      _buildButton("x²", Colors.teal, height: 45),
                      _buildButton("π", Colors.teal, height: 45),
                      _buildButton("e", Colors.teal, height: 45),
                      _buildButton("%", Colors.orange, height: 45),
                    ]),
                  ],
                ),
              ),

            const Divider(),

            // Main Pad
            Container(
              padding: const EdgeInsets.all(8),
              height: size.height * (_isScientific ? 0.4 : 0.55),
              child: Column(
                children: [
                  Expanded(child: Row(children: [
                    _buildButton("AC", Colors.redAccent),
                    _buildButton("C", Colors.orangeAccent),
                    _buildButton("÷", const Color(0xFF6366F1)),
                  ])),
                  _buildNumericRow(["7", "8", "9", "×"], isDark),
                  _buildNumericRow(["4", "5", "6", "-"], isDark),
                  _buildNumericRow(["1", "2", "3", "+"], isDark),
                  Expanded(child: Row(children: [
                    _buildButton("0", isDark ? Colors.blueGrey.shade800 : Colors.white, flex: 2, textColor: isDark ? Colors.white : Colors.black),
                    _buildButton(".", isDark ? Colors.blueGrey.shade800 : Colors.white, textColor: isDark ? Colors.white : Colors.black),
                    _buildButton("=", Colors.green),
                  ])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericRow(List<String> texts, bool isDark) {
    return Expanded(
      child: Row(
        children: texts.map((t) {
          bool isOp = ["×", "-", "+"].contains(t);
          return _buildButton(
            t,
            isOp ? const Color(0xFF6366F1) : (isDark ? Colors.blueGrey.shade800 : Colors.white),
            textColor: isOp ? Colors.white : (isDark ? Colors.white : Colors.black),
          );
        }).toList(),
      ),
    );
  }
}