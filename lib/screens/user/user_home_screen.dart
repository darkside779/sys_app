// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../localization/app_localizations.dart';
import '../../localization/localization_extension.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';
import '../../models/order_model.dart';
import '../auth/login_screen.dart';
import 'my_orders_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
        content: Text(context.tr.are_you_sure_logout),
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
    final tr = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? tr.dashboard : context.tr.my_orders),
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
    final tr = AppLocalizations.of(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            accountName: Text(authProvider.user?.name ?? context.tr.driver_user),
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
            leading: const Icon(Icons.dashboard),
            title: Text(tr.dashboard),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: Text(context.tr.my_orders),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
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
    final tr = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: tr.dashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment),
          label: tr.my_orders,
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildMyOrdersTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return Consumer2<OrderProvider, AuthProvider>(
      builder: (context, orderProvider, authProvider, _) {
        if (orderProvider.isLoading) {
          return CommonWidgets.localizedLoading(
            context,
            (tr) => tr.loading,
          );
        }

        // Filter orders for current user/driver
        final userOrders = orderProvider.orders.where((order) => 
          order.driverId == authProvider.user?.id
        ).toList();
        
        final orderStats = _getOrderStatistics(userOrders);
        
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
                      context.tr.driver_dashboard,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr.view_manage_orders,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Statistics Grid
              Text(
                context.tr.my_statistics,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    context.tr.total_orders,
                    orderStats['total']?.toString() ?? '0',
                    Icons.assignment,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    context,
                    context.tr.pending,
                    orderStats['received']?.toString() ?? '0',
                    Icons.pending,
                    AppTheme.warningColor,
                  ),
                  _buildStatCard(
                    context,
                    context.tr.completed,
                    orderStats['returned']?.toString() ?? '0',
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    context,
                    context.tr.not_returned,
                    orderStats['notReturned']?.toString() ?? '0',
                    Icons.cancel,
                    AppTheme.errorColor,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Orders
              Text(
                context.tr.recent_orders,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              
              if (userOrders.isEmpty)
                CommonWidgets.localizedCard(
                  context: context,
                  content: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          context.tr.no_orders_assigned,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...userOrders.take(5).map((order) => _buildOrderCard(order)),
              
              if (userOrders.length > 5) ...[
                const SizedBox(height: 16),
                Center(
                  child: CommonWidgets.primaryButton(
                    context: context,
                    getText: (tr) => tr.view_all_orders,
                    onPressed: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyOrdersTab() {
    return const MyOrdersScreen();
  }

  Map<String, int> _getOrderStatistics(List<Order> orders) {
    return {
      'total': orders.length,
      'received': orders.where((o) => o.state == OrderState.received).length,
      'returned': orders.where((o) => o.state == OrderState.returned).length,
      'notReturned': orders.where((o) => o.state == OrderState.notReturned).length,
    };
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.state) {
      case OrderState.received:
        statusColor = AppTheme.warningColor;
        break;
      case OrderState.returned:
        statusColor = AppTheme.successColor;
        break;
      case OrderState.notReturned:
        statusColor = AppTheme.errorColor;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.tr.order_hash}${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    order.state.getLocalizedDisplayName(context),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${context.tr.customer}: ${order.customerName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${context.tr.address}: ${order.customerAddress}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            Text(
              '${context.tr.amount}: \$${order.cost.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
