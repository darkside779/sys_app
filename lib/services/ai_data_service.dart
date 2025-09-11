// ignore_for_file: avoid_print, avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart' as models;
import '../models/company_model.dart';
import '../models/driver_model.dart';

class AIDataService {
  static AIDataService? _instance;
  static AIDataService get instance => _instance ??= AIDataService._internal();
  
  AIDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for performance
  Map<String, dynamic>? _cachedData;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Get all data for AI analysis
  Future<Map<String, dynamic>> getAllDataForAI() async {
    // Return cached data if still valid
    if (_cachedData != null && 
        _lastCacheUpdate != null && 
        DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration) {
      return _cachedData!;
    }

    try {
      final results = await Future.wait([
        _fetchOrdersData(),
        _fetchCompaniesData(),
        _fetchDriversData(),
        _fetchProductsData(),
      ]);

      _cachedData = {
        'orders': results[0],
        'companies': results[1],
        'drivers': results[2],
        'products': results[3],
        'summary': _generateDataSummary(
          results[0] as Map<String, dynamic>,
          results[1] as Map<String, dynamic>,
          results[2] as Map<String, dynamic>,
          results[3] as List<Map<String, dynamic>>,
        ),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _lastCacheUpdate = DateTime.now();
      return _cachedData!;
    } catch (e) {
      print('Error fetching data for AI: $e');
      return {
        'error': 'Failed to fetch data: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Fetch orders data
  Future<Map<String, dynamic>> _fetchOrdersData() async {
    try {
      final ordersSnapshot = await _firestore.collection('orders').get();
      final orders = ordersSnapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();

      // Calculate statistics
      final totalOrders = orders.length;
      final completedOrders = orders.where((o) => o.state == models.OrderState.returned).length;
      final pendingOrders = orders.where((o) => o.state == models.OrderState.received).length;
      final outForDelivery = orders.where((o) => o.state == models.OrderState.outForDelivery).length;
      final notReturned = orders.where((o) => o.state == models.OrderState.notReturned).length;

      final totalCost = orders.fold(0.0, (sum, order) => sum + order.cost);
      final avgCost = totalOrders > 0 ? totalCost / totalOrders : 0.0;

      // Recent orders (last 7 days)
      final recentOrders = orders.where((order) => 
        DateTime.now().difference(order.date).inDays <= 7
      ).toList();

      return {
        'total_orders': totalOrders,
        'completed_orders': completedOrders,
        'pending_orders': pendingOrders,
        'out_for_delivery': outForDelivery,
        'not_returned': notReturned,
        'completion_rate': totalOrders > 0 ? (completedOrders / totalOrders * 100).round() : 0,
        'total_cost': totalCost,
        'average_cost': avgCost.round(),
        'recent_orders_count': recentOrders.length,
        'recent_orders': recentOrders.take(10).map((order) => _orderToMap(order)).toList(),
        'status_distribution': {
          'received': pendingOrders,
          'out_for_delivery': outForDelivery,
          'returned': completedOrders,
          'not_returned': notReturned,
        },
      };
    } catch (e) {
      print('Error fetching orders data: $e');
      return {'error': 'Failed to fetch orders: $e'};
    }
  }

  /// Fetch companies data
  Future<Map<String, dynamic>> _fetchCompaniesData() async {
    try {
      final companiesSnapshot = await _firestore.collection('delivery_companies').get();
      final companies = companiesSnapshot.docs.map((doc) => DeliveryCompany.fromFirestore(doc)).toList();

      // Get orders per company
      final ordersSnapshot = await _firestore.collection('orders').get();
      final orders = ordersSnapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();

      final companyStats = <String, Map<String, dynamic>>{};
      for (final company in companies) {
        final companyOrders = orders.where((o) => o.companyId == company.id).toList();
        final completedOrders = companyOrders.where((o) => o.state == models.OrderState.returned).length;
        
        companyStats[company.id] = {
          'name': company.name,
          'total_orders': companyOrders.length,
          'completed_orders': completedOrders,
          'completion_rate': companyOrders.isNotEmpty ? (completedOrders / companyOrders.length * 100).round() : 0,
          'total_revenue': companyOrders.fold(0.0, (sum, order) => sum + order.cost),
        };
      }

      return {
        'total_companies': companies.length,
        'active_companies': companies.where((c) => c.isActive).length,
        'company_stats': companyStats,
        'companies': companies.take(5).map((company) => _companyToMap(company)).toList(),
      };
    } catch (e) {
      print('Error fetching companies data: $e');
      return {'error': 'Failed to fetch companies: $e'};
    }
  }

  /// Fetch drivers data
  Future<Map<String, dynamic>> _fetchDriversData() async {
    try {
      final driversSnapshot = await _firestore.collection('drivers').get();
      final drivers = driversSnapshot.docs.map((doc) => Driver.fromFirestore(doc)).toList();

      // Get orders per driver
      final ordersSnapshot = await _firestore.collection('orders').get();
      final orders = ordersSnapshot.docs.map((doc) => models.Order.fromFirestore(doc)).toList();

      final driverStats = <String, Map<String, dynamic>>{};
      for (final driver in drivers) {
        final driverOrders = orders.where((o) => o.driverId == driver.id).toList();
        final completedOrders = driverOrders.where((o) => o.state == models.OrderState.returned).length;
        
        driverStats[driver.id] = {
          'name': driver.name,
          'phone': driver.phone,
          'company_id': driver.companyId,
          'total_orders': driverOrders.length,
          'completed_orders': completedOrders,
          'completion_rate': driverOrders.isNotEmpty ? (completedOrders / driverOrders.length * 100).round() : 0,
        };
      }

      return {
        'total_drivers': drivers.length,
        'active_drivers': drivers.where((d) => d.isActive).length,
        'driver_stats': driverStats,
        'drivers': drivers.take(10).map((driver) => _driverToMap(driver)).toList(),
      };
    } catch (e) {
      print('Error fetching drivers data: $e');
      return {'error': 'Failed to fetch drivers: $e'};
    }
  }

  /// Helper method to parse DateTime from various formats
  DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date string: $dateValue - $e');
        return null;
      }
    } else if (dateValue is DateTime) {
      return dateValue;
    }
    
    return null;
  }

  /// Fetch products data
  Future<List<Map<String, dynamic>>> _fetchProductsData() async {
    try {
      final productsSnapshot = await _firestore.collection('products').get();
      final products = productsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Product',
          'price': (data['price'] as num?)?.toDouble() ?? 0.0,
          'stock': (data['stock'] as num?)?.toInt() ?? 0,
          'isActive': data['isActive'] ?? true,
          'category': data['category'] ?? 'General',
          'description': data['description'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'createdAt': _parseDateTime(data['createdAt']) ?? DateTime.now(),
        };
      }).toList();

      return products;
    } catch (e) {
      print('Error fetching products data: $e');
      return [];
    }
  }

  /// Generate overall data summary
  Map<String, dynamic> _generateDataSummary(
    Map<String, dynamic> ordersData,
    Map<String, dynamic> companiesData,
    Map<String, dynamic> driversData,
    List<Map<String, dynamic>> productsData,
  ) {
    final availableProducts = productsData.where((p) => (p['stock'] as int) > 0).length;
    
    return {
      'overview': {
        'total_orders': ordersData['total_orders'] ?? 0,
        'total_companies': companiesData['total_companies'] ?? 0,
        'total_drivers': driversData['total_drivers'] ?? 0,
        'total_products': productsData.length,
        'overall_completion_rate': ordersData['completion_rate'] ?? 0,
        'total_revenue': ordersData['total_cost'] ?? 0,
      },
      'performance': {
        'best_performing_company': _findBestPerformingCompany(companiesData),
        'most_active_driver': _findMostActiveDriver(driversData),
        'recent_trend': _analyzeRecentTrend(ordersData),
        'product_availability': '$availableProducts of ${productsData.length} products available',
      },
      'alerts': _generateAlerts(ordersData, companiesData, driversData, productsData),
    };
  }

  /// Find best performing company
  String _findBestPerformingCompany(Map<String, dynamic> companiesData) {
    final stats = companiesData['company_stats'] as Map<String, dynamic>?;
    if (stats == null || stats.isEmpty) return 'No companies found';

    String bestCompany = 'Unknown';
    int highestRate = 0;

    stats.forEach((id, data) {
      final rate = data['completion_rate'] as int? ?? 0;
      if (rate > highestRate) {
        highestRate = rate;
        bestCompany = data['name'] as String? ?? 'Unknown';
      }
    });

    return '$bestCompany ($highestRate% completion rate)';
  }

  /// Find most active driver
  String _findMostActiveDriver(Map<String, dynamic> driversData) {
    final stats = driversData['driver_stats'] as Map<String, dynamic>?;
    if (stats == null || stats.isEmpty) return 'No drivers found';

    String mostActiveDriver = 'Unknown';
    int highestOrders = 0;

    stats.forEach((id, data) {
      final orders = data['total_orders'] as int? ?? 0;
      if (orders > highestOrders) {
        highestOrders = orders;
        mostActiveDriver = data['name'] as String? ?? 'Unknown';
      }
    });

    return '$mostActiveDriver ($highestOrders orders)';
  }

  /// Analyze recent trend
  String _analyzeRecentTrend(Map<String, dynamic> ordersData) {
    final recentCount = ordersData['recent_orders_count'] as int? ?? 0;
    final totalOrders = ordersData['total_orders'] as int? ?? 0;
    
    if (totalOrders == 0) return 'No data available';
    
    final recentPercentage = (recentCount / totalOrders * 100).round();
    
    if (recentPercentage > 30) {
      return 'High activity - $recentCount orders in last 7 days';
    } else if (recentPercentage > 15) {
      return 'Moderate activity - $recentCount orders in last 7 days';
    } else {
      return 'Low activity - $recentCount orders in last 7 days';
    }
  }

  /// Generate system alerts
  List<String> _generateAlerts(
    Map<String, dynamic> ordersData,
    Map<String, dynamic> companiesData,
    Map<String, dynamic> driversData,
    List<Map<String, dynamic>> productsData,
  ) {
    final alerts = <String>[];
    
    // Check completion rate
    final completionRate = ordersData['completion_rate'] as int? ?? 0;
    if (completionRate < 70) {
      alerts.add('Low completion rate: $completionRate% - Consider investigating delays');
    }
    
    // Check not returned orders
    final notReturned = ordersData['not_returned'] as int? ?? 0;
    if (notReturned > 10) {
      alerts.add('High number of not returned orders: $notReturned');
    }
    
    // Check product stock levels
    final outOfStock = productsData.where((p) => (p['stock'] as int? ?? 0) == 0).length;
    final lowStock = productsData.where((p) => (p['stock'] as int? ?? 0) > 0 && (p['stock'] as int? ?? 0) <= 5).length;
    
    if (outOfStock > 0) {
      alerts.add('Products out of stock: $outOfStock items need restocking');
    }
    if (lowStock > 3) {
      alerts.add('Multiple products have low stock: $lowStock items running low');
    }
    
    return alerts;
  }

  /// Convert order to simplified map
  Map<String, dynamic> _orderToMap(models.Order order) {
    return {
      'id': order.id,
      'order_number': order.orderNumber,
      'customer_name': order.customerName,
      'cost': order.cost,
      'status': order.state.value,
      'date': order.date.toIso8601String(),
    };
  }

  /// Convert company to simplified map
  Map<String, dynamic> _companyToMap(DeliveryCompany company) {
    return {
      'id': company.id,
      'name': company.name,
      'contact': company.contact,
      'is_active': company.isActive,
    };
  }

  /// Convert driver to simplified map
  Map<String, dynamic> _driverToMap(Driver driver) {
    return {
      'id': driver.id,
      'name': driver.name,
      'phone': driver.phone,
      'company_id': driver.companyId,
      'is_active': driver.isActive,
    };
  }

  /// Clear cache
  void clearCache() {
    _cachedData = null;
    _lastCacheUpdate = null;
  }

  /// Get specific data type
  Future<Map<String, dynamic>> getOrdersData() async {
    return await _fetchOrdersData();
  }

  Future<Map<String, dynamic>> getCompaniesData() async {
    return await _fetchCompaniesData();
  }

  Future<Map<String, dynamic>> getDriversData() async {
    return await _fetchDriversData();
  }

  Future<List<Map<String, dynamic>>> getProductsData() async {
    return await _fetchProductsData();
  }
}
