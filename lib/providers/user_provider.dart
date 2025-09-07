import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as models;
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  List<models.User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<models.User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all users from Firestore
  Future<void> loadUsers() async {
    try {
      _setLoading(true);
      _clearError();
      
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      
      _users = snapshot.docs.map((doc) {
        return models.User.fromFirestore(doc);
      }).toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load users: $e');
      _setLoading(false);
    }
  }

  // Create new user with Firebase Auth and Firestore
  Future<bool> createUser(models.User user, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Create Firebase Auth account first
      final createdUser = await _authService.registerWithEmailAndPassword(
        email: user.email,
        password: password,
        name: user.name,
        phone: user.phone,
        role: user.role,
        language: user.language,
      );
      
      if (createdUser != null) {
        // Add to local list
        _users.insert(0, createdUser);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create user account');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to create user: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update existing user
  Future<bool> updateUser(models.User user) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
      
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update user: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('users').doc(userId).delete();
      
      _users.removeWhere((user) => user.id == userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete user: $e');
      _setLoading(false);
      return false;
    }
  }

  // Toggle user status
  Future<bool> toggleUserStatus(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final userIndex = _users.indexWhere((user) => user.id == userId);
      if (userIndex == -1) {
        _setError('User not found');
        _setLoading(false);
        return false;
      }
      
      final user = _users[userIndex];
      final updatedUser = user.copyWith(isActive: !user.isActive);
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isActive': updatedUser.isActive});
      
      _users[userIndex] = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to toggle user status: $e');
      _setLoading(false);
      return false;
    }
  }

  // Reset user password using Firebase Auth
  Future<bool> resetUserPassword(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Find user by ID to get their email
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        _setError('User not found');
        _setLoading(false);
        return false;
      }
      
      final userData = models.User.fromFirestore(userDoc);
      
      // Send password reset email using AuthService
      await _authService.resetPassword(userData.email);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send password reset email: $e');
      _setLoading(false);
      return false;
    }
  }

  // Get user by ID
  models.User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search users
  List<models.User> searchUsers({String? query, models.UserRole? role}) {
    List<models.User> filtered = List.from(_users);
    
    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase()) ||
        user.phone.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    if (role != null) {
      filtered = filtered.where((user) => user.role == role).toList();
    }
    
    return filtered;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data (for logout)
  void clearData() {
    _users.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
