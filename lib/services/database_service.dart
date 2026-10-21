import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static const String transactionsBoxName = 'transactions_box';
  static const String budgetsBoxName = 'budgets_box';
  static const String settingsBoxName = 'settings_box';
  static const String usersBoxName = 'users_box';
  static const String authBoxName = 'auth_box';

  late Box<Map> _transactionsBox;
  late Box<Map> _budgetsBox;
  late Box<dynamic> _settingsBox;
  late Box<Map> _usersBox;
  late Box<dynamic> _authBox;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes the embedded on-device Hive database
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    _transactionsBox = await Hive.openBox<Map>(transactionsBoxName);
    _budgetsBox = await Hive.openBox<Map>(budgetsBoxName);
    _settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
    _usersBox = await Hive.openBox<Map>(usersBoxName);
    _authBox = await Hive.openBox<dynamic>(authBoxName);

    _isInitialized = true;
  }

  // ==================== AUTHENTICATION & USERS ====================

  bool isLoggedIn() {
    return _authBox.get('isLoggedIn', defaultValue: false) as bool;
  }

  String? getCurrentUserId() {
    return _authBox.get('currentUserId') as String?;
  }

  UserModel? getCurrentUser() {
    final uid = getCurrentUserId();
    if (uid == null) return null;
    final map = _usersBox.get(uid);
    if (map == null) return null;
    return UserModel.fromMap(map);
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    // Check if email already exists
    for (final key in _usersBox.keys) {
      final map = _usersBox.get(key);
      if (map != null && map['email']?.toString().toLowerCase() == cleanEmail) {
        return false; // Email already in use
      }
    }

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      id: id,
      name: name.trim(),
      email: cleanEmail,
      password: password,
      createdAt: DateTime.now(),
    );

    await _usersBox.put(id, user.toMap());
    await _authBox.put('isLoggedIn', true);
    await _authBox.put('currentUserId', id);
    await _settingsBox.put('userName', user.name);

    return true;
  }

  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    for (final key in _usersBox.keys) {
      final map = _usersBox.get(key);
      if (map != null) {
        final user = UserModel.fromMap(map);
        if (user.email.toLowerCase() == cleanEmail && user.password == password) {
          await _authBox.put('isLoggedIn', true);
          await _authBox.put('currentUserId', user.id);
          await _settingsBox.put('userName', user.name);
          return user;
        }
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _authBox.put('isLoggedIn', false);
    await _authBox.delete('currentUserId');
  }

  // ==================== TRANSACTIONS ====================

  List<TransactionModel> getAllTransactions() {
    final list = <TransactionModel>[];
    for (final key in _transactionsBox.keys) {
      final map = _transactionsBox.get(key);
      if (map != null) {
        try {
          list.add(TransactionModel.fromMap(map));
        } catch (e) {
          debugPrint('Error parsing transaction: $e');
        }
      }
    }
    // Sort descending by date
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveTransaction(TransactionModel tx) async {
    await _transactionsBox.put(tx.id, tx.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  Future<void> clearAllTransactions() async {
    await _transactionsBox.clear();
  }

  // ==================== BUDGETS ====================

  List<BudgetModel> getAllBudgets() {
    final list = <BudgetModel>[];
    for (final key in _budgetsBox.keys) {
      final map = _budgetsBox.get(key);
      if (map != null) {
        try {
          list.add(BudgetModel.fromMap(map));
        } catch (e) {
          debugPrint('Error parsing budget: $e');
        }
      }
    }
    return list;
  }

  Future<void> saveBudget(BudgetModel budget) async {
    await _budgetsBox.put(budget.id, budget.toMap());
  }

  Future<void> deleteBudget(String id) async {
    await _budgetsBox.delete(id);
  }

  Future<void> clearAllBudgets() async {
    await _budgetsBox.clear();
  }

  // ==================== SETTINGS ====================

  T getSetting<T>(String key, T defaultValue) {
    if (!_settingsBox.containsKey(key)) return defaultValue;
    return (_settingsBox.get(key) as T?) ?? defaultValue;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }
}
