import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { 
  superAdmin,
  admin, 
  user;
  
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.user:
        return 'Driver/User';
    }
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String language; // "ar" or "en"
  final DateTime createdAt;
  final bool isActive;
  final bool notificationsEnabled;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.language,
    required this.createdAt,
    this.isActive = true,
    this.notificationsEnabled = true,
  });

  // Convert User object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  // Alias for toMap for consistency with other models
  Map<String, dynamic> toFirestore() => toMap();

  // Create User object from Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => UserRole.user,
      ),
      phone: data['phone'] ?? '',
      language: data['language'] ?? 'en',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  // Create User object from Map
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.user,
      ),
      phone: map['phone'] ?? '',
      language: map['language'] ?? 'en',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  // Copy with method for updating user data
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? language,
    DateTime? createdAt,
    bool? isActive,
    bool? notificationsEnabled,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: ${role.name}, phone: $phone, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.phone == phone &&
        other.language == language;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        role.hashCode ^
        phone.hashCode ^
        language.hashCode;
  }
}
