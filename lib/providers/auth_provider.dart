import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUser;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;
  String? get userRole => _userRole;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _currentUser = prefs.getString('currentUser');
    _userRole = prefs.getString('userRole');
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    // Simple authentication for demo purposes
    // In a real app, this would connect to your backend
    if (username == 'admin' && password == 'medwave2024') {
      _isAuthenticated = true;
      _currentUser = username;
      _userRole = 'admin';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('currentUser', username);
      await prefs.setString('userRole', 'admin');
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;
    _userRole = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('currentUser');
    await prefs.remove('userRole');
    
    notifyListeners();
  }
}
