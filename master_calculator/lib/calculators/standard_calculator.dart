import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

class StandardCalculator extends StatefulWidget {
  const StandardCalculator({super.key});

  @override
  State<StandardCalculator> createState() => _StandardCalculatorState();
}

class _StandardCalculatorState extends State<StandardCalculator> with SingleTickerProviderStateMixin {
  String _equation = "0";
  String _result = "0";
  String _expression = "";
  String _memory = "0";
  String _history = "";
  List<String> _historyList = [];
  bool _isRadians = false;
  bool _showHistory = false;
  String _language = "English";

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _historyAnimationController;

  // Language translations
  Map<String, Map<String, String>> _translations = {
    "English": {
      "copy": "Copy result",
      "radians": "Radians mode",
      "degrees": "Degrees mode",
      "memoryAdded": "Added to memory",
      "memoryCleared": "Memory cleared",
      "invalidExpression": "Invalid expression",
      "copied": "Copied to clipboard",
      "history": "History",
      "clearHistory": "Clear History",
      "noHistory": "No history yet",
      "angleMode": "Angle Mode",
      "basic": "Basic",
      "scientific": "Scientific",
      "programmer": "Programmer",
    },
    "Hindi": {
      "copy": "परिणाम कॉपी करें",
      "radians": "रेडियन मोड",
      "degrees": "डिग्री मोड",
      "memoryAdded": "मेमोरी में जोड़ा गया",
      "memoryCleared": "मेमोरी साफ़ कर दी गई",
      "invalidExpression": "अमान्य अभिव्यक्ति",
      "copied": "क्लिपबोर्ड पर कॉपी किया गया",
      "history": "इतिहास",
      "clearHistory": "इतिहास साफ़ करें",
      "noHistory": "अभी तक कोई इतिहास नहीं",
      "angleMode": "कोण मोड",
      "basic": "बेसिक",
      "scientific": "साइंटिफिक",
      "programmer": "प्रोग्रामर",
    },
  };

  String getText(String key) {
    return _translations[_language]?[key] ?? _translations["English"]![key]!;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
    _historyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _historyAnimationController.dispose();
    super.dispose();
  }

  void _buttonPressed(String buttonText) {
    HapticFeedback.lightImpact();
    setState(() {
      if (buttonText == "AC") {
        _equation = "0";
        _result = "0";
      } else if (buttonText == "C") {
        if (_equation.length > 1) {
          _equation = _equation.substring(0, _equation.length - 1);
        } else {
          _equation = "0";
        }
      } else if (buttonText == "=") {
        _calculateResult();
      } else if (buttonText == "M+") {
        _memory = _result != "0" ? _result : _equation;
        _showSnackBar("${getText("memoryAdded")}: $_memory");
      } else if (buttonText == "M-") {
        _memory = "0";
        _showSnackBar(getText("memoryCleared"));
      } else if (buttonText == "MR") {
        if (_memory != "0") {
          if (_equation == "0") {
            _equation = _memory;
          } else {
            _equation += _memory;
          }
        }
      } else if (buttonText == "sin") {
        _addFunction("sin(");
      } else if (buttonText == "cos") {
        _addFunction("cos(");
      } else if (buttonText == "tan") {
        _addFunction("tan(");
      } else if (buttonText == "asin") {
        _addFunction("asin(");
      } else if (buttonText == "acos") {
        _addFunction("acos(");
      } else if (buttonText == "atan") {
        _addFunction("atan(");
      } else if (buttonText == "log") {
        _addFunction("log(");
      } else if (buttonText == "ln") {
        _addFunction("ln(");
      } else if (buttonText == "log10") {
        _addFunction("log10(");
      } else if (buttonText == "√") {
        _addFunction("sqrt(");
      } else if (buttonText == "∛") {
        _addFunction("cbrt(");
      } else if (buttonText == "x²") {
        _addFunction("^2");
      } else if (buttonText == "x³") {
        _addFunction("^3");
      } else if (buttonText == "xʸ") {
        _addFunction("^");
      } else if (buttonText == "1/x") {
        _addFunction("^(-1)");
      } else if (buttonText == "10ˣ") {
        _addFunction("10^");
      } else if (buttonText == "eˣ") {
        _addFunction("exp(");
      } else if (buttonText == "π") {
        if (_equation == "0") {
          _equation = "pi";
        } else {
          _equation += "pi";
        }
      } else if (buttonText == "e") {
        if (_equation == "0") {
          _equation = "e";
        } else {
          _equation += "e";
        }
      } else if (buttonText == "!") {
        _addFunction("!");
      } else if (buttonText == "(") {
        if (_equation == "0") {
          _equation = "(";
        } else {
          _equation += "(";
        }
      } else if (buttonText == ")") {
        _equation += ")";
      } else if (buttonText == "rad") {
        setState(() {
          _isRadians = !_isRadians;
        });
        _showSnackBar(_isRadians ? getText("radians") : getText("degrees"));
      } else if (buttonText == "Ans") {
        if (_result != "0" && _result != "Error") {
          if (_equation == "0") {
            _equation = _result;
          } else {
            _equation += _result;
          }
        }
      } else {
        if (_equation == "0") {
          _equation = buttonText;
        } else {
          _equation += buttonText;
        }
      }
    });
  }

