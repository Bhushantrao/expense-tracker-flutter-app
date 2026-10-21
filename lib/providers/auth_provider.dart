import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  UserModel? _currentUser;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadAuthStatus();
  }

  void _loadAuthStatus() {
    _isLoggedIn = _db.isLoggedIn();
    if (_isLoggedIn) {
      _currentUser = _db.getCurrentUser();
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final success = await _db.registerUser(
      name: name,
      email: email,
      password: password,
    );
    if (success) {
      _isLoggedIn = true;
      _currentUser = _db.getCurrentUser();
      notifyListeners();
    }
    return success;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final user = await _db.loginUser(
      email: email,
      password: password,
    );
    if (user != null) {
      _isLoggedIn = true;
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _db.logout();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
