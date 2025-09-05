// ignore_for_file: deprecated_member_use, unused_local_variable

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

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  DeliveryCompany? _company;
  Driver? _driver;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      final companyProvider = context.read<CompanyProvider>();
      final driverProvider = context.read<DriverProvider>();

      _order = orderProvider.orders.firstWhere(
        (order) => order.id == widget.orderId,
        orElse: () => throw Exception('Order not found'),
      );

      _company = companyProvider.companies.firstWhere(
        (company) => company.id == _order!.companyId,
        orElse: () => DeliveryCompany(
          id: _order!.companyId,
          name: 'Unknown Company',
          contact: 'N/A',
          address: 'N/A',
          createdAt: DateTime.now(),
          createdBy: '',
        ),
      );

      _driver = driverProvider.drivers.firstWhere(
        (driver) => driver.id == _order!.driverId,
        orElse: () => Driver(
          id: _order!.driverId,
          name: 'Unknown Driver',
          phone: 'N/A',
          companyId: _order!.companyId,
          createdAt: DateTime.now(),
          createdBy: '',
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _updateOrderStatus(OrderState newStatus) async {
    try {
      final orderProvider = context.read<OrderProvider>();
      
      final updates = {
        'state': newStatus.value,
      };
      
      await orderProvider.updateOrder(_order!.id, updates);
      
      setState(() {
        _order = _order!.copyWith(state: newStatus);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
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

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderState.values.map((status) {
            final isSelected = status == _order!.state;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              title: Text(status.displayName),
              onTap: () {
                Navigator.pop(context);
                if (status != _order!.state) {
                  _updateOrderStatus(status);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_order != null ? 'Order #${_order!.orderNumber}' : 'Order Details'),
        actions: _order != null ? [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _showUpdateStatusDialog,
                child: Row(
                  children: [
                    const Icon(Icons.update, size: 18),
                    const SizedBox(width: 8),
                    Text('Update Status'),
                  ],
                ),
              ),
            ],
          ),
        ] : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return CommonWidgets.localizedLoading(context, (tr) => tr.loading);
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading order',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Order not found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(),
          const SizedBox(height: 24),
          _buildCustomerSection(),
          const SizedBox(height: 24),
          _buildCompanySection(),
          const SizedBox(height: 24),
          _buildDriverSection(),
          const SizedBox(height: 24),
          _buildOrderDetailsSection(),
          if (_order!.note != null && _order!.note!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildNotesSection(),
          ],
          const SizedBox(height: 24),
          _buildStatusUpdateSection(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    Color statusColor;
    IconData statusIcon;
    switch (_order!.state) {
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${_order!.orderNumber}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(_order!.createdAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _order!.state.displayName,
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Amount',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${_order!.cost.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _buildSection(
      title: 'Customer Information',
      icon: Icons.person,
      color: AppTheme.primaryColor,
      children: [
        _buildInfoRow(Icons.person, 'Name', _order!.customerName),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.location_on, 'Address', _order!.customerAddress),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.calendar_today, 'Delivery Date', 
          DateFormat('MMM dd, yyyy').format(_order!.date)),
      ],
    );
  }

  Widget _buildCompanySection() {
    return _buildSection(
      title: 'Delivery Company',
      icon: Icons.business,
      color: AppTheme.infoColor,
      children: [
        _buildInfoRow(Icons.business, 'Company Name', _company!.name),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.location_city, 'Address', _company!.address),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.phone, 'Contact', _company!.contact),
      ],
    );
  }

  Widget _buildDriverSection() {
    return _buildSection(
      title: 'Assigned Driver',
      icon: Icons.local_shipping,
      color: AppTheme.successColor,
      children: [
        _buildInfoRow(Icons.person, 'Driver Name', _driver!.name),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.phone, 'Phone', _driver!.phone),
      ],
    );
  }

  Widget _buildOrderDetailsSection() {
    return _buildSection(
      title: 'Order Details',
      icon: Icons.receipt_long,
      color: AppTheme.warningColor,
      children: [
        _buildInfoRow(Icons.numbers, 'Order Number', _order!.orderNumber),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.attach_money, 'Cost', '\$${_order!.cost.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.calendar_today, 'Order Date', 
          DateFormat('MMM dd, yyyy').format(_order!.date)),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.person, 'Created By', _order!.createdBy),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.schedule, 'Created At', 
          DateFormat('MMM dd, yyyy HH:mm').format(_order!.createdAt)),
      ],
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: 'Notes',
      icon: Icons.note,
      color: Colors.grey,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            _order!.note!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusUpdateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.update, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_order!.state == OrderState.received) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateOrderStatus(OrderState.returned),
                      icon: const Icon(Icons.check_circle),
                      label: Text('Mark as Returned'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateOrderStatus(OrderState.notReturned),
                      icon: const Icon(Icons.cancel),
                      label: Text('Mark as Not Returned'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (_order!.state != OrderState.received)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showUpdateStatusDialog,
                      icon: const Icon(Icons.edit),
                      label: Text('Change Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