  void _addFunction(String func) {
    if (_equation == "0") {
      _equation = func;
    } else {
      _equation += func;
    }
  }

  void _calculateResult() {
    _expression = _equation;
    _expression = _expression.replaceAll('×', '*');
    _expression = _expression.replaceAll('÷', '/');
    _expression = _expression.replaceAll('π', 'pi');
    _expression = _expression.replaceAll('e', 'e');
    _expression = _expression.replaceAll('√', 'sqrt');
    _expression = _expression.replaceAll('∛', 'cbrt');
    _expression = _expression.replaceAll('x²', '^2');
    _expression = _expression.replaceAll('x³', '^3');
    _expression = _expression.replaceAll('xʸ', '^');
    _expression = _expression.replaceAll('10ˣ', '10^');
    _expression = _expression.replaceAll('eˣ', 'exp');
    _expression = _expression.replaceAll('asin', 'asin');
    _expression = _expression.replaceAll('acos', 'acos');
    _expression = _expression.replaceAll('atan', 'atan');
    _expression = _expression.replaceAll('log10', 'log10');

    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();

      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) {
        _result = "Error";
      } else {
        if (eval == eval.roundToDouble()) {
          _result = eval.round().toString();
        } else {
          _result = eval.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }

        // Add to history
        String historyEntry = "$_equation = $_result";
        _historyList.insert(0, historyEntry);
        if (_historyList.length > 20) _historyList.removeLast();
      }
    } catch (e) {
      _result = "Error";
      _showSnackBar(getText("invalidExpression"));
    }
  }

  int _factorial(int n) {
    if (n < 0) return 0;
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    _showSnackBar(getText("copied"));
  }

  void _clearHistory() {
    setState(() {
      _historyList.clear();
    });
    _showSnackBar(getText("clearHistory"));
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  Widget _buildButton(String text, Color color, {double flex = 1, Color? textColor, double fontSize = 26}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: color,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _buttonPressed(text),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 65,
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: text.length > 2 ? fontSize - 6 : fontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.white,
                    ),
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
    final buttonBgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    const accentColor = Color(0xFF6366F1);
    const operatorColor = Color(0xFF8B5CF6);
    const memoryColor = Color(0xFF10B981);

    return Scaffold(
      appBar: AppBar(
        title: Text(_language == "English" ? "Standard Calculator" : "मानक कैलकुलेटर"),
        centerTitle: true,
        elevation: 0,
        actions: [
          // History Button
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
                if (_showHistory) {
                  _historyAnimationController.forward();
                } else {
                  _historyAnimationController.reverse();
                }
              });
            },
            tooltip: getText("history"),
          ),
          // Language Button
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: getText("angleMode"),
          ),
          // Copy Button
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyResult,
            tooltip: getText("copy"),
          ),
          // Angle Mode Indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              label: Text(
                _isRadians ? "RAD" : "DEG",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              backgroundColor: accentColor.withOpacity(0.2),
              side: BorderSide(color: accentColor.withOpacity(0.5)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // History/Equation Display
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _equation,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // Result Display
              GestureDetector(
                onLongPress: _copyResult,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  alignment: Alignment.centerRight,
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Divider(thickness: 1, height: 1),

              // Memory Functions Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _buildButton("M+", memoryColor, flex: 1, fontSize: 18),
                    _buildButton("M-", memoryColor, flex: 1, fontSize: 18),
                    _buildButton("MR", memoryColor, flex: 1, fontSize: 18),
                    _buildButton("MC", memoryColor, flex: 1, fontSize: 18),
                    _buildButton("Ans", operatorColor, flex: 1, fontSize: 18),
                  ],
                ),
              ),

              // Scientific Functions Row 1
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _buildButton("sin", operatorColor, flex: 1, fontSize: 16),
                    _buildButton("cos", operatorColor, flex: 1, fontSize: 16),
                    _buildButton("tan", operatorColor, flex: 1, fontSize: 16),
                    _buildButton("asin", operatorColor, flex: 1, fontSize: 14),
                    _buildButton("acos", operatorColor, flex: 1, fontSize: 14),
                    _buildButton("atan", operatorColor, flex: 1, fontSize: 14),
                  ],
                ),
              ),

              // Scientific Functions Row 2
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _buildButton("log", operatorColor, flex: 1, fontSize: 16),
                    _buildButton("ln", operatorColor, flex: 1, fontSize: 16),
                    _buildButton("log10", operatorColor, flex: 1, fontSize: 14),
                    _buildButton("√", operatorColor, flex: 1, fontSize: 20),
                    _buildButton("∛", operatorColor, flex: 1, fontSize: 20),
                    _buildButton("!", operatorColor, flex: 1, fontSize: 20),
                  ],
                ),
              ),

              // Scientific Functions Row 3
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _buildButton("x²", operatorColor, flex: 1, fontSize: 18),
                    _buildButton("x³", operatorColor, flex: 1, fontSize: 18),
                    _buildButton("xʸ", operatorColor, flex: 1, fontSize: 18),
                    _buildButton("10ˣ", operatorColor, flex: 1, fontSize: 14),
                    _buildButton("eˣ", operatorColor, flex: 1, fontSize: 14),
                    _buildButton("1/x", operatorColor, flex: 1, fontSize: 16),
                  ],
                ),
              ),

              // Constants Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _buildButton("π", operatorColor, flex: 1, fontSize: 20),
                    _buildButton("e", operatorColor, flex: 1, fontSize: 20),
                    _buildButton("(", buttonBgColor, flex: 1, fontSize: 24),
                    _buildButton(")", buttonBgColor, flex: 1, fontSize: 24),
                    _buildButton("rad", operatorColor, flex: 1, fontSize: 14),
                  ],
                ),
              ),

              // Main Calculator Buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Row 1: Clear, Percent, Division
                      Row(
                        children: [
                          _buildButton("AC", Colors.red.shade400, flex: 1),
                          _buildButton("C", Colors.orange.shade400, flex: 1),
                          _buildButton("%", operatorColor, flex: 1),
                          _buildButton("÷", operatorColor, flex: 1),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: 7, 8, 9, Multiplication
                      Row(
                        children: [
                          _buildButton("7", buttonBgColor, flex: 1),
                          _buildButton("8", buttonBgColor, flex: 1),
                          _buildButton("9", buttonBgColor, flex: 1),
                          _buildButton("×", operatorColor, flex: 1),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 3: 4, 5, 6, Subtraction
                      Row(
                        children: [
                          _buildButton("4", buttonBgColor, flex: 1),
                          _buildButton("5", buttonBgColor, flex: 1),
                          _buildButton("6", buttonBgColor, flex: 1),
                          _buildButton("-", operatorColor, flex: 1),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 4: 1, 2, 3, Addition
                      Row(
                        children: [
                          _buildButton("1", buttonBgColor, flex: 1),
                          _buildButton("2", buttonBgColor, flex: 1),
                          _buildButton("3", buttonBgColor, flex: 1),
                          _buildButton("+", operatorColor, flex: 1),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 5: 0, ., Equals
                      Row(
                        children: [
                          _buildButton("0", buttonBgColor, flex: 2),
                          _buildButton(".", buttonBgColor, flex: 1),
                          _buildButton("=", const Color(0xFF10B981), flex: 1, textColor: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // History Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(
              _showHistory ? 0 : MediaQuery.of(context).size.width,
              0,
              0,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Column(
                children: [
                  // History Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "History",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_sweep, color: Colors.white),
                              onPressed: _clearHistory,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _showHistory = false;
                                  _historyAnimationController.reverse();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // History List
                  Expanded(
                    child: _historyList.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            getText("noHistory"),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      itemCount: _historyList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _historyList[index].split(" = ")[0],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "= ${_historyList[index].split(" = ")[1]}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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