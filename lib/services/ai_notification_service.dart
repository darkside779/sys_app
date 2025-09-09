// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'ai_service.dart';
import 'ai_data_service.dart';
import '../models/ai_response_models.dart';

enum NotificationPriority { low, medium, high, critical }

enum NotificationType {
  unusualPattern,
  performanceIssue,
  optimization,
  prediction,
  anomaly,
}

class AINotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? actionText;
  final VoidCallback? onAction;
  bool isRead;

  AINotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.data,
    this.actionText,
    this.onAction,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.unusualPattern:
        return Icons.trending_up;
      case NotificationType.performanceIssue:
        return Icons.warning;
      case NotificationType.optimization:
        return Icons.lightbulb;
      case NotificationType.prediction:
        return Icons.analytics;
      case NotificationType.anomaly:
        return Icons.error_outline;
    }
  }

  Color get color {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.blue;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.high:
        return Colors.red;
      case NotificationPriority.critical:
        return Colors.red[900]!;
    }
  }
}

class AINotificationService {
  static final AINotificationService _instance = AINotificationService._internal();
  static AINotificationService get instance => _instance;
  AINotificationService._internal();

  final StreamController<AINotification> _notificationController = StreamController<AINotification>.broadcast();
  final List<AINotification> _notifications = [];
  Timer? _monitoringTimer;
  
  Stream<AINotification> get notificationStream => _notificationController.stream;
  List<AINotification> get notifications => List.unmodifiable(_notifications);
  
  // Previous data for comparison
  Map<String, dynamic>? _previousData;
  DateTime? _lastCheck;

