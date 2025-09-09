import 'package:flutter/material.dart';
import 'dart:async';
import '../services/ai_notification_service.dart';
import '../localization/app_localizations.dart';

class AINotificationPanel extends StatefulWidget {
  const AINotificationPanel({super.key});

  @override
  State<AINotificationPanel> createState() => _AINotificationPanelState();
}

class _AINotificationPanelState extends State<AINotificationPanel> {
  late StreamSubscription<AINotification> _notificationSubscription;
  List<AINotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _notifications = AINotificationService.instance.notifications;
    
    _notificationSubscription = AINotificationService.instance.notificationStream.listen((notification) {
      setState(() {
        _notifications = AINotificationService.instance.notifications;
      });
    });
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = l10n.localeName == 'ar';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'تنبيهات الذكاء الاصطناعي' : 'AI Notifications',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_notifications.any((n) => !n.isRead))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${AINotificationService.instance.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_all_read':
                        AINotificationService.instance.markAllAsRead();
                        setState(() {
                          _notifications = AINotificationService.instance.notifications;
                        });
                        break;
                      case 'clear_all':
                        AINotificationService.instance.clearAll();
                        setState(() {
                          _notifications = AINotificationService.instance.notifications;
                        });
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mark_all_read',
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'تعيين الكل كمقروء' : 'Mark All Read'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          const Icon(Icons.clear_all),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'مسح الكل' : 'Clear All'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notifications List
          if (_notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.notifications_none, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'لا توجد تنبيهات' : 'No notifications',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notifications.length > 10 ? 10 : _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification, theme, isArabic);
              },
            ),
          
          // View All Button
          if (_notifications.length > 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to full notifications page
                    _showAllNotifications(context);
                  },
                  child: Text(isArabic ? 'عرض جميع التنبيهات' : 'View All Notifications'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AINotification notification, ThemeData theme, bool isArabic) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          AINotificationService.instance.markAsRead(notification.id);
          setState(() {
            _notifications = AINotificationService.instance.notifications;
          });
        }
        
        if (notification.onAction != null) {
          notification.onAction!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? null : theme.primaryColor.withValues(alpha: 0.05),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with priority color
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notification.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(notification.timestamp, isArabic),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  if (notification.actionText != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: notification.onAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(notification.actionText!),
                    ),
                  ],
                ],
              ),
            ),
            
            // Unread indicator
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return isArabic ? 'الآن' : 'Now';
    } else if (difference.inMinutes < 60) {
      return isArabic ? '${difference.inMinutes} د' : '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return isArabic ? '${difference.inHours} س' : '${difference.inHours}h';
    } else {
      return isArabic ? '${difference.inDays} ي' : '${difference.inDays}d';
    }
  }

  void _showAllNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'All Notifications',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Full notifications list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(notification, Theme.of(context), false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
