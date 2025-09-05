// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../models/company_model.dart';
import '../../models/driver_model.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final DeliveryCompany? company;
  final Driver? driver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdateStatus;

  const OrderCard({
    super.key,
    required this.order,
    required this.company,
    required this.driver,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateStatus,
  });

  Color _getStatusColor(OrderState status) {
    switch (status) {
      case OrderState.received:
        return Colors.blue;
      case OrderState.returned:
        return Colors.green;
      case OrderState.notReturned:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.state).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(order.state)),
                  ),
                  child: Text(
                    order.state.displayName,
                    style: TextStyle(
                      color: _getStatusColor(order.state),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onUpdateStatus,
                      child: Row(
                        children: [
                          const Icon(Icons.update, size: 18),
                          const SizedBox(width: 8),
                          Text('Update Status'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: onEdit,
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18),
                          const SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: onDelete,
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Delete', style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Customer', order.customerName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Address', order.customerAddress),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.business, 'Company', company?.name ?? 'Unknown'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.local_shipping, 'Driver', driver?.name ?? 'Unknown'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.attach_money, 'Cost', '\$${order.cost.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Date', order.date.toString().split(' ')[0]),
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
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class OrderDialog extends StatefulWidget {
  final Order? order;

  const OrderDialog({super.key, this.order});

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _costController = TextEditingController();
  final _noteController = TextEditingController();
  
  String? _selectedCompanyId;
  String? _selectedDriverId;
  OrderState _selectedStatus = OrderState.received;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _orderNumberController.text = widget.order!.orderNumber;
      _customerNameController.text = widget.order!.customerName;
      _customerAddressController.text = widget.order!.customerAddress;
      _costController.text = widget.order!.cost.toString();
      _noteController.text = widget.order!.note ?? '';
      _selectedCompanyId = widget.order!.companyId;
      _selectedDriverId = widget.order!.driverId;
      _selectedStatus = widget.order!.state;
      _selectedDate = widget.order!.date;
    }
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompanyId == null || _selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both company and driver'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      final authProvider = context.read<AuthProvider>();
      
      if (widget.order == null) {
        // Create new order
        final newOrder = Order(
          id: '', // Will be set by the provider
          companyId: _selectedCompanyId!,
          driverId: _selectedDriverId!,
          customerName: _customerNameController.text.trim(),
          customerAddress: _customerAddressController.text.trim(),
          date: _selectedDate,
          cost: double.parse(_costController.text.trim()),
          orderNumber: _orderNumberController.text.trim(),
          state: _selectedStatus,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          createdBy: authProvider.user?.id ?? 'unknown_user',
          createdAt: DateTime.now(),
        );
        await orderProvider.createOrder(newOrder);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing order
        final updates = {
          'companyId': _selectedCompanyId!,
          'driverId': _selectedDriverId!,
          'customerName': _customerNameController.text.trim(),
          'customerAddress': _customerAddressController.text.trim(),
          'date': _selectedDate,
          'cost': double.parse(_costController.text.trim()),
          'orderNumber': _orderNumberController.text.trim(),
          'state': _selectedStatus.value,
          'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        };
        await orderProvider.updateOrder(widget.order!.id, updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Operation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.order == null ? 'Create Order' : 'Edit Order'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _orderNumberController,
                  decoration: InputDecoration(
                    labelText: 'Order Number',
                    hintText: 'Enter order number',
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Order number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    hintText: 'Enter customer name',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Customer name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customerAddressController,
                  decoration: InputDecoration(
                    labelText: 'Customer Address',
                    hintText: 'Enter customer address',
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Customer address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costController,
                  decoration: InputDecoration(
                    labelText: 'Cost',
                    hintText: 'Enter cost',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cost is required';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Consumer<CompanyProvider>(
                  builder: (context, companyProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCompanyId,
                      decoration: InputDecoration(
                        labelText: 'Company',
                        prefixIcon: const Icon(Icons.business),
                      ),
                      items: companyProvider.companies.map((company) =>
                        DropdownMenuItem<String>(
                          value: company.id,
                          child: Text(company.name),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCompanyId = value;
                          _selectedDriverId = null; // Reset driver selection
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a company';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<DriverProvider>(
                  builder: (context, driverProvider, child) {
                    final availableDrivers = _selectedCompanyId != null
                        ? driverProvider.drivers.where((d) => d.companyId == _selectedCompanyId).toList()
                        : <Driver>[];
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedDriverId,
                      decoration: InputDecoration(
                        labelText: 'Driver',
                        prefixIcon: const Icon(Icons.local_shipping),
                      ),
                      items: availableDrivers.map((driver) =>
                        DropdownMenuItem<String>(
                          value: driver.id,
                          child: Text(driver.name),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDriverId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a driver';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<OrderState>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.info),
                  ),
                  items: OrderState.values.map((status) =>
                    DropdownMenuItem<OrderState>(
                      value: status,
                      child: Text(status.displayName),
                    ),
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Date: ${_selectedDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (Optional)',
                    hintText: 'Enter additional notes',
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _saveOrder(),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(widget.order == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}

class UpdateStatusDialog extends StatefulWidget {
  final Order order;

  const UpdateStatusDialog({super.key, required this.order});

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  late OrderState _selectedStatus;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.state;
    _noteController.text = widget.order.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      
      final updates = {
        'state': _selectedStatus.value,
        'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      };
      
      await orderProvider.updateOrder(widget.order.id, updates);
      
      if (mounted) {
        Navigator.pop(context);
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Order #${widget.order.orderNumber}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<OrderState>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: const Icon(Icons.info),
            ),
            items: OrderState.values.map((status) =>
              DropdownMenuItem<OrderState>(
                value: status,
                child: Text(status.displayName),
              ),
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Update Note (Optional)',
              hintText: 'Enter additional notes',
              prefixIcon: const Icon(Icons.note),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _updateStatus(),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text('Update Status'),
        ),
      ],
    );
  }
}
