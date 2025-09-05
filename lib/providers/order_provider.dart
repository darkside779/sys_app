// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import '../models/order_model.dart' as models;
import '../services/db_service.dart';

enum OrderLoadState { initial, loading, loaded, error }

class OrderProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  OrderLoadState _state = OrderLoadState.initial;
  List<models.Order> _orders = [];
  List<models.Order> _filteredOrders = [];
  String? _errorMessage;

  // Filters
  models.OrderState? _statusFilter;
  String? _companyFilter;
  String? _driverFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _searchQuery;

  // Getters
  OrderLoadState get state => _state;
  List<models.Order> get orders => _filteredOrders;
  List<models.Order> get allOrders => _orders;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == OrderLoadState.loading;
  bool get hasError => _state == OrderLoadState.error;

  // Filter getters
  models.OrderState? get statusFilter => _statusFilter;
  String? get companyFilter => _companyFilter;
  String? get driverFilter => _driverFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  String? get searchQuery => _searchQuery;

  // Initialize and load orders
  Future<void> initialize() async {
    await loadAllOrders();
  }

  // Load all orders
  Future<void> loadAllOrders() async {
    try {
      _setState(OrderLoadState.loading);
      _orders = await _dbService.getAllOrders();
      _applyFilters();
      _setState(OrderLoadState.loaded);
    } catch (e) {
      _setError('Failed to load orders: $e');
    }
  }

  // Load orders by user (for regular users)
  Future<void> loadOrdersByUser(String userId) async {
    try {
      _setState(OrderLoadState.loading);
      _orders = await _dbService.getOrdersByUser(userId);
      _applyFilters();
      _setState(OrderLoadState.loaded);
    } catch (e) {
      _setError('Failed to load orders: $e');
    }
  }

  // Load orders by company
  Future<void> loadOrdersByCompany(String companyId) async {
    try {
      _setState(OrderLoadState.loading);
      _orders = await _dbService.getOrdersByCompany(companyId);
      _applyFilters();
      _setState(OrderLoadState.loaded);
    } catch (e) {
      _setError('Failed to load orders: $e');
    }
  }

  // Load orders by driver
  Future<void> loadOrdersByDriver(String driverId) async {
    try {
      _setState(OrderLoadState.loading);
      _orders = await _dbService.getOrdersByDriver(driverId);
      _applyFilters();
      _setState(OrderLoadState.loaded);
    } catch (e) {
      _setError('Failed to load orders: $e');
    }
  }

  // Create new order
  Future<bool> createOrder(models.Order order) async {
    try {
      print('DEBUG: Creating order for user: ${order.createdBy}');
      print('DEBUG: Order details: ${order.orderNumber}, ${order.customerName}');
      
      final orderId = await _dbService.createOrder(order);
      print('DEBUG: Order created with ID: $orderId');
      
      final newOrder = order.copyWith(id: orderId);
      _orders.insert(0, newOrder);
      _applyFilters();
      notifyListeners();
      
      print('DEBUG: Total orders in provider: ${_orders.length}');
      print('DEBUG: Filtered orders: ${_filteredOrders.length}');
      
      return true;
    } catch (e) {
      print('DEBUG: Error creating order: $e');
      _setError('Failed to create order: $e');
      return false;
    }
  }

  // Update order
  Future<bool> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      await _dbService.updateOrder(orderId, updates);

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        // Reload the updated order from database to ensure consistency
        final updatedOrder = await _dbService.getOrderById(orderId);
        if (updatedOrder != null) {
          _orders[orderIndex] = updatedOrder;
          _applyFilters();
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _setError('Failed to update order: $e');
      return false;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    models.OrderState status,
  ) async {
    try {
      await _dbService.updateOrderStatus(orderId, status);

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(state: status);
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Failed to update order status: $e');
      return false;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _dbService.deleteOrder(orderId);
      _orders.removeWhere((order) => order.id == orderId);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete order: $e');
      return false;
    }
  }

  // Get order by ID
  models.Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Filter methods
  void setStatusFilter(models.OrderState? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setCompanyFilter(String? companyId) {
    _companyFilter = companyId;
    _applyFilters();
    notifyListeners();
  }

  void setDriverFilter(String? driverId) {
    _driverFilter = driverId;
    _applyFilters();
    notifyListeners();
  }

  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _statusFilter = null;
    _companyFilter = null;
    _driverFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _searchQuery = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to orders
  void _applyFilters() {
    _filteredOrders = _orders.where((order) {
      // Status filter
      if (_statusFilter != null && order.state != _statusFilter) {
        return false;
      }

      // Company filter
      if (_companyFilter != null && order.companyId != _companyFilter) {
        return false;
      }

      // Driver filter
      if (_driverFilter != null && order.driverId != _driverFilter) {
        return false;
      }

      // Date range filter
      if (_startDateFilter != null && order.date.isBefore(_startDateFilter!)) {
        return false;
      }
      if (_endDateFilter != null && order.date.isAfter(_endDateFilter!)) {
        return false;
      }

      // Search query filter
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        return order.customerName.toLowerCase().contains(query) ||
            order.customerAddress.toLowerCase().contains(query) ||
            order.orderNumber.toLowerCase().contains(query) ||
            (order.note?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();

    // Sort by creation date (newest first)
    _filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get order statistics
  Map<String, int> getOrderStatistics() {
    final total = _orders.length;
    final received = _orders
        .where((order) => order.state == models.OrderState.received)
        .length;
    final returned = _orders
        .where((order) => order.state == models.OrderState.returned)
        .length;
    final notReturned = _orders
        .where((order) => order.state == models.OrderState.notReturned)
        .length;

    return {
      'total': total,
      'received': received,
      'returned': returned,
      'notReturned': notReturned,
    };
  }

  // Get filtered statistics
  Map<String, int> getFilteredStatistics() {
    final total = _filteredOrders.length;
    final received = _filteredOrders
        .where((order) => order.state == models.OrderState.received)
        .length;
    final returned = _filteredOrders
        .where((order) => order.state == models.OrderState.returned)
        .length;
    final notReturned = _filteredOrders
        .where((order) => order.state == models.OrderState.notReturned)
        .length;

    return {
      'total': total,
      'received': received,
      'returned': returned,
      'notReturned': notReturned,
    };
  }

  // Refresh orders
  Future<void> refresh() async {
    await loadAllOrders();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == OrderLoadState.error) {
      _setState(OrderLoadState.loaded);
    }
  }

  // Private helper methods
  void _setState(OrderLoadState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = OrderLoadState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
