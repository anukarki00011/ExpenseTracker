import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  // Simulate a delay for network calls
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // For now, return a dummy user if email/password are not empty
    if (email.isNotEmpty && password.isNotEmpty) {
      return UserModel(
        uid: 'dummy_uid',
        name: 'Test User',
        email: email,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<UserModel?> register(
      String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      return UserModel(
        uid: 'dummy_uid',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
