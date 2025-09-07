// ignore_for_file: unused_import, deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
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
    final userProvider = context.read<UserProvider>();
    await orderProvider.initialize(); // Fetch from Firebase
    await userProvider.loadUsers(); // Load users to resolve createdBy names
    await _loadOrders(); // Then filter for user orders
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();

    // Refresh data from Firebase to get latest changes
    await orderProvider.loadAllOrders();

    if (!mounted) return;

    // Filter orders created by current user
    final userOrders = orderProvider.orders
        .where((order) => order.createdBy == authProvider.user?.id)
        .toList();

    if (mounted) {
      setState(() {
        _filteredOrders = userOrders;
      });
      _applyFilters();
    }
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

  Future<void> _clearFilters() async {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _statusFilter = null;
    });
    await _loadOrders();
  }

  Future<void> _updateOrderStatus(Order order, OrderState newStatus) async {
    if (newStatus == OrderState.returned) {
      _showReturnReasonDialog(order);
      return;
    }

    try {
      final orderProvider = context.read<OrderProvider>();

      final updates = {'state': newStatus.value};

      await orderProvider.updateOrder(order.id, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.update_success),
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

  void _showReturnReasonDialog(Order order) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr.return_reason),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order #${order.orderNumber}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: context.tr.enter_return_reason,
                prefixIcon: const Icon(Icons.help_outline),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr.return_reason_required),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _updateOrderStatusWithReason(
                order,
                OrderState.returned,
                reason,
              );
            },
            child: Text(context.tr.update),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatusWithReason(
    Order order,
    OrderState newStatus,
    String? returnReason,
  ) async {
    try {
      final orderProvider = context.read<OrderProvider>();

      final updates = {'state': newStatus.value, 'returnReason': returnReason};

      await orderProvider.updateOrder(order.id, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.update_success),
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
        heroTag: "my_orders_fab",
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
                      labelText: context.tr.search_orders,
                      hintText: context.tr.search_orders_hint,
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
                Flexible(
                  child: DropdownButtonFormField<OrderState>(
                    initialValue: _statusFilter,
                    decoration: InputDecoration(
                      labelText: context.tr.status,
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem<OrderState>(
                        value: null,
                        child: Text(context.tr.all_status),
                      ),
                      ...OrderState.values.map(
                        (status) => DropdownMenuItem<OrderState>(
                          value: status,
                          child: Text(status.getLocalizedDisplayName(context)),
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
                    context.tr.filters_applied,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text(context.tr.clear_all),
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
      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    context.tr.no_orders_found,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty || _statusFilter != null
                        ? context.tr.try_adjusting_filters
                        : context.tr.no_orders_created_yet,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    IconData statusIcon;
    switch (order.state) {
      case OrderState.received:
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        break;
      case OrderState.outForDelivery:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
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
                    '${context.tr.order_hash}${order.orderNumber}',
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            order.state.getLocalizedDisplayName(context),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (order.state == OrderState.returned &&
                          order.returnReason != null &&
                          order.returnReason!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          order.returnReason!,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                          Text(context.tr.view_details),
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
                            Text(context.tr.mark_as_returned),
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
                            Text(context.tr.mark_as_not_returned),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person,
              context.tr.customer,
              order.customerName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on,
              context.tr.address,
              order.customerAddress,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.attach_money,
              context.tr.amount,
              '${context.tr.currency_symbol}${order.cost.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              context.tr.date,
              DateFormat('MMM dd, yyyy').format(order.date),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.person_add,
              context.tr.created_by,
              _getCreatedByName(order.createdBy),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              context.tr.created_at,
              DateFormat('MMM dd, yyyy - HH:mm').format(order.createdAt),
            ),
            if (order.note != null && order.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, context.tr.note, order.note!),
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

  String _getCreatedByName(String userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.getUserById(userId);
    return user?.name ?? 'Unknown User';
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
      case OrderState.outForDelivery:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
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
      title: Text(context.tr.order_details),
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
                      '${context.tr.order_hash}${order.orderNumber}',
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
                          order.state.getLocalizedDisplayName(context),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 18,
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
              _buildSectionTitle(context.tr.customer_information),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.person,
                context.tr.name,
                order.customerName,
              ),
              _buildDetailRow(
                Icons.location_on,
                context.tr.address,
                order.customerAddress,
              ),

              const SizedBox(height: 16),

              // Order Information
              _buildSectionTitle(context.tr.order_information),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.attach_money,
                context.tr.amount,
                '${context.tr.currency_symbol}${order.cost.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                Icons.calendar_today,
                context.tr.date,
                DateFormat('MMM dd, yyyy').format(order.date),
              ),
              _buildDetailRow(
                Icons.person_add,
                context.tr.created_by,
                _getCreatedByNameForDialog(context, order.createdBy),
              ),
              _buildDetailRow(
                Icons.access_time,
                context.tr.created_at,
                DateFormat('MMM dd, yyyy - HH:mm').format(order.createdAt),
              ),

              if (order.note != null && order.note!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle(context.tr.notes),
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
                      name: context.tr.unknown_company,
                      contact: 'N/A',
                      address: 'N/A',
                      createdAt: DateTime.now(),
                      createdBy: '',
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context.tr.company_information),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.business,
                        context.tr.company,
                        company.name,
                      ),
                      _buildDetailRow(
                        Icons.location_city,
                        context.tr.address,
                        company.address,
                      ),
                      _buildDetailRow(
                        Icons.phone,
                        context.tr.contact,
                        company.contact,
                      ),
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
          child: Text(context.tr.close),
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

  String _getCreatedByNameForDialog(BuildContext context, String userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.getUserById(userId);
    return user?.name ?? 'Unknown User';
  }
}
