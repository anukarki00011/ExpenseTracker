import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _infoMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get infoMessage => _infoMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _authService.getCurrentUser();
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
    _infoMessage = null;
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

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required DateTime dob,
  }) async {
    _setLoading(true);
    _setError(null);
    _infoMessage = null;
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        dob: dob,
      );
      if (user != null) {
        _infoMessage =
            'Registration successful! A verification email has been sent to $email. Please verify to log in.';
        _setLoading(false);
        notifyListeners();
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

  Future<void> resendVerificationEmail() async {
    try {
      await _authService.resendVerificationEmail();
      _infoMessage = 'Verification email sent. Please check your inbox.';
      notifyListeners();
    } catch (e) {
      _error = 'Failed to resend verification email: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _infoMessage = null;
    notifyListeners();
  }
}
