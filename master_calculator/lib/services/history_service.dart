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
  static const String _backupKey = 'cloud_backup';
  static const String _lastBackupKey = 'last_backup';
  static const String _statsKey = 'history_stats';

  // ==================== BASIC CRUD OPERATIONS ====================

  // Get all history items
  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString(_historyKey);
    if (historyString == null) return [];

    final List<dynamic> historyList = json.decode(historyString);
    return historyList.map((item) => HistoryItem.fromJson(item)).toList();
  }

  // Add new item to history
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

    // Update statistics
    await _updateStatistics();
  }

  // Delete single item from history
  static Future<void> deleteFromHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<HistoryItem> history = await getHistory();
    history.removeWhere((item) => item.id == id);

    final String encoded = json.encode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);

    // Update statistics
    await _updateStatistics();
  }

  // Clear all history
  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_statsKey);
  }

  // Toggle favorite status
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

  // Get only favorite items
  static Future<List<HistoryItem>> getFavorites() async {
    final history = await getHistory();
    return history.where((item) => item.isFavorite).toList();
  }

  // ==================== STATISTICS METHODS ====================

  // Get history count
  static Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }

  // Get favorites count
  static Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  // Get statistics by calculator type
  static Future<Map<String, int>> getStatisticsByType() async {
    final history = await getHistory();
    final Map<String, int> stats = {};

    for (var item in history) {
      final type = item.calculatorType;
      stats[type] = (stats[type] ?? 0) + 1;
    }

    return stats;
  }

  // Get total calculations count
  static Future<int> getTotalCalculations() async {
    final history = await getHistory();
    return history.length;
  }

  // Get today's calculations count
  static Future<int> getTodayCalculations() async {
    final history = await getHistory();
    final today = DateTime.now();
    return history.where((item) =>
    item.timestamp.year == today.year &&
        item.timestamp.month == today.month &&
        item.timestamp.day == today.day
    ).length;
  }

  // Get this week's calculations count
  static Future<int> getThisWeekCalculations() async {
    final history = await getHistory();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return history.where((item) => item.timestamp.isAfter(weekAgo)).length;
  }

  // Update statistics
  static Future<void> _updateStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = {
      'total': await getTotalCalculations(),
      'favorites': await getFavoritesCount(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_statsKey, json.encode(stats));
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsString = prefs.getString(_statsKey);
    if (statsString == null) {
      return {
        'total': 0,
        'favorites': 0,
        'lastUpdated': null,
      };
    }
    return json.decode(statsString);
  }

  // ==================== BACKUP & RESTORE METHODS ====================

  // Backup to cloud (simulated with SharedPreferences)
  static Future<bool> backupToCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      final backupData = json.encode(history.map((item) => item.toJson()).toList());
      await prefs.setString(_backupKey, backupData);
      await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Restore from cloud backup
  static Future<bool> restoreFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupString = prefs.getString(_backupKey);
      if (backupString == null) return false;

      final List<dynamic> backupList = json.decode(backupString);
      final restoredHistory = backupList.map((item) => HistoryItem.fromJson(item)).toList();

      final String encoded = json.encode(restoredHistory.map((item) => item.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
      await _updateStatistics();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get last backup time
  static Future<String?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final backupTime = prefs.getString(_lastBackupKey);
    if (backupTime == null) return null;

    final date = DateTime.parse(backupTime);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  // Check if backup exists
  static Future<bool> hasBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_backupKey);
  }

  // ==================== SEARCH METHODS ====================

  // Search history by query
  static Future<List<HistoryItem>> searchHistory(String query) async {
    if (query.isEmpty) return await getHistory();

    final history = await getHistory();
    final lowerQuery = query.toLowerCase();

    return history.where((item) =>
    item.expression.toLowerCase().contains(lowerQuery) ||
        item.result.toLowerCase().contains(lowerQuery) ||
        item.calculatorType.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Filter by calculator type
  static Future<List<HistoryItem>> filterByType(String calculatorType) async {
    final history = await getHistory();
    if (calculatorType == "All") return history;

    return history.where((item) =>
    item.calculatorType.toLowerCase() == calculatorType.toLowerCase()
    ).toList();
  }

  // ==================== EXPORT METHODS ====================

  // Export history as JSON string
  static Future<String> exportHistoryAsJson() async {
    final history = await getHistory();
    return json.encode(history.map((item) => item.toJson()).toList());
  }

  // Import history from JSON string
  static Future<bool> importHistoryFromJson(String jsonString) async {
    try {
      final List<dynamic> historyList = json.decode(jsonString);
      final importedHistory = historyList.map((item) => HistoryItem.fromJson(item)).toList();

      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(importedHistory.map((item) => item.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
      await _updateStatistics();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== CLEANUP METHODS ====================

  // Delete old history items (older than days)
  static Future<int> deleteOldHistory(int days) async {
    final prefs = await SharedPreferences.getInstance();
    List<HistoryItem> history = await getHistory();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final newHistory = history.where((item) => item.timestamp.isAfter(cutoffDate)).toList();
    final deletedCount = history.length - newHistory.length;

    final String encoded = json.encode(newHistory.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
    await _updateStatistics();

    return deletedCount;
  }

  // Delete all favorites
  static Future<void> deleteAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<HistoryItem> history = await getHistory();

    final newHistory = history.where((item) => !item.isFavorite).toList();

    final String encoded = json.encode(newHistory.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
    await _updateStatistics();
  }
}