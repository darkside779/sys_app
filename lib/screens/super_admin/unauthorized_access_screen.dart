import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../app/theme.dart';

class UnauthorizedAccessScreen extends StatefulWidget {
  const UnauthorizedAccessScreen({super.key});

  @override
  State<UnauthorizedAccessScreen> createState() => _UnauthorizedAccessScreenState();
}

class _UnauthorizedAccessScreenState extends State<UnauthorizedAccessScreen> {
  List<Map<String, dynamic>> _unauthorizedAttempts = [];
  bool _isSystemLocked = false;
  bool _isLoadingLockStatus = true;
  bool _isUpdatingLock = false;

  @override
  void initState() {
    super.initState();
    _loadUnauthorizedAttempts();
    _loadSystemLockStatus();
  }

  void _loadUnauthorizedAttempts() {
    // Simulated unauthorized access attempts data
    // In a real app, this would come from Firebase or another logging service
    setState(() {
      _unauthorizedAttempts = [
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'email': 'hacker@example.com',
          'ipAddress': '192.168.1.100',
          'attemptedRole': 'admin',
          'reason': 'Invalid credentials',
        },
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'email': 'test@test.com',
          'ipAddress': '10.0.0.1',
          'attemptedRole': 'super_admin',
          'reason': 'Insufficient permissions',
        },
        {
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'email': 'unknown@domain.com',
          'ipAddress': '172.16.0.1',
          'attemptedRole': 'admin',
          'reason': 'Account not found',
        },
      ];
    });
  }

  Future<void> _loadSystemLockStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('system_settings')
          .doc('security')
          .get();
      
      if (mounted) {
        setState(() {
          _isSystemLocked = doc.data()?['is_locked'] ?? false;
          _isLoadingLockStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLockStatus = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load system lock status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleSystemLock() async {
    setState(() {
      _isUpdatingLock = true;
    });

    try {
      final newLockStatus = !_isSystemLocked;
      
      await FirebaseFirestore.instance
          .collection('system_settings')
          .doc('security')
          .set({
        'is_locked': newLockStatus,
        'locked_by': context.read<AuthProvider>().user?.id,
        'locked_at': FieldValue.serverTimestamp(),
        'lock_reason': newLockStatus ? 'System locked by Super Admin for security' : null,
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _isSystemLocked = newLockStatus;
          _isUpdatingLock = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newLockStatus 
                ? 'System has been locked. All users and admins are now blocked from accessing the system.'
                : 'System has been unlocked. Users and admins can now access the system normally.',
            ),
            backgroundColor: newLockStatus ? Colors.red : Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingLock = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update system lock: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unauthorized Access'),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security Alert Card
                Card(
                  color: Colors.red.shade50,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Security Monitoring',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Monitor and track unauthorized access attempts to the system',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // System Lock Control Card
                Card(
                  color: _isSystemLocked ? Colors.red.shade50 : Colors.green.shade50,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isSystemLocked ? Icons.lock : Icons.lock_open,
                              color: _isSystemLocked ? Colors.red : Colors.green,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'System Lock Control',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: _isSystemLocked ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isSystemLocked 
                                      ? 'System is currently LOCKED. All users and admins are blocked.'
                                      : 'System is currently UNLOCKED. All users can access normally.',
                                    style: TextStyle(
                                      color: _isSystemLocked ? Colors.red.shade700 : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isLoadingLockStatus)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isUpdatingLock ? null : _toggleSystemLock,
                              icon: _isUpdatingLock 
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(_isSystemLocked ? Icons.lock_open : Icons.lock),
                              label: Text(
                                _isUpdatingLock 
                                  ? 'Updating...'
                                  : (_isSystemLocked ? 'UNLOCK SYSTEM' : 'LOCK SYSTEM'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSystemLocked ? Colors.green : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          _isSystemLocked 
                            ? '⚠️ Warning: Unlocking will allow all users to access the system again.'
                            : '⚠️ Warning: Locking will immediately block all users and admins from accessing the system.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Attempts',
                        _unauthorizedAttempts.length.toString(),
                        Icons.warning,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Today\'s Attempts',
                        _unauthorizedAttempts
                            .where((attempt) =>
                                attempt['timestamp'].day == DateTime.now().day)
                            .length
                            .toString(),
                        Icons.today,
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Recent Unauthorized Attempts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Unauthorized Attempts List
                Card(
                  child: Column(
                    children: _unauthorizedAttempts.map((attempt) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: Icon(
                            Icons.block,
                            color: Colors.red,
                          ),
                        ),
                        title: Text(attempt['email']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('IP: ${attempt['ipAddress']}'),
                            Text('Attempted: ${attempt['attemptedRole']}'),
                            Text('Reason: ${attempt['reason']}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDateTime(attempt['timestamp']),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadUnauthorizedAttempts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearLogs,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Logs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all unauthorized access logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _unauthorizedAttempts.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
