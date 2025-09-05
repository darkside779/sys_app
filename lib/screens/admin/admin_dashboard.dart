// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sys_app/localization/localization_extension.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';
import '../auth/login_screen.dart';
import 'manage_companies_screen.dart';
import 'manage_drivers_screen.dart';
import 'manage_orders_screen.dart';
import 'reports_screen.dart';
import 'manage_users_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).initialize();
      Provider.of<CompanyProvider>(context, listen: false).initialize();
      Provider.of<DriverProvider>(context, listen: false).initialize();
    });
  }

  Future<void> _handleLanguageChange(Locale locale) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateProfile(
        language: locale.languageCode,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Language updated to ${locale.languageCode == 'en' ? 'English' : 'العربية'}',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update language: ${authProvider.errorMessage}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        content: Text(
          'Are you sure you want to logout?',
        ), // Add to translations
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
        title: Text(tr.dashboard),
        actions: [
          CommonWidgets.languageSwitcher(
            context: context,
            onLanguageChanged: (locale) {
              _handleLanguageChange(locale);
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

  Widget _buildNavigationDrawer(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final tr = AppLocalizations.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: Text(authProvider.user?.name ?? 'Admin User'),
            accountEmail: Text(authProvider.user?.phone ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
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
            leading: const Icon(Icons.shopping_bag),
            title: Text(tr.orders),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(tr.companies),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: Text(tr.drivers),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: Text('Reports'),
            selected: _selectedIndex == 4,
            onTap: () {
              setState(() => _selectedIndex = 4);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(tr.users),
            selected: _selectedIndex == 5,
            onTap: () {
              setState(() => _selectedIndex = 5);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(tr.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminSettingsScreen(),
                ),
              );
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
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: tr.dashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag),
          label: tr.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.business),
          label: tr.companies,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_shipping),
          label: tr.drivers,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: tr.users,
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildOrdersTab();
      case 2:
        return _buildCompaniesTab();
      case 3:
        return _buildDriversTab();
      case 4:
        return _buildReportsTab();
      case 5:
        return _buildUsersTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return Consumer3<OrderProvider, CompanyProvider, DriverProvider>(
      builder: (context, orderProvider, companyProvider, driverProvider, _) {
        if (orderProvider.isLoading ||
            companyProvider.isLoading ||
            driverProvider.isLoading) {
          return CommonWidgets.localizedLoading(context, (tr) => tr.loading);
        }

        final orderStats = orderProvider.getOrderStatistics();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Statistics Grid
              Text(
                context.tr.statistics,
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
                    Icons.shopping_bag,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    context,
                    context.tr.completed_orders,
                    orderStats['returned']?.toString() ?? '0',
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    context,
                    context.tr.companies,
                    companyProvider.companies.length.toString(),
                    Icons.business,
                    AppTheme.warningColor,
                  ),
                  _buildStatCard(
                    context,
                    context.tr.drivers,
                    driverProvider.drivers.length.toString(),
                    Icons.local_shipping,
                    AppTheme.infoColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              CommonWidgets.localizedCard(
                context: context,
                content: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CommonWidgets.primaryButton(
                            context: context,
                            getText: (tr) => tr.create_order,
                            onPressed: () {
                              setState(() => _selectedIndex = 1);
                            },
                            icon: Icons.add,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CommonWidgets.secondaryButton(
                            context: context,
                            getText: (tr) => tr.create_company,
                            onPressed: () {
                              setState(() => _selectedIndex = 2);
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ManageCompaniesScreen(),
                                    ),
                                  )
                                  .then((_) {
                                    // Return to dashboard after navigation
                                    setState(() => _selectedIndex = 0);
                                  });
                            },
                            icon: Icons.business_center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CommonWidgets.secondaryButton(
                            context: context,
                            getText: (tr) => tr.create_driver,
                            onPressed: () {
                              setState(() => _selectedIndex = 3);
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ManageDriversScreen(),
                                    ),
                                  )
                                  .then((_) {
                                    // Return to dashboard after navigation
                                    setState(() => _selectedIndex = 0);
                                  });
                            },
                            icon: Icons.person_add,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CommonWidgets.secondaryButton(
                            context: context,
                            getText: (tr) => tr.view_reports,
                            onPressed: () {
                              setState(() => _selectedIndex = 4);
                            },
                            icon: Icons.analytics,
                          ),
                        ),
                      ],
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

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return const ManageOrdersScreen();
  }

  Widget _buildCompaniesTab() {
    return const ManageCompaniesScreen();
  }

  Widget _buildDriversTab() {
    return const ManageDriversScreen();
  }

  Widget _buildReportsTab() {
    return const ReportsScreen();
  }

  Widget _buildUsersTab() {
    return const ManageUsersScreen();
  }
}