  void startMonitoring() {
    stopMonitoring();
    
    // Check immediately
    _checkForPatterns();
    
    // Set up periodic monitoring (every 5 minutes)
    _monitoringTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkForPatterns();
    });
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  Future<void> _checkForPatterns() async {
    try {
      final currentData = await AIDataService.instance.getAllDataForAI();
      final now = DateTime.now();
      
      if (_previousData != null && _lastCheck != null) {
        await _analyzeDataChanges(currentData, _previousData!, now);
      }
      
      // Always check for current issues
      await _checkCurrentPerformance(currentData, now);
      
      _previousData = currentData;
      _lastCheck = now;
    } catch (e) {
      print('AI Notification Service Error: $e');
    }
  }

  Future<void> _analyzeDataChanges(
    Map<String, dynamic> current,
    Map<String, dynamic> previous,
    DateTime timestamp,
  ) async {
    final currentOrdersData = current['orders'] as Map<String, dynamic>? ?? {};
    final previousOrdersData = previous['orders'] as Map<String, dynamic>? ?? {};
    
    
    final currentOrderCount = currentOrdersData['total_orders'] as int? ?? 0;
    final previousOrderCount = previousOrdersData['total_orders'] as int? ?? 0;
    
    // Check for unusual order patterns
    if (currentOrderCount > previousOrderCount + 10) {
      _addNotification(AINotification(
        id: 'sudden_spike_${timestamp.millisecondsSinceEpoch}',
        title: 'Unusual Order Spike Detected',
        message: 'Orders increased by ${currentOrderCount - previousOrderCount} in the last check. This could indicate high demand or system issues.',
        type: NotificationType.unusualPattern,
        priority: NotificationPriority.high,
        timestamp: timestamp,
        data: {
          'current_count': currentOrderCount,
          'previous_count': previousOrderCount,
          'increase': currentOrderCount - previousOrderCount,
        },
        actionText: 'Analyze Pattern',
      ));
    }

    // Check for performance degradation
    final currentSuccessRate = currentOrdersData['completion_rate'] as int? ?? 0;
    final previousSuccessRate = previousOrdersData['completion_rate'] as int? ?? 0;
    
    if (currentSuccessRate < previousSuccessRate - 10) {
      _addNotification(AINotification(
        id: 'performance_drop_${timestamp.millisecondsSinceEpoch}',
        title: 'Performance Drop Alert',
        message: 'Success rate dropped from $previousSuccessRate% to $currentSuccessRate%',
        type: NotificationType.performanceIssue,
        priority: NotificationPriority.critical,
        timestamp: timestamp,
        data: {
          'current_rate': currentSuccessRate,
          'previous_rate': previousSuccessRate,
          'drop': previousSuccessRate - currentSuccessRate,
        },
        actionText: 'Investigate',
      ));
    }
  }

  Future<void> _checkCurrentPerformance(Map<String, dynamic> data, DateTime timestamp) async {
    final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    // Check for low driver availability
    final activeDrivers = drivers.where((d) => d['isActive'] == true).length;
    final totalDrivers = drivers.length;
    
    if (totalDrivers > 0 && (activeDrivers / totalDrivers) < 0.3) {
      _addNotification(AINotification(
        id: 'low_drivers_${timestamp.millisecondsSinceEpoch}',
        title: 'Low Driver Availability',
        message: 'Only $activeDrivers out of $totalDrivers drivers are active. Consider incentivizing more drivers.',
        type: NotificationType.performanceIssue,
        priority: NotificationPriority.high,
        timestamp: timestamp,
        data: {
          'active_drivers': activeDrivers,
          'total_drivers': totalDrivers,
          'availability_rate': (activeDrivers / totalDrivers) * 100,
        },
        actionText: 'View Drivers',
      ));
    }

    // Generate optimization suggestions
    final insights = await AIService.instance.sendMessage('analyze current performance and suggest optimizations');
    if (insights.type == AIResponseType.systemInsights) {
      final systemInsights = insights.data as SystemInsights;
      
      if (systemInsights.recommendations.isNotEmpty) {
        _addNotification(AINotification(
          id: 'optimization_${timestamp.millisecondsSinceEpoch}',
          title: 'AI Optimization Suggestion',
          message: systemInsights.recommendations.first,
          type: NotificationType.optimization,
          priority: NotificationPriority.medium,
          timestamp: timestamp,
          data: {'recommendations': systemInsights.recommendations},
          actionText: 'View All',
        ));
      }
    }

    // Check for anomalies using AI analysis
    await _checkForAnomalies(data, timestamp);
  }

  Future<void> _checkForAnomalies(Map<String, dynamic> data, DateTime timestamp) async {
    try {
      final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
      final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
      
      final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      
      // Detect unusual patterns in recent orders
      final recentOrders = orders.where((order) {
        try {
          final orderTime = order['timestamp'] is String 
              ? DateTime.parse(order['timestamp']) 
              : DateTime.now();
          return orderTime.isAfter(timestamp.subtract(const Duration(hours: 2)));
        } catch (e) {
          return false;
        }
      }).toList();

      // Check for too many cancelled orders
      final cancelledRecent = recentOrders.where((o) => o['status'] == 'cancelled').length;
      if (recentOrders.isNotEmpty && (cancelledRecent / recentOrders.length) > 0.3) {
        _addNotification(AINotification(
          id: 'high_cancellation_${timestamp.millisecondsSinceEpoch}',
          title: 'High Cancellation Rate Detected',
          message: '${(cancelledRecent / recentOrders.length * 100).toStringAsFixed(1)}% of recent orders were cancelled. This needs immediate attention.',
          type: NotificationType.anomaly,
          priority: NotificationPriority.critical,
          timestamp: timestamp,
          data: {
            'cancelled_count': cancelledRecent,
            'total_recent': recentOrders.length,
            'cancellation_rate': (cancelledRecent / recentOrders.length) * 100,
          },
          actionText: 'Investigate',
        ));
      }

      // Check for driver performance anomalies
      final underperformingDrivers = drivers.where((driver) {
        final completedDeliveries = driver['completedDeliveries'] as int? ?? 0;
        final rating = (driver['rating'] as num?)?.toDouble() ?? 0.0;
        return completedDeliveries > 10 && rating < 3.0;
      }).toList();

      if (underperformingDrivers.isNotEmpty) {
        _addNotification(AINotification(
          id: 'underperforming_drivers_${timestamp.millisecondsSinceEpoch}',
          title: 'Underperforming Drivers Alert',
          message: '${underperformingDrivers.length} drivers with low ratings need attention.',
          type: NotificationType.performanceIssue,
          priority: NotificationPriority.medium,
          timestamp: timestamp,
          data: {
            'driver_count': underperformingDrivers.length,
            'drivers': underperformingDrivers.map((d) => d['name']).toList(),
          },
          actionText: 'Review Drivers',
        ));
      }
    } catch (e) {
      debugPrint('Anomaly detection error: $e');
    }
  }


  void _addNotification(AINotification notification) {
    // Avoid duplicate notifications
    final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
    if (existingIndex >= 0) {
      return;
    }

    _notifications.insert(0, notification);
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
    
    _notificationController.add(notification);
  }

  void markAsRead(String notificationId) {
    final notification = _notifications.firstWhere((n) => n.id == notificationId);
    notification.isRead = true;
  }

  void markAllAsRead() {
    for (final notification in _notifications) {
      notification.isRead = true;
    }
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  void clearAll() {
    _notifications.clear();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AINotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<AINotification> getNotificationsByPriority(NotificationPriority priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  void dispose() {
    stopMonitoring();
    _notificationController.close();
  }
}
