import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

enum OrderState { received, outForDelivery, returned, notReturned }

extension OrderStateExtension on OrderState {
  String getLocalizedDisplayName(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (this) {
      case OrderState.received:
        return localizations.status_received;
      case OrderState.outForDelivery:
        return localizations.status_out_for_delivery;
      case OrderState.returned:
        return localizations.status_returned;
      case OrderState.notReturned:
        return localizations.status_not_returned;
    }
  }

  String get value {
    switch (this) {
      case OrderState.received:
        return 'Received';
      case OrderState.outForDelivery:
        return 'Out for delivery';
      case OrderState.returned:
        return 'Returned';
      case OrderState.notReturned:
        return 'Not returned';
    }
  }
}

class Order {
  final String id;
  final String companyId; // Reference to delivery_companies/companyId
  final String driverId; // Reference to drivers/driverId
  final String customerName;
  final String customerAddress;
  final DateTime date;
  final double cost;
  final String orderNumber;
  final OrderState state;
  final String? note; // Optional
  final String? returnReason; // Reason why order was returned
  final String createdBy; // Reference to users/userId
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.companyId,
    required this.driverId,
    required this.customerName,
    required this.customerAddress,
    required this.date,
    required this.cost,
    required this.orderNumber,
    required this.state,
    this.note,
    this.returnReason,
    required this.createdBy,
    required this.createdAt,
  });

  // Convert Order object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'companyId': FirebaseFirestore.instance.doc(
        'delivery_companies/$companyId',
      ),
      'driverId': (driverId.isNotEmpty && driverId != 'unassigned')
          ? FirebaseFirestore.instance.doc('drivers/$driverId')
          : null,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'date': Timestamp.fromDate(date),
      'cost': cost,
      'orderNumber': orderNumber,
      'state': state.value,
      'note': note,
      'returnReason': returnReason,
      'createdBy': FirebaseFirestore.instance.doc('users/$createdBy'),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create Order object from Firestore DocumentSnapshot
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper function to extract ID from either String or DocumentReference
    String extractId(dynamic field, String fallback) {
      if (field == null) return fallback;
      if (field is String) return field;
      if (field is DocumentReference) return field.id;
      return fallback;
    }

    return Order(
      id: doc.id,
      companyId: extractId(data['companyId'], ''),
      driverId: extractId(data['driverId'], 'unassigned'),
      customerName: data['customerName'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      cost: (data['cost'] ?? 0).toDouble(),
      orderNumber: data['orderNumber'] ?? '',
      state: OrderState.values.firstWhere(
        (state) => state.value == data['state'],
        orElse: () => OrderState.received,
      ),
      note: data['note'],
      returnReason: data['returnReason'],
      createdBy: extractId(data['createdBy'], ''),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create Order object from Map
  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      companyId: (map['companyId'] as DocumentReference).id,
      driverId: (map['driverId'] as DocumentReference).id,
      customerName: map['customerName'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      cost: (map['cost'] ?? 0).toDouble(),
      orderNumber: map['orderNumber'] ?? '',
      state: OrderState.values.firstWhere(
        (state) => state.value == map['state'],
        orElse: () => OrderState.received,
      ),
      note: map['note'],
      returnReason: map['returnReason'],
      createdBy: (map['createdBy'] as DocumentReference).id,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updating order data
  Order copyWith({
    String? id,
    String? companyId,
    String? driverId,
    String? customerName,
    String? customerAddress,
    DateTime? date,
    double? cost,
    String? orderNumber,
    OrderState? state,
    String? note,
    String? returnReason,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      driverId: driverId ?? this.driverId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      orderNumber: orderNumber ?? this.orderNumber,
      state: state ?? this.state,
      note: note ?? this.note,
      returnReason: returnReason ?? this.returnReason,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, customerName: $customerName, state: ${state.value}, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.companyId == companyId &&
        other.driverId == driverId &&
        other.customerName == customerName &&
        other.customerAddress == customerAddress &&
        other.orderNumber == orderNumber &&
        other.state == state &&
        other.cost == cost &&
        other.note == note &&
        other.returnReason == returnReason &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        driverId.hashCode ^
        customerName.hashCode ^
        customerAddress.hashCode ^
        orderNumber.hashCode ^
        state.hashCode ^
        cost.hashCode ^
        (note?.hashCode ?? 0) ^
        (returnReason?.hashCode ?? 0) ^
        createdBy.hashCode;
  }
}
