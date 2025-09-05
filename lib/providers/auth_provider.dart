import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart' as models;
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  models.User? _user;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  models.User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;
  bool get isAdmin => _user?.role == models.UserRole.admin;

  AuthProvider() {
    _initializeAuthState();
  }

  // Initialize authentication state
  void _initializeAuthState() {
    _authService.authStateChanges.listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData();
      } else {
        _setUnauthenticated();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      _setState(AuthState.loading);
      final userData = await _authService.getCurrentUserData();
      if (userData != null) {
        _user = userData;
        _setState(AuthState.authenticated);
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setError('Failed to load user data: $e');
    }
  }

  // Initialize method for splash screen
  Future<void> initialize() async {
    try {
      _setState(AuthState.loading);
      // Check if user is already authenticated
      final user = await _authService.getCurrentUserData();
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Alias methods for backwards compatibility with screens
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await signIn(email, password);
  }

  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required models.UserRole role,
    required String language,
  }) async {
    return await register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
      language: language,
    );
  }

  // Sign in existing user
  Future<bool> signIn(String email, String password) async {
    try {
      _setState(AuthState.loading);
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError('Sign in failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required models.UserRole role,
    required String language,
  }) async {
    try {
      _setState(AuthState.loading);
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        language: language,
      );
      
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setState(AuthState.loading);
      await _authService.signOut();
      _setUnauthenticated();
    } catch (e) {
      _setError('Sign out failed: $e');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setState(AuthState.loading);
      await _authService.resetPassword(email);
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? language,
    bool? notificationsEnabled,
  }) async {
    if (_user == null) return false;

    try {
      _setState(AuthState.loading);
      
      await _authService.updateUserProfile(
        userId: _user!.id,
        name: name,
        phone: phone,
        language: language,
        notificationsEnabled: notificationsEnabled,
      );

      // Update local user object
      _user = _user!.copyWith(
        name: name,
        phone: phone,
        language: language,
        notificationsEnabled: notificationsEnabled,
      );

      // Force rebuild of MaterialApp when language changes to update locale
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setState(AuthState.loading);
      
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      _setState(AuthState.loading);
      
      await _authService.deleteAccount(password);
      
      _setUnauthenticated();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_authService.currentUser != null) {
      await _loadUserData();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private helper methods
  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _state = AuthState.unauthenticated;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

}
