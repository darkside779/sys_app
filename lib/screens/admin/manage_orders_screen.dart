// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/order_model.dart';
import '../../models/company_model.dart';
import '../../models/driver_model.dart';
import '../../widgets/common_widgets.dart';
import '../../localization/app_localizations.dart';
import '../../app/theme.dart';
import 'order_components.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCompanyFilter;
  String? _selectedDriverFilter;
  OrderState? _selectedStatusFilter;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
      context.read<CompanyProvider>().loadAllCompanies();
      context.read<DriverProvider>().loadAllDrivers();
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => OrderDialog(),
    );
  }

  void _showEditOrderDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDialog(order: order),
    );
  }

  void _showDeleteConfirmation(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).delete),
        content: Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<OrderProvider>().deleteOrder(orderId).then((success) {
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            },
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => UpdateStatusDialog(order: order),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCompanyFilter = null;
      _selectedDriverFilter = null;
      _selectedStatusFilter = null;
      _selectedDateRange = null;
    });
    _searchController.clear();
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    var filtered = orders;

    if (_selectedCompanyFilter != null && _selectedCompanyFilter!.isNotEmpty) {
      filtered = filtered.where((order) => order.companyId == _selectedCompanyFilter).toList();
    }

    if (_selectedDriverFilter != null && _selectedDriverFilter!.isNotEmpty) {
      filtered = filtered.where((order) => order.driverId == _selectedDriverFilter).toList();
    }

    if (_selectedStatusFilter != null) {
      filtered = filtered.where((order) => order.state == _selectedStatusFilter).toList();
    }

    if (_selectedDateRange != null) {
      filtered = filtered.where((order) {
        return order.date.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
               order.date.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.customerAddress.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).manage_orders),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            onPressed: _clearFilters,
            tooltip: AppLocalizations.of(context).filter,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().loadAllOrders(),
            tooltip: AppLocalizations.of(context).refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).search_orders,
                    hintText: 'Enter order number, customer name, or address...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Company Filter
                      Consumer<CompanyProvider>(
                        builder: (context, companyProvider, child) {
                          return SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCompanyFilter,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).company,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(AppLocalizations.of(context).all_companies),
                                ),
                                ...companyProvider.companies.map((company) =>
                                  DropdownMenuItem<String>(
                                    value: company.id,
                                    child: Text(company.name),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCompanyFilter = value;
                                  _selectedDriverFilter = null;
                                });
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // Driver Filter
                      Consumer<DriverProvider>(
                        builder: (context, driverProvider, child) {
                          final availableDrivers = _selectedCompanyFilter != null
                              ? driverProvider.drivers.where((d) => d.companyId == _selectedCompanyFilter).toList()
                              : driverProvider.drivers;
                          
                          return SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedDriverFilter,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).driver,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(AppLocalizations.of(context).all_drivers),
                                ),
                                ...availableDrivers.map((driver) =>
                                  DropdownMenuItem<String>(
                                    value: driver.id,
                                    child: Text(driver.name),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDriverFilter = value;
                                });
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // Status Filter
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<OrderState>(
                          initialValue: _selectedStatusFilter,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).status,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            DropdownMenuItem<OrderState>(
                              value: null,
                              child: Text(AppLocalizations.of(context).all_statuses),
                            ),
                            ...OrderState.values.map((status) =>
                              DropdownMenuItem<OrderState>(
                                value: status,
                                child: Text(status.getLocalizedDisplayName(context)),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusFilter = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Date Range Filter
                      ElevatedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(_selectedDateRange == null 
                            ? 'Date Range' 
                            : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: Consumer3<OrderProvider, CompanyProvider, DriverProvider>(
              builder: (context, orderProvider, companyProvider, driverProvider, child) {
                if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (orderProvider.errorMessage != null) {
                  return Card(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: AppTheme.errorColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  orderProvider.errorMessage!,
                                  style: TextStyle(color: AppTheme.errorColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => orderProvider.loadAllOrders(),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredOrders = _getFilteredOrders(orderProvider.orders);

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || 
                          _selectedCompanyFilter != null ||
                          _selectedDriverFilter != null ||
                          _selectedStatusFilter != null ||
                          _selectedDateRange != null
                              ? 'No orders found matching your filters'
                              : 'No orders available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_searchQuery.isEmpty && 
                            _selectedCompanyFilter == null &&
                            _selectedDriverFilter == null &&
                            _selectedStatusFilter == null &&
                            _selectedDateRange == null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showCreateOrderDialog,
                            icon: const Icon(Icons.add),
                            label: Text('Create Order'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => orderProvider.loadAllOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final company = companyProvider.getCompanyById(order.companyId);
                      final driver = driverProvider.getDriverById(order.driverId);
                      return OrderCard(
                        order: order,
                        company: company,
                        driver: driver,
                        onEdit: () => _showEditOrderDialog(order),
                        onDelete: () => _showDeleteConfirmation(order.id),
                        onUpdateStatus: () => _showUpdateStatusDialog(order),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOrderDialog,
        icon: const Icon(Icons.add),
        label: Text('Create Order'),
        heroTag: "manage_orders_fab",
      ),
    );
  }
}
