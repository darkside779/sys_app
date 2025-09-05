import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/user/order_detail_screen.dart';
import '../screens/user/user_dashboard.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Global navigator key for navigation from service
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  // Set navigator key (called from main app)
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted permission');
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('User granted provisional permission');
        }
      } else {
        if (kDebugMode) {
          print('User declined or has not accepted permission');
        }
      }

      // Get the FCM token
      String? token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Received foreground message: ${message.notification?.title}');
        }
        // Handle the message when app is in foreground
        _handleMessage(message);
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Message opened app: ${message.notification?.title}');
        }
        // Navigate to specific screen based on message data
        _handleMessageTap(message);
      });

    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  // Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
    }
  }

  // Handle foreground messages
  void _handleMessage(RemoteMessage message) {
    // Implement your logic for handling foreground notifications
    // For example, show an in-app notification or update the UI
    
    if (message.data.containsKey('type')) {
      switch (message.data['type']) {
        case 'order_status_update':
          // Handle order status update
          _handleOrderStatusUpdate(message.data);
          break;
        case 'new_order':
          // Handle new order notification
          _handleNewOrder(message.data);
          break;
        default:
          if (kDebugMode) {
            print('Unknown notification type: ${message.data['type']}');
          }
      }
    }
  }

  // Handle notification taps
  void _handleMessageTap(RemoteMessage message) {
    // Navigate to specific screens based on notification data
    
    if (message.data.containsKey('type')) {
      switch (message.data['type']) {
        case 'order_status_update':
          // Navigate to order details screen
          String? orderId = message.data['orderId'];
          if (orderId != null) {
            _navigateToOrderDetails(orderId);
          }
          break;
        case 'new_order':
          // Navigate to orders list
          _navigateToOrdersList();
          break;
        default:
          // Navigate to home screen
          _navigateToHome();
      }
    }
  }

  // Handle order status update notifications
  void _handleOrderStatusUpdate(Map<String, dynamic> data) {
    // Implement logic to update local state or refresh order data
    if (kDebugMode) {
      print('Order status updated for order: ${data['orderId']}');
    }
  }

  // Handle new order notifications
  void _handleNewOrder(Map<String, dynamic> data) {
    // Implement logic to handle new order notifications
    if (kDebugMode) {
      print('New order received: ${data['orderId']}');
    }
  }

  // Navigation methods with actual navigation logic
  void _navigateToOrderDetails(String orderId) {
    if (_navigatorKey?.currentContext == null) {
      if (kDebugMode) {
        print('Navigator context not available for order details navigation');
      }
      return;
    }
    
    _navigatorKey!.currentState?.push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: orderId),
      ),
    );
    
    if (kDebugMode) {
      print('Navigated to order details: $orderId');
    }
  }

  void _navigateToOrdersList() {
    if (_navigatorKey?.currentContext == null) {
      if (kDebugMode) {
        print('Navigator context not available for orders list navigation');
      }
      return;
    }
    
    // Navigate to user dashboard which contains orders
    _navigatorKey!.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const UserDashboard(),
      ),
      (route) => false,
    );
    
    if (kDebugMode) {
      print('Navigated to orders list (User Dashboard)');
    }
  }

  void _navigateToHome() {
    if (_navigatorKey?.currentContext == null) {
      if (kDebugMode) {
        print('Navigator context not available for home navigation');
      }
      return;
    }
    
    // Navigate to appropriate home screen (User or Admin Dashboard)
    _navigatorKey!.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const UserDashboard(),
      ),
      (route) => false,
    );
    
    if (kDebugMode) {
      print('Navigated to home screen');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      // This would require platform-specific implementation
      // For now, just a placeholder
      if (kDebugMode) {
        print('Clearing all notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing notifications: $e');
      }
    }
  }
}

// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.notification?.title}');
  }
  // Handle the background message
  // Note: You cannot update UI from background handler
}
