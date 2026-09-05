import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user (returns UserModel if logged in)
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      // We'll create a basic UserModel from Firebase user
      // The full profile (name) will be fetched later from Firestore
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    }
    return null;
  }

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        // Fetch user profile from Firestore to get name
        return await _getUserFromFirestore(user.uid);
      }
      return null;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register new user
  Future<UserModel?> register(
      String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);
        // Create user document in Firestore
        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        await _createUserInFirestore(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Helper: create user document in Firestore
  Future<void> _createUserInFirestore(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'createdAt': Timestamp.fromDate(user.createdAt),
    });
  }

  // Helper: fetch user from Firestore
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      // Fallback: use Firebase Auth user data
      final user = _auth.currentUser;
      if (user != null) {
        return UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Convert Firebase exceptions to user-friendly messages
  String _handleAuthException(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak (at least 6 characters).';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
