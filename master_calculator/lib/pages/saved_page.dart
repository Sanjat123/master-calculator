import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/history_service.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<HistoryItem> _savedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    setState(() => _isLoading = true);
    final savedItems = await HistoryService.getFavorites();
    setState(() {
      _savedItems = savedItems;
      _isLoading = false;
    });
  }

  Future<void> _removeFromSaved(String id) async {
    await HistoryService.toggleFavorite(id);
    await _loadSavedItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Removed from saved"), duration: Duration(seconds: 1)),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard"), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Saved"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_savedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(),
              tooltip: "Clear all saved",
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedItems.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedItems.length,
        itemBuilder: (context, index) {
          final item = _savedItems[index];
          return _buildSavedCard(item, isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 80,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            "No saved items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "Star your favorite calculations to see them here",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(Icons.calculate, color: const Color(0xFF6366F1)),
            onPressed: () => Navigator.pop(context),
            tooltip: "Go to calculators",
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(HistoryItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCalculatorColor(item.calculatorType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCalculatorIcon(item.calculatorType),
                color: _getCalculatorColor(item.calculatorType),
                size: 24,
              ),
            ),
            title: Text(
              item.expression,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "= ${item.result}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(item.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCalculatorColor(item.calculatorType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.calculatorType,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: _getCalculatorColor(item.calculatorType),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard("${item.expression} = ${item.result}"),
                  tooltip: "Copy",
                ),
                IconButton(
                  icon: const Icon(Icons.star, size: 20, color: Colors.amber),
                  onPressed: () => _removeFromSaved(item.id),
                  tooltip: "Remove from saved",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Saved"),
        content: const Text("Are you sure you want to remove all saved items?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              for (var item in _savedItems) {
                await HistoryService.toggleFavorite(item.id);
              }
              await _loadSavedItems();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All saved items cleared"), duration: Duration(seconds: 1)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  IconData _getCalculatorIcon(String calculatorType) {
    switch (calculatorType.toLowerCase()) {
      case 'standard': return Icons.calculate;
      case 'age': return Icons.cake;
      case 'emi': return Icons.account_balance;
      case 'bmi': return Icons.fitness_center;
      case 'gst': return Icons.receipt;
      case 'sip': return Icons.trending_up;
      case 'currency': return Icons.currency_exchange;
      case 'unit': return Icons.straighten;
      case 'discount': return Icons.local_offer;
      case 'loan': return Icons.money;
      default: return Icons.calculate;
    }
  }

  Color _getCalculatorColor(String calculatorType) {
    switch (calculatorType.toLowerCase()) {
      case 'standard': return Colors.blue;
      case 'age': return Colors.orange;
      case 'emi': return Colors.green;
      case 'bmi': return Colors.red;
      case 'gst': return Colors.pink;
      case 'sip': return Colors.teal;
      case 'currency': return Colors.deepOrange;
      case 'unit': return Colors.indigo;
      case 'discount': return Colors.cyan;
      case 'loan': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
    } else {
      return "Just now";
    }
  }
}