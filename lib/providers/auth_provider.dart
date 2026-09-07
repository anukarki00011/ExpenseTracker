import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Check if user is already logged in (from persisted session)
    _user = _authService.getCurrentUser();
    // Could also fetch full profile asynchronously, but for now basic info is enough
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _authService.register(name, email, password);
      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _user = null;
    _setLoading(false);
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String newName) async {
    if (_user == null) return false;
    _setLoading(true);
    _setError(null);
    try {
      await _authService.updateUserName(_user!.uid, newName);
      // Update local user
      _user = UserModel(
        uid: _user!.uid,
        name: newName,
        email: _user!.email,
        createdAt: _user!.createdAt,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
