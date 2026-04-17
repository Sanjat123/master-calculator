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
  List<String> _historyList = [];
  bool _isRadians = false;
  bool _showHistory = false;
  String _language = "English";
  String _mode = "standard"; // standard, scientific, programmer

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _historyAnimationController;

  // Color scheme
  final Color _primaryColor = const Color(0xFF6366F1);
  final Color _secondaryColor = const Color(0xFF8B5CF6);
  final Color _operatorColor = const Color(0xFFF59E0B);
  final Color _numberColor = const Color(0xFF1E293B);
  final Color _functionColor = const Color(0xFF10B981);
  final Color _memoryColor = const Color(0xFF06B6D4);
  final Color _clearColor = const Color(0xFFEF4444);
  final Color _equalsColor = const Color(0xFF22C55E);

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
      "standard": "Standard",
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
      "standard": "मानक",
      "scientific": "वैज्ञानिक",
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

        String historyEntry = "$_equation = $_result";
        _historyList.insert(0, historyEntry);
        if (_historyList.length > 20) _historyList.removeLast();
      }
    } catch (e) {
      _result = "Error";
      _showSnackBar(getText("invalidExpression"));
    }
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

  Widget _buildButton(String text, Color color, {double flex = 1, Color? textColor, double fontSize = 24}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: text.length > 2 ? fontSize - 4 : fontSize,
                    fontWeight: FontWeight.w600,
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

    // Button colors based on mode
    final numberBtnColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final numberTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_language == "English" ? "Standard Calculator" : "मानक कैलकुलेटर"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Mode Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: DropdownButton<String>(
              value: _mode,
              icon: const Icon(Icons.settings_applications),
              underline: const SizedBox(),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              items: const [
                DropdownMenuItem(value: "standard", child: Text("Standard")),
                DropdownMenuItem(value: "scientific", child: Text("Scientific")),
              ],
              onChanged: (value) {
                setState(() {
                  _mode = value!;
                });
              },
            ),
          ),
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
              backgroundColor: _primaryColor.withOpacity(0.2),
              side: BorderSide(color: _primaryColor.withOpacity(0.5)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Display Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Equation Display
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _equation,
                        style: TextStyle(
                          fontSize: 28,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Result Display
                    GestureDetector(
                      onLongPress: _copyResult,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 1, height: 1),

              // Memory Functions Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _buildButton("M+", _memoryColor, flex: 1, fontSize: 16),
                    const SizedBox(width: 8),
                    _buildButton("M-", _memoryColor, flex: 1, fontSize: 16),
                    const SizedBox(width: 8),
                    _buildButton("MR", _memoryColor, flex: 1, fontSize: 16),
                    const SizedBox(width: 8),
                    _buildButton("MC", _memoryColor, flex: 1, fontSize: 16),
                    const SizedBox(width: 8),
                    _buildButton("Ans", _operatorColor, flex: 1, fontSize: 16),
                  ],
                ),
              ),

              // Scientific Functions (only in scientific mode)
              if (_mode == "scientific") ...[
                // Row 1: Trig Functions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      _buildButton("sin", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("cos", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("tan", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("asin", _functionColor, flex: 1, fontSize: 12),
                      const SizedBox(width: 6),
                      _buildButton("acos", _functionColor, flex: 1, fontSize: 12),
                      const SizedBox(width: 6),
                      _buildButton("atan", _functionColor, flex: 1, fontSize: 12),
                    ],
                  ),
                ),
                // Row 2: Log Functions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      _buildButton("log", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("ln", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("log10", _functionColor, flex: 1, fontSize: 12),
                      const SizedBox(width: 6),
                      _buildButton("√", _functionColor, flex: 1, fontSize: 18),
                      const SizedBox(width: 6),
                      _buildButton("∛", _functionColor, flex: 1, fontSize: 18),
                      const SizedBox(width: 6),
                      _buildButton("!", _functionColor, flex: 1, fontSize: 18),
                    ],
                  ),
                ),
                // Row 3: Power Functions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      _buildButton("x²", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("x³", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("xʸ", _functionColor, flex: 1, fontSize: 14),
                      const SizedBox(width: 6),
                      _buildButton("10ˣ", _functionColor, flex: 1, fontSize: 12),
                      const SizedBox(width: 6),
                      _buildButton("eˣ", _functionColor, flex: 1, fontSize: 12),
                      const SizedBox(width: 6),
                      _buildButton("1/x", _functionColor, flex: 1, fontSize: 14),
                    ],
                  ),
                ),
                // Row 4: Constants
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      _buildButton("π", _functionColor, flex: 1, fontSize: 16),
                      const SizedBox(width: 6),
                      _buildButton("e", _functionColor, flex: 1, fontSize: 16),
                      const SizedBox(width: 6),
                      _buildButton("(", _operatorColor, flex: 1, fontSize: 20),
                      const SizedBox(width: 6),
                      _buildButton(")", _operatorColor, flex: 1, fontSize: 20),
                      const SizedBox(width: 6),
                      _buildButton("rad", _operatorColor, flex: 1, fontSize: 12),
                    ],
                  ),
                ),
              ],

              // Main Calculator Buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Row 1: AC, C, %, ÷
                      Row(
                        children: [
                          _buildButton("AC", _clearColor, flex: 1, fontSize: 18),
                          const SizedBox(width: 8),
                          _buildButton("C", _clearColor, flex: 1, fontSize: 18),
                          const SizedBox(width: 8),
                          _buildButton("%", _operatorColor, flex: 1, fontSize: 18),
                          const SizedBox(width: 8),
                          _buildButton("÷", _operatorColor, flex: 1, fontSize: 24),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: 7, 8, 9, ×
                      Row(
                        children: [
                          _buildButton("7", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("8", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("9", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("×", _operatorColor, flex: 1, fontSize: 24),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 3: 4, 5, 6, -
                      Row(
                        children: [
                          _buildButton("4", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("5", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("6", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("-", _operatorColor, flex: 1, fontSize: 28),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 4: 1, 2, 3, +
                      Row(
                        children: [
                          _buildButton("1", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("2", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("3", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton("+", _operatorColor, flex: 1, fontSize: 28),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 5: 0, ., =
                      Row(
                        children: [
                          _buildButton("0", numberBtnColor, flex: 2, textColor: numberTextColor, fontSize: 24),
                          const SizedBox(width: 8),
                          _buildButton(".", numberBtnColor, flex: 1, textColor: numberTextColor, fontSize: 28),
                          const SizedBox(width: 8),
                          _buildButton("=", _equalsColor, flex: 1, fontSize: 28),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryColor,
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
                            color: _primaryColor.withOpacity(0.1),
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