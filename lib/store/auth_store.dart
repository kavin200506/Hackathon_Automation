import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../core/constants.dart';

class AuthStore extends ChangeNotifier {
  User? _user;
  String? _token;
  String? _userType;

  User? get user => _user;
  String? get token => _token;
  String? get userType => _userType;
  bool get isAuthenticated => _token != null && _user != null;

  AuthStore() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.accessTokenKey);
    _userType = prefs.getString(AppConstants.userTypeKey);
    notifyListeners();
  }

  Future<void> setAuth(User user, String token, String userType) async {
    _user = user;
    _token = token;
    _userType = userType;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, token);
    await prefs.setString(AppConstants.userTypeKey, userType);
    
    notifyListeners();
  }

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _userType = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}

