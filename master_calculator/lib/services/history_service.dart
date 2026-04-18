import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String id;
  final String expression;
  final String result;
  final String calculatorType;
  final DateTime timestamp;
  final bool isFavorite;

  HistoryItem({
    required this.id,
    required this.expression,
    required this.result,
    required this.calculatorType,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'expression': expression,
    'result': result,
    'calculatorType': calculatorType,
    'timestamp': timestamp.toIso8601String(),
    'isFavorite': isFavorite,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    id: json['id'],
    expression: json['expression'],
    result: json['result'],
    calculatorType: json['calculatorType'],
    timestamp: DateTime.parse(json['timestamp']),
    isFavorite: json['isFavorite'] ?? false,
  );
}

class HistoryService {
  static const String _historyKey = 'calculation_history';
  static const String _favoritesKey = 'favorites';

  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString(_historyKey);
    if (historyString == null) return [];

    final List<dynamic> historyList = json.decode(historyString);
    return historyList.map((item) => HistoryItem.fromJson(item)).toList();
  }

  static Future<void> addToHistory({
    required String expression,
    required String result,
    required String calculatorType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<HistoryItem> history = await getHistory();

    final newItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      expression: expression,
      result: result,
      calculatorType: calculatorType,
      timestamp: DateTime.now(),
    );

    history.insert(0, newItem);

    // Keep only last 100 items
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    final String encoded = json.encode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  static Future<void> deleteFromHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<HistoryItem> history = await getHistory();
    history.removeWhere((item) => item.id == id);

    final String encoded = json.encode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<HistoryItem> history = await getHistory();
    final index = history.indexWhere((item) => item.id == id);
    if (index != -1) {
      history[index] = HistoryItem(
        id: history[index].id,
        expression: history[index].expression,
        result: history[index].result,
        calculatorType: history[index].calculatorType,
        timestamp: history[index].timestamp,
        isFavorite: !history[index].isFavorite,
      );

      final String encoded = json.encode(history.map((item) => item.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
    }
  }

  static Future<List<HistoryItem>> getFavorites() async {
    final history = await getHistory();
    return history.where((item) => item.isFavorite).toList();
  }
}