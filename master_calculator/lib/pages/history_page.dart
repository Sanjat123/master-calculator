import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  List<HistoryItem> _history = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  String _searchQuery = "";
  String _selectedFilter = "All";
  late AnimationController _animationController;

  final List<String> _filterOptions = ["All", "Standard", "Age", "EMI", "BMI", "GST", "SIP", "Currency", "Unit", "Discount", "Loan"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
    _animationController.forward(from: 0);
  }

  Future<void> _deleteItem(String id) async {
    await HistoryService.deleteFromHistory(id);
    await _loadHistory();
    _showSnackBar("Item deleted", Colors.green);
  }

  Future<void> _clearAllHistory() async {
    final count = _history.length;
    if (count == 0) {
      _showSnackBar("No history to clear", Colors.orange);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear History"),
        content: Text("Are you sure you want to clear all $count history items? This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await HistoryService.clearAllHistory();
              await _loadHistory();
              Navigator.pop(context);
              _showSnackBar("All history cleared", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(String id) async {
    await HistoryService.toggleFavorite(id);
    await _loadHistory();
    final item = _history.firstWhere((item) => item.id == id);
    _showSnackBar(
      item.isFavorite ? "Added to favorites" : "Removed from favorites",
      item.isFavorite ? Colors.amber : Colors.grey,
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar("Copied to clipboard", Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<HistoryItem> get _filteredItems {
    List<HistoryItem> items = _history;

    // Filter by calculator type
    if (_selectedFilter != "All") {
      items = items.where((item) =>
      item.calculatorType.toLowerCase() == _selectedFilter.toLowerCase()
      ).toList();
    }

    // Filter by favorites
    if (_showFavoritesOnly) {
      items = items.where((item) => item.isFavorite).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
      item.expression.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.result.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.calculatorType.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredCount = _filteredItems.length;
    final totalCount = _history.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Search Button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: "Search",
          ),
          // Favorites filter
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              color: _showFavoritesOnly ? Colors.amber : null,
            ),
            onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            tooltip: "Show favorites only",
          ),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllHistory,
              tooltip: "Clear all",
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 45,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? filter : "All";
                      });
                    },
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF6366F1),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar (if search active)
          if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _searchQuery,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => setState(() => _searchQuery = ""),
                  ),
                ],
              ),
            ),

          // Stats Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "$totalCount items",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                if (_searchQuery.isNotEmpty || _selectedFilter != "All" || _showFavoritesOnly)
                  Row(
                    children: [
                      Icon(Icons.filter_alt, size: 16, color: const Color(0xFF6366F1)),
                      const SizedBox(width: 4),
                      Text(
                        "$filteredCount result${filteredCount != 1 ? 's' : ''}",
                        style: TextStyle(fontSize: 12, color: const Color(0xFF6366F1)),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return _buildHistoryCard(item, isDark, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSearch = "";
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Search History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  onChanged: (value) => tempSearch = value,
                  decoration: InputDecoration(
                    hintText: "Search by expression or result...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _searchQuery = tempSearch);
                          Navigator.pop(context);
                        },
                        child: const Text("Search"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    String title = "No history yet";
    String message = "Your calculation history will appear here";

    if (_searchQuery.isNotEmpty) {
      title = "No matching results";
      message = "Try a different search term";
    } else if (_showFavoritesOnly) {
      title = "No favorites yet";
      message = "Star your favorite calculations to see them here";
    } else if (_selectedFilter != "All") {
      title = "No $_selectedFilter calculations";
      message = "Try a different filter";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off :
            _showFavoritesOnly ? Icons.star_border : Icons.history,
            size: 80,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_searchQuery.isNotEmpty && !_showFavoritesOnly && _selectedFilter == "All")
            const SizedBox(height: 16),

        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item, bool isDark, int index) {
    final calculatorColor = _getCalculatorColor(item.calculatorType);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) async {
          await HistoryService.deleteFromHistory(item.id);
          await _loadHistory();
          _showSnackBar("Item deleted", Colors.red);
        },
        child: Container(
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _copyToClipboard("${item.expression} = ${item.result}");
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: calculatorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCalculatorIcon(item.calculatorType),
                        color: calculatorColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.expression,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "= ${item.result}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: calculatorColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item.calculatorType,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: calculatorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            item.isFavorite ? Icons.star : Icons.star_border,
                            color: item.isFavorite ? Colors.amber : Colors.grey,
                            size: 22,
                          ),
                          onPressed: () => _toggleFavorite(item.id),
                          tooltip: item.isFavorite ? "Remove from favorites" : "Add to favorites",
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyToClipboard("${item.expression} = ${item.result}"),
                          tooltip: "Copy",
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => _deleteItem(item.id),
                          tooltip: "Delete",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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