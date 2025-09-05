import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<User> get users => _users;
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
        return User.fromFirestore(doc);
      }).toList();
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load users: $e');
      _setLoading(false);
    }
  }

  // Create new user
  Future<bool> createUser(User user) async {
    try {
      _setLoading(true);
      _clearError();
      
      final docRef = await _firestore.collection('users').add(user.toFirestore());
      final newUser = user.copyWith(id: docRef.id);
      
      _users.insert(0, newUser);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create user: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update existing user
  Future<bool> updateUser(User user) async {
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

  // Get user by ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search users
  List<User> searchUsers({String? query, UserRole? role}) {
    List<User> filtered = List.from(_users);
    
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
