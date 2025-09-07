import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';
import '../../app/theme.dart';

class SystemMonitoringScreen extends StatefulWidget {
  const SystemMonitoringScreen({super.key});

  @override
  State<SystemMonitoringScreen> createState() => _SystemMonitoringScreenState();
}

class _SystemMonitoringScreenState extends State<SystemMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSystemData();
    });
  }

  Future<void> _loadSystemData() async {
    final orderProvider = context.read<OrderProvider>();
    final userProvider = context.read<UserProvider>();
    
    await Future.wait([
      orderProvider.loadAllOrders(),
      userProvider.loadUsers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Monitoring'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Consumer2<OrderProvider, UserProvider>(
        builder: (context, orderProvider, userProvider, _) {
          if (orderProvider.isLoading || userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalOrders = orderProvider.orders.length;
          final totalUsers = userProvider.users.length;
          final activeUsers = userProvider.users.where((u) => u.isActive).length;
          final todayOrders = orderProvider.orders.where((order) =>
            order.date.day == DateTime.now().day &&
            order.date.month == DateTime.now().month &&
            order.date.year == DateTime.now().year
          ).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                // System Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Total Orders',
                      totalOrders.toString(),
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Today\'s Orders',
                      todayOrders.toString(),
                      Icons.today,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Total Users',
                      totalUsers.toString(),
                      Icons.people,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Active Users',
                      activeUsers.toString(),
                      Icons.person,
                      Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Recent Orders
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Orders',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...orderProvider.orders
                            .take(5)
                            .map((order) => ListTile(
                                  leading: Icon(
                                    Icons.receipt,
                                    color: AppTheme.primaryColor,
                                  ),
                                  title: Text(order.orderNumber),
                                  subtitle: Text('Order #${order.id}'),
                                  trailing: Text(
                                    '${order.date.day}/${order.date.month}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ))
                            ,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // User Activity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Roles Distribution',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...userProvider.users
                            .fold<Map<String, int>>({}, (map, user) {
                              final role = user.role.displayName;
                              map[role] = (map[role] ?? 0) + 1;
                              return map;
                            })
                            .entries
                            .map((entry) => ListTile(
                                  leading: Icon(
                                    entry.key.contains('Super') ? Icons.security :
                                    entry.key.contains('Admin') ? Icons.admin_panel_settings :
                                    Icons.person,
                                    color: entry.key.contains('Super') ? Colors.deepPurple :
                                           entry.key.contains('Admin') ? AppTheme.errorColor :
                                           AppTheme.primaryColor,
                                  ),
                                  title: Text(entry.key),
                                  trailing: Text(entry.value.toString()),
                                ))
                            ,
                      ],
                    ),
                  ),
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
          mainAxisAlignment: MainAxisAlignment.center,
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
}
