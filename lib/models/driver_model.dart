import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String name;
  final String phone;
  final String companyId; // Reference to delivery_companies/companyId
  final String createdBy; // Reference to users/userId
  final DateTime createdAt;
  final bool isActive;

  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.companyId,
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert Driver object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'companyId': FirebaseFirestore.instance.doc('delivery_companies/$companyId'),
      'createdBy': FirebaseFirestore.instance.doc('users/$createdBy'),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  // Create Driver object from Firestore DocumentSnapshot
  factory Driver.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Driver(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      companyId: (data['companyId'] as DocumentReference).id,
      createdBy: (data['createdBy'] as DocumentReference).id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Create Driver object from Map
  factory Driver.fromMap(Map<String, dynamic> map, String id) {
    return Driver(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      companyId: (map['companyId'] as DocumentReference).id,
      createdBy: (map['createdBy'] as DocumentReference).id,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with method for updating driver data
  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? companyId,
    String? createdBy,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      companyId: companyId ?? this.companyId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Driver(id: $id, name: $name, phone: $phone, companyId: $companyId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Driver &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.companyId == companyId &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        companyId.hashCode ^
        createdBy.hashCode;
  }
}
