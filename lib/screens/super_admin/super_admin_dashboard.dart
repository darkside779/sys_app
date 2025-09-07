// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../app/theme.dart';
import '../../widgets/common_widgets.dart';
import '../admin/manage_orders_screen.dart';
import '../admin/manage_users_screen.dart';
import 'system_monitoring_screen.dart';
import 'unauthorized_access_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final orderProvider = context.read<OrderProvider>();
    final userProvider = context.read<UserProvider>();
    
    await Future.wait([
      orderProvider.loadAllOrders(),
      userProvider.loadUsers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    // Check if user is super admin
    if (user?.role != UserRole.superAdmin) {
      return _buildUnauthorizedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthProvider>().signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildOverviewTab(),
          const SystemMonitoringScreen(),
          const ManageUsersScreen(),
          const ManageOrdersScreen(),
          const UnauthorizedAccessScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
            label: 'Security',
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthorizedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unauthorized Access'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Access Denied',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You do not have Super Administrator privileges to access this area.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<OrderProvider, UserProvider>(
      builder: (context, orderProvider, userProvider, _) {
        if (orderProvider.isLoading || userProvider.isLoading) {
          return CommonWidgets.localizedLoading(context, (tr) => tr.loading);
        }

        final totalOrders = orderProvider.orders.length;
        final totalUsers = userProvider.users.length;
        final superAdmins = userProvider.users.where((u) => u.role == UserRole.superAdmin).length;
        final admins = userProvider.users.where((u) => u.role == UserRole.admin).length;
        final users = userProvider.users.where((u) => u.role == UserRole.user).length;
        final activeUsers = userProvider.users.where((u) => u.isActive).length;

        final todayOrders = orderProvider.orders.where((order) =>
          order.date.day == DateTime.now().day &&
          order.date.month == DateTime.now().month &&
          order.date.year == DateTime.now().year
        ).length;

        final receivedOrders = orderProvider.orders.where((order) => order.state == OrderState.received).length;
        final outForDeliveryOrders = orderProvider.orders.where((order) => order.state == OrderState.outForDelivery).length;
        final returnedOrders = orderProvider.orders.where((order) => order.state == OrderState.returned).length;
        final notReturnedOrders = orderProvider.orders.where((order) => order.state == OrderState.notReturned).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Super Admin Control Center',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Complete system oversight and management'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // System Statistics
              Text(
                'System Statistics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard('Total Orders', totalOrders.toString(), Icons.shopping_bag, Colors.blue),
                  _buildStatCard('Today\'s Orders', todayOrders.toString(), Icons.today, Colors.green),
                  _buildStatCard('Total Users', totalUsers.toString(), Icons.people, Colors.orange),
                  _buildStatCard('Active Users', activeUsers.toString(), Icons.person, Colors.purple),
                ],
              ),

              const SizedBox(height: 24),

              // User Roles Distribution
              Text(
                'User Roles Distribution',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRoleRow('Super Admins', superAdmins, Icons.security, Colors.deepPurple),
                      const Divider(),
                      _buildRoleRow('Admins', admins, Icons.admin_panel_settings, AppTheme.errorColor),
                      const Divider(),
                      _buildRoleRow('Users/Drivers', users, Icons.local_shipping, AppTheme.primaryColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Order Status Distribution
              Text(
                'Order Status Distribution',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatusRow('Received', receivedOrders, Colors.blue),
                      const Divider(),
                      _buildStatusRow('Out for Delivery', outForDeliveryOrders, Colors.orange),
                      const Divider(),
                      _buildStatusRow('Returned', returnedOrders, Colors.green),
                      const Divider(),
                      _buildStatusRow('Not Returned', notReturnedOrders, Colors.red),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2,
                children: [
                  _buildActionCard(
                    'System Monitor',
                    Icons.monitor,
                    Colors.green,
                    () => setState(() => _currentIndex = 1),
                  ),
                  _buildActionCard(
                    'Security Logs',
                    Icons.security,
                    Colors.red,
                    () => setState(() => _currentIndex = 4),
                  ),
                  _buildActionCard(
                    'Manage Users',
                    Icons.people,
                    Colors.blue,
                    () => setState(() => _currentIndex = 2),
                  ),
                  _buildActionCard(
                    'Manage Orders',
                    Icons.inventory,
                    Colors.orange,
                    () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

  Widget _buildRoleRow(String role, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(role)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(status)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
