import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../services/database_service.dart';

class BudgetStatus {
  final BudgetModel budget;
  final double spent;
  final double remaining;
  final double percentage; // 0.0 to 1.0+
  final bool isWarning;
  final bool isOverBudget;

  BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.isWarning,
    required this.isOverBudget,
  });
}

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<TransactionModel> _transactions = [];
  List<BudgetModel> _budgets = [];

  String _searchQuery = '';
  String _filterType = 'All'; // 'All', 'Expense', 'Income'
  String? _filterCategory;
  String _timeRange = 'All'; // 'All', 'This Month', 'This Week', 'Today'

  List<TransactionModel> get transactions => _transactions;
  List<BudgetModel> get budgets => _budgets;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String? get filterCategory => _filterCategory;
  String get timeRange => _timeRange;

  ExpenseProvider() {
    loadData();
    purgeMockDataIfPresent();
  }

  Future<void> purgeMockDataIfPresent() async {
    final hasSeed = _transactions.any((tx) => tx.id.startsWith('seed_'));
    if (hasSeed) {
      await _db.clearAllTransactions();
      await _db.clearAllBudgets();
      loadData();
    }
  }

  void loadData() {
    _transactions = _db.getAllTransactions();
    _budgets = _db.getAllBudgets();
    notifyListeners();
  }

  // ==================== FILTERING ====================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setTimeRange(String range) {
    _timeRange = range;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();

    return _transactions.where((tx) {
      // Type filter
      if (_filterType == 'Expense' && !tx.isExpense) return false;
      if (_filterType == 'Income' && tx.isExpense) return false;

      // Category filter
      if (_filterCategory != null &&
          _filterCategory!.isNotEmpty &&
          _filterCategory != 'All') {
        if (tx.category.toLowerCase() != _filterCategory!.toLowerCase()) {
          return false;
        }
      }

      // Time range filter
      if (_timeRange == 'Today') {
        final isToday = tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
        if (!isToday) return false;
      } else if (_timeRange == 'This Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final beginningOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        if (tx.date.isBefore(beginningOfWeek)) return false;
      } else if (_timeRange == 'This Month') {
        final isThisMonth = tx.date.year == now.year && tx.date.month == now.month;
        if (!isThisMonth) return false;
      }

      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchesTitle = tx.title.toLowerCase().contains(q);
        final matchesCat = tx.category.toLowerCase().contains(q);
        final matchesNotes = tx.notes.toLowerCase().contains(q);
        if (!matchesTitle && !matchesCat && !matchesNotes) return false;
      }

      return true;
    }).toList();
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  // ==================== AGGREGATES ====================

  double get totalIncome {
    return _transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalBalance => totalIncome - totalExpense;

  double get thisMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            !tx.isExpense &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.isExpense &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get thisMonthBalance => thisMonthIncome - thisMonthExpense;

  // Category totals for this month's expenses
  Map<String, double> get thisMonthCategoryExpenses {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final tx in _transactions) {
      if (tx.isExpense &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  // Category totals for this month's incomes
  Map<String, double> get thisMonthCategoryIncomes {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final tx in _transactions) {
      if (!tx.isExpense &&
          tx.date.year == now.year &&
          tx.date.month == now.month) {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  // ==================== BUDGET LOGIC ====================

  List<BudgetStatus> get budgetStatuses {
    final catExpenses = thisMonthCategoryExpenses;
    final list = <BudgetStatus>[];

    for (final b in _budgets) {
      final spent = catExpenses[b.category] ?? 0.0;
      final limit = b.monthlyLimit;
      final percentage = limit > 0 ? (spent / limit) : 0.0;
      final remaining = limit - spent;
      final isOverBudget = spent >= limit;
      final isWarning = !isOverBudget && percentage >= b.alertThreshold;

      list.add(BudgetStatus(
        budget: b,
        spent: spent,
        remaining: remaining,
        percentage: percentage,
        isWarning: isWarning,
        isOverBudget: isOverBudget,
      ));
    }
    return list;
  }

  bool get hasOverBudgetAlert {
    return budgetStatuses.any((s) => s.isOverBudget || s.isWarning);
  }

  List<BudgetStatus> get alertBudgets {
    return budgetStatuses.where((s) => s.isOverBudget || s.isWarning).toList();
  }

  double get totalMonthlyBudgetLimit {
    return _budgets.fold(0.0, (sum, b) => sum + b.monthlyLimit);
  }

  double get totalMonthlyBudgetSpent {
    final catExpenses = thisMonthCategoryExpenses;
    return _budgets.fold(0.0, (sum, b) => sum + (catExpenses[b.category] ?? 0.0));
  }

  // ==================== CRUD OPERATIONS ====================

  Future<void> addTransaction(TransactionModel tx) async {
    await _db.saveTransaction(tx);
    loadData();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await _db.saveTransaction(tx);
    loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    loadData();
  }

  Future<void> clearAllData() async {
    await _db.clearAllTransactions();
    await _db.clearAllBudgets();
    loadData();
  }

  Future<void> resetToZero() async {
    await _db.clearAllTransactions();
    await _db.clearAllBudgets();
    loadData();
  }

  Future<void> setBudget(BudgetModel budget) async {
    await _db.saveBudget(budget);
    loadData();
  }

  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(id);
    loadData();
  }
}
