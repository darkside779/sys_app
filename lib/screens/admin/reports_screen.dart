// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../models/order_model.dart';
import '../../models/company_model.dart';
import '../../models/driver_model.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _orderNumberController = TextEditingController();
  String? _selectedCompanyId;
  String? _selectedDriverId;
  OrderState? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Order> _filteredOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final orderProvider = context.read<OrderProvider>();
    setState(() {
      _filteredOrders = orderProvider.orders;
    });
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    final orderProvider = context.read<OrderProvider>();
    List<Order> orders = List.from(orderProvider.orders);

    // Filter by order number
    if (_orderNumberController.text.isNotEmpty) {
      orders = orders.where((order) => 
        order.orderNumber.toLowerCase().contains(_orderNumberController.text.toLowerCase())
      ).toList();
    }

    // Filter by company
    if (_selectedCompanyId != null) {
      orders = orders.where((order) => order.companyId == _selectedCompanyId).toList();
    }

    // Filter by driver
    if (_selectedDriverId != null) {
      orders = orders.where((order) => order.driverId == _selectedDriverId).toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      orders = orders.where((order) => order.state == _selectedStatus).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      orders = orders.where((order) => 
        order.date.isAfter(_startDate!) || 
        order.date.isAtSameMomentAs(_startDate!)
      ).toList();
    }
    if (_endDate != null) {
      orders = orders.where((order) => 
        order.date.isBefore(_endDate!.add(Duration(days: 1)))
      ).toList();
    }

    setState(() {
      _filteredOrders = orders;
      _isLoading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _orderNumberController.clear();
      _selectedCompanyId = null;
      _selectedDriverId = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
    _loadInitialData();
  }

  Map<String, dynamic> _generateStatistics() {
    final stats = <String, dynamic>{};
    
    stats['totalOrders'] = _filteredOrders.length;
    stats['receivedOrders'] = _filteredOrders.where((o) => o.state == OrderState.received).length;
    stats['returnedOrders'] = _filteredOrders.where((o) => o.state == OrderState.returned).length;
    stats['notReturnedOrders'] = _filteredOrders.where((o) => o.state == OrderState.notReturned).length;
    
    stats['totalRevenue'] = _filteredOrders.fold<double>(0, (sum, order) => sum + order.cost);
    stats['averageOrderValue'] = _filteredOrders.isNotEmpty 
        ? stats['totalRevenue'] / _filteredOrders.length 
        : 0.0;

    // Company breakdown
    final companyStats = <String, int>{};
    for (final order in _filteredOrders) {
      companyStats[order.companyId] = (companyStats[order.companyId] ?? 0) + 1;
    }
    stats['companyBreakdown'] = companyStats;

    // Driver breakdown
    final driverStats = <String, int>{};
    for (final order in _filteredOrders) {
      driverStats[order.driverId] = (driverStats[order.driverId] ?? 0) + 1;
    }
    stats['driverBreakdown'] = driverStats;

    return stats;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: _isLoading
                ? CommonWidgets.localizedLoading(context, (tr) => tr.loading)
                : _buildReportsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: Text('Clear'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.search),
                  label: Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _orderNumberController,
                    decoration: InputDecoration(
                      labelText: 'Order Number',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Consumer<CompanyProvider>(
                    builder: (context, companyProvider, child) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCompanyId,
                        decoration: InputDecoration(
                          labelText: 'Company',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Companies'),
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
                            _selectedCompanyId = value;
                            _selectedDriverId = null; // Reset driver when company changes
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Consumer<DriverProvider>(
                    builder: (context, driverProvider, child) {
                      final availableDrivers = _selectedCompanyId != null
                          ? driverProvider.drivers.where((d) => d.companyId == _selectedCompanyId).toList()
                          : driverProvider.drivers;
                      
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedDriverId,
                        decoration: InputDecoration(
                          labelText: 'Driver',
                          prefixIcon: const Icon(Icons.local_shipping),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Drivers'),
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
                            _selectedDriverId = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<OrderState>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(Icons.info),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem<OrderState>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...OrderState.values.map((status) =>
                        DropdownMenuItem<OrderState>(
                          value: status,
                          child: Text(status.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                                  : 'Select Date Range',
                              style: TextStyle(
                                color: _startDate != null ? Colors.black : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsContent() {
    final stats = _generateStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Statistics
          Text(
            'Summary Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildStatisticsGrid(stats),
          
          const SizedBox(height: 24),
          
          // Company Performance
          if (stats['companyBreakdown'].isNotEmpty) ...[
            Text(
              'Company Performance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildCompanyPerformance(stats['companyBreakdown']),
            const SizedBox(height: 24),
          ],
          
          // Driver Performance
          if (stats['driverBreakdown'].isNotEmpty) ...[
            Text(
              'Driver Performance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDriverPerformance(stats['driverBreakdown']),
            const SizedBox(height: 24),
          ],
          
          // Orders List
          Text(
            'Filtered Orders (${_filteredOrders.length})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Orders', stats['totalOrders'].toString(), Icons.shopping_bag, AppTheme.primaryColor),
        _buildStatCard('Received', stats['receivedOrders'].toString(), Icons.inbox, AppTheme.infoColor),
        _buildStatCard('Returned', stats['returnedOrders'].toString(), Icons.check_circle, AppTheme.successColor),
        _buildStatCard('Not Returned', stats['notReturnedOrders'].toString(), Icons.cancel, AppTheme.errorColor),
        _buildStatCard('Total Revenue', '\$${stats['totalRevenue'].toStringAsFixed(2)}', Icons.attach_money, AppTheme.warningColor),
        _buildStatCard('Average Order', '\$${stats['averageOrderValue'].toStringAsFixed(2)}', Icons.trending_up, AppTheme.infoColor),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyPerformance(Map<String, int> companyStats) {
    return Consumer<CompanyProvider>(
      builder: (context, companyProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: companyStats.entries.map((entry) {
                final company = companyProvider.companies.firstWhere(
                  (c) => c.id == entry.key,
                  orElse: () => DeliveryCompany(
                    id: entry.key,
                    name: 'Unknown Company',
                    contact: '',
                    address: '',
                    createdAt: DateTime.now(),
                    createdBy: '',
                  ),
                );
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text('${entry.value}'),
                  ),
                  title: Text(company.name),
                  subtitle: Text('${entry.value} orders'),
                  trailing: Text(
                    '${((entry.value / _filteredOrders.length) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverPerformance(Map<String, int> driverStats) {
    return Consumer<DriverProvider>(
      builder: (context, driverProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: driverStats.entries.map((entry) {
                final driver = driverProvider.drivers.firstWhere(
                  (d) => d.id == entry.key,
                  orElse: () => Driver(
                    id: entry.key,
                    name: 'Unknown Driver',
                    phone: '',
                    companyId: '',
                    createdAt: DateTime.now(),
                    createdBy: '',
                  ),
                );
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.successColor,
                    child: Text('${entry.value}'),
                  ),
                  title: Text(driver.name),
                  subtitle: Text('${entry.value} orders'),
                  trailing: Text(
                    '${((entry.value / _filteredOrders.length) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Order #', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Orders
          ..._filteredOrders.map((order) => _buildOrderRow(order)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(Order order) {
    Color statusColor;
    switch (order.state) {
      case OrderState.received:
        statusColor = AppTheme.infoColor;
        break;
      case OrderState.returned:
        statusColor = AppTheme.successColor;
        break;
      case OrderState.notReturned:
        statusColor = AppTheme.errorColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(order.orderNumber)),
          Expanded(child: Text(order.customerName)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                order.state.displayName,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ),
          Expanded(child: Text('\$${order.cost.toStringAsFixed(2)}')),
          Expanded(child: Text(DateFormat('MMM dd, yyyy').format(order.date))),
        ],
      ),
    );
  }
}
