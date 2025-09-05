import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/company_model.dart';
import '../models/driver_model.dart';
import '../models/order_model.dart' as models;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== USER OPERATIONS ==========
  
  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // ========== COMPANY OPERATIONS ==========
  
  // Create delivery company
  Future<String> createCompany(DeliveryCompany company) async {
    try {
      final docRef = await _firestore.collection('delivery_companies').add(company.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create company: $e');
    }
  }

  // Get company by ID
  Future<DeliveryCompany?> getCompanyById(String companyId) async {
    try {
      final doc = await _firestore.collection('delivery_companies').doc(companyId).get();
      if (doc.exists) {
        return DeliveryCompany.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get company: $e');
    }
  }

  // Get all companies
  Future<List<DeliveryCompany>> getAllCompanies() async {
    try {
      final snapshot = await _firestore.collection('delivery_companies').orderBy('name').get();
      return snapshot.docs.map((doc) => DeliveryCompany.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get companies: $e');
    }
  }

  // Update company
  Future<void> updateCompany(String companyId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('delivery_companies').doc(companyId).update(updates);
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  // Delete company
  Future<void> deleteCompany(String companyId) async {
    try {
      await _firestore.collection('delivery_companies').doc(companyId).delete();
    } catch (e) {
      throw Exception('Failed to delete company: $e');
    }
  }

  // ========== DRIVER OPERATIONS ==========
  
  // Create driver
  Future<String> createDriver(Driver driver) async {
    try {
      final docRef = await _firestore.collection('drivers').add(driver.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create driver: $e');
    }
  }

  // Get driver by ID
  Future<Driver?> getDriverById(String driverId) async {
    try {
      final doc = await _firestore.collection('drivers').doc(driverId).get();
      if (doc.exists) {
        return Driver.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get driver: $e');
    }
  }

  // Get all drivers
  Future<List<Driver>> getAllDrivers() async {
    try {
      final snapshot = await _firestore.collection('drivers').orderBy('name').get();
      return snapshot.docs.map((doc) => Driver.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get drivers: $e');
    }
  }

  // Get drivers by company
  Future<List<Driver>> getDriversByCompany(String companyId) async {
    try {
      final companyRef = _firestore.doc('delivery_companies/$companyId');
      final snapshot = await _firestore
          .collection('drivers')
          .where('companyId', isEqualTo: companyRef)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => Driver.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get drivers by company: $e');
    }
  }

  // Update driver
  Future<void> updateDriver(String driverId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update(updates);
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }

  // Delete driver
  Future<void> deleteDriver(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).delete();
    } catch (e) {
      throw Exception('Failed to delete driver: $e');
    }
  }

  // ========== ORDER OPERATIONS ==========
  
  // Create order
  Future<String> createOrder(models.Order order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get order by ID
  Future<models.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return models.Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Get all orders
  Future<List<models.Order>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get orders by user (for regular users to see their assigned orders)
  Future<List<models.Order>> getOrdersByUser(String userId) async {
    try {
      final userRef = _firestore.doc('users/$userId');
      final snapshot = await _firestore
          .collection('orders')
          .where('createdBy', isEqualTo: userRef)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get orders by user: $e');
    }
  }

  // Get orders by company
  Future<List<models.Order>> getOrdersByCompany(String companyId) async {
    try {
      final companyRef = _firestore.doc('delivery_companies/$companyId');
      final snapshot = await _firestore
          .collection('orders')
          .where('companyId', isEqualTo: companyRef)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get orders by company: $e');
    }
  }

  // Get orders by driver
  Future<List<models.Order>> getOrdersByDriver(String driverId) async {
    try {
      final driverRef = _firestore.doc('drivers/$driverId');
      final snapshot = await _firestore
          .collection('orders')
          .where('driverId', isEqualTo: driverRef)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get orders by driver: $e');
    }
  }

  // Get orders by status
  Future<List<models.Order>> getOrdersByStatus(models.OrderState status) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('state', isEqualTo: status.value)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  // Get orders by date range
  Future<List<models.Order>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get orders by date range: $e');
    }
  }

  // Update order
  Future<void> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('orders').doc(orderId).update(updates);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, models.OrderState status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'state': status.value,
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  // ========== STATISTICS ==========
  
  // Get order statistics
  Future<Map<String, int>> getOrderStatistics() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      final orders = snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();

      return {
        'total': orders.length,
        'received': orders.where((order) => order.state == models.OrderState.received).length,
        'returned': orders.where((order) => order.state == models.OrderState.returned).length,
        'notReturned': orders.where((order) => order.state == models.OrderState.notReturned).length,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // Stream for real-time updates
  Stream<List<models.Order>> getOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList());
  }

  Stream<List<DeliveryCompany>> getCompaniesStream() {
    return _firestore
        .collection('delivery_companies')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DeliveryCompany.fromFirestore(doc)).toList());
  }

  Stream<List<Driver>> getDriversStream() {
    return _firestore
        .collection('drivers')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Driver.fromFirestore(doc)).toList());
  }
}
