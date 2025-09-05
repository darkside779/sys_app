// ignore_for_file: dead_code, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';
import '../auth/login_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).initialize();
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await _showLogoutDialog();
    if (shouldLogout == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr.logout),
        content: Text('Are you sure you want to logout?'), // Add to translations
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr.cancel),
          ),
          CommonWidgets.errorButton(
            context: context,
            getText: (tr) => tr.logout,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.home),
        actions: [
          CommonWidgets.languageSwitcher(
            context: context,
            onLanguageChanged: (locale) {
              // Handle language change
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: tr.logout,
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, authProvider),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context, AuthProvider authProvider) {
    final tr = AppLocalizations.of(context)!;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: Text(authProvider.user?.name ?? 'User'),
            accountEmail: Text(authProvider.user?.phone ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 40,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(tr.home),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(tr.orders),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(tr.profile),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(tr.settings),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(tr.logout),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final tr = AppLocalizations.of(context)!;
    
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: tr.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag),
          label: tr.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: tr.profile,
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildOrdersTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        if (orderProvider.isLoading) {
          return CommonWidgets.localizedLoading(
            context,
            (tr) => tr.loading,
          );
        }

        final userOrders = orderProvider.orders
            .where((order) => order.driverId == Provider.of<AuthProvider>(context, listen: false).user?.id)
            .toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              CommonWidgets.localizedCard(
                context: context,
                getTitle: (tr) => tr.welcome,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Dashboard', // Add to translations
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View your orders and manage your profile.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Order Statistics
              Text(
                context.tr.orders,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      context.tr.totalOrders,
                      userOrders.length.toString(),
                      Icons.shopping_bag,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      context.tr.todayOrders,
                      userOrders.where((order) => 
                        order.date.day == DateTime.now().day &&
                        order.date.month == DateTime.now().month &&
                        order.date.year == DateTime.now().year
                      ).length.toString(),
                      Icons.today,
                      AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Orders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Orders', // Add to translations
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    child: Text('View All'), // Add to translations
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (userOrders.isEmpty)
                CommonWidgets.localizedCard(
                  context: context,
                  content: Column(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet', // Add to translations
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your orders will appear here once assigned.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...userOrders.take(3).map((order) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getOrderStatusColor(order.state),
                      child: Icon(
                        _getOrderStatusIcon(order.state),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(order.orderNumber),
                    subtitle: Text(order.customerName),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getOrderStatusText(order.state),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getOrderStatusColor(order.state),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${order.date.day}/${order.date.month}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to order details
                    },
                  ),
                )),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              Text(
                'Quick Actions', // Add to translations
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              
              CommonWidgets.localizedCard(
                context: context,
                content: Column(
                  children: [
                    CommonWidgets.primaryButton(
                      context: context,
                      getText: (tr) => 'Refresh Orders', // Add to translations
                      onPressed: () {
                        Provider.of<OrderProvider>(context, listen: false).loadAllOrders();
                      },
                      icon: Icons.refresh,
                    ),
                    const SizedBox(height: 12),
                    CommonWidgets.secondaryButton(
                      context: context,
                      getText: (tr) => 'Update Profile', // Add to translations
                      onPressed: () => setState(() => _selectedIndex = 2),
                      icon: Icons.person,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getOrderStatusColor(dynamic state) {
    // This would need to match your OrderState enum
    switch (state.toString()) {
      case 'OrderState.received':
        return AppTheme.successColor;
      case 'OrderState.returned':
        return AppTheme.primaryColor;
      case 'OrderState.notReturned':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  IconData _getOrderStatusIcon(dynamic state) {
    switch (state.toString()) {
      case 'OrderState.received':
        return Icons.check_circle;
      case 'OrderState.returned':
        return Icons.assignment_return;
      case 'OrderState.notReturned':
        return Icons.error;
      default:
        return Icons.pending;
    }
  }

  String _getOrderStatusText(dynamic state) {
    final tr = AppLocalizations.of(context)!;
    switch (state.toString()) {
      case 'OrderState.received':
        return tr.orderReceived;
      case 'OrderState.returned':
        return tr.orderReturned;
      case 'OrderState.notReturned':
        return tr.orderNotReturned;
      default:
        return 'Pending'; // Add to translations
    }
  }

  Widget _buildOrdersTab() {
    return const Center(
      child: Text('Orders List - Coming Soon'),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CommonWidgets.localizedCard(
                context: context,
                getTitle: (tr) => tr.profile,
                content: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      user?.phone ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Chip(
                      label: Text(context.tr.user),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              CommonWidgets.localizedCard(
                context: context,
                getTitle: (tr) => 'Account Information', // Add to translations
                content: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(context.tr.language),
                      subtitle: Text(user?.language == 'ar' ? context.tr.arabic : context.tr.english),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to language settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text('Notifications'), // Add to translations
                      subtitle: Text('Manage notification preferences'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to notification settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: Text('Privacy & Security'), // Add to translations
                      subtitle: Text('Manage your privacy settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to privacy settings
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
