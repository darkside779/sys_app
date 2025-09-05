import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryCompany {
  final String id;
  final String name;
  final String address;
  final String contact;
  final String createdBy; // Reference to users/userId
  final DateTime createdAt;
  final bool isActive;

  const DeliveryCompany({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert DeliveryCompany object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'contact': contact,
      'createdBy': FirebaseFirestore.instance.doc('users/$createdBy'),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  // Create DeliveryCompany object from Firestore DocumentSnapshot
  factory DeliveryCompany.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return DeliveryCompany(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      contact: data['contact'] ?? '',
      createdBy: (data['createdBy'] as DocumentReference).id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Create DeliveryCompany object from Map
  factory DeliveryCompany.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryCompany(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      contact: map['contact'] ?? '',
      createdBy: (map['createdBy'] as DocumentReference).id,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with method for updating company data
  DeliveryCompany copyWith({
    String? id,
    String? name,
    String? address,
    String? contact,
    String? createdBy,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return DeliveryCompany(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'DeliveryCompany(id: $id, name: $name, address: $address, contact: $contact)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryCompany &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.contact == contact &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        contact.hashCode ^
        createdBy.hashCode;
  }
}
