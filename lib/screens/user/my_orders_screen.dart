// ignore_for_file: unused_import, deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/company_provider.dart';
import '../../models/order_model.dart';
import '../../models/company_model.dart';
import '../../localization/app_localizations.dart';
import '../../localization/localization_extension.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';
import 'create_order_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  OrderState? _statusFilter;
  List<Order> _filteredOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoadOrders();
    });
  }

  Future<void> _initializeAndLoadOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.initialize(); // Fetch from Firebase
    _loadOrders(); // Then filter for user orders
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();

    print('DEBUG MyOrders: Current user ID: ${authProvider.user?.id}');
    print('DEBUG MyOrders: Total orders in provider: ${orderProvider.orders.length}');
    
    // Filter orders created by current user
    final userOrders = orderProvider.orders
        .where((order) => order.createdBy == authProvider.user?.id)
        .toList();

    print('DEBUG MyOrders: User orders found: ${userOrders.length}');
    for (var order in userOrders) {
      print('DEBUG MyOrders: Order - ${order.orderNumber}, createdBy: ${order.createdBy}');
    }

    setState(() {
      _filteredOrders = userOrders;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();

    List<Order> orders = orderProvider.orders
        .where((order) => order.createdBy == authProvider.user?.id)
        .toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      orders = orders
          .where(
            (order) =>
                order.orderNumber.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                order.customerName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                order.customerAddress.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      orders = orders.where((order) => order.state == _statusFilter).toList();
    }

    // Sort by date (newest first)
    orders.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _filteredOrders = orders;
      _isLoading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _statusFilter = null;
    });
    _loadOrders();
  }

  Future<void> _updateOrderStatus(Order order, OrderState newStatus) async {
    try {
      final orderProvider = context.read<OrderProvider>();

      final updates = {'state': newStatus.value};

      await orderProvider.updateOrder(order.id, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => _OrderDetailsDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? CommonWidgets.localizedLoading(context, (tr) => tr.loading)
                : _buildOrdersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateOrder(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _navigateToCreateOrder(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
    );
    
    if (result == true && mounted) {
      // Refresh orders after creating a new one
      final orderProvider = context.read<OrderProvider>();
      await orderProvider.initialize();
      _loadOrders();
    }
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Orders',
                      hintText: 'Order number, customer, address...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _applyFilters();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<OrderState>(
                    initialValue: _statusFilter,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem<OrderState>(
                        value: null,
                        child: Text('All Status'),
                      ),
                      ...OrderState.values.map(
                        (status) => DropdownMenuItem<OrderState>(
                          value: status,
                          child: Text(status.displayName),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _statusFilter = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            if (_searchQuery.isNotEmpty || _statusFilter != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Filters applied',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text('Clear All'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _statusFilter != null
                  ? 'Try adjusting your filters'
                  : 'No orders created yet. Tap + to create your first order.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    IconData statusIcon;
    switch (order.state) {
      case OrderState.received:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending;
        break;
      case OrderState.returned:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case OrderState.notReturned:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        order.state.displayName,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _showOrderDetails(order),
                      child: Row(
                        children: [
                          const Icon(Icons.info, size: 18),
                          const SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    if (order.state == OrderState.received) ...[
                      PopupMenuItem(
                        onTap: () =>
                            _updateOrderStatus(order, OrderState.returned),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text('Mark as Returned'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () =>
                            _updateOrderStatus(order, OrderState.notReturned),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cancel,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text('Mark as Not Returned'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Customer', order.customerName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Address', order.customerAddress),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.attach_money,
              'Amount',
              '\$${order.cost.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              DateFormat('MMM dd, yyyy').format(order.date),
            ),
            if (order.note != null && order.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, 'Note', order.note!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}

class _OrderDetailsDialog extends StatelessWidget {
  final Order order;

  const _OrderDetailsDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (order.state) {
      case OrderState.received:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending;
        break;
      case OrderState.returned:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case OrderState.notReturned:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
    }

    return AlertDialog(
      title: Text('Order Details'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Number and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.orderNumber}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          order.state.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Customer Information
              _buildSectionTitle('Customer Information'),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.person, 'Name', order.customerName),
              _buildDetailRow(
                Icons.location_on,
                'Address',
                order.customerAddress,
              ),

              const SizedBox(height: 16),

              // Order Information
              _buildSectionTitle('Order Information'),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.attach_money,
                'Amount',
                '\$${order.cost.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                DateFormat('MMM dd, yyyy').format(order.date),
              ),

              if (order.note != null && order.note!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Notes'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    order.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Company Information
              Consumer<CompanyProvider>(
                builder: (context, companyProvider, child) {
                  final company = companyProvider.companies.firstWhere(
                    (c) => c.id == order.companyId,
                    orElse: () => DeliveryCompany(
                      id: order.companyId,
                      name: 'Unknown Company',
                      contact: 'N/A',
                      address: 'N/A',
                      createdAt: DateTime.now(),
                      createdBy: '',
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Company Information'),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.business, 'Company', company.name),
                      _buildDetailRow(
                        Icons.location_city,
                        'Address',
                        company.address,
                      ),
                      _buildDetailRow(Icons.phone, 'Contact', company.contact),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
