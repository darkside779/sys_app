// ignore_for_file: use_build_context_synchronously, unused_import, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../models/order_model.dart' as models;
import '../../models/driver_model.dart';
import '../../localization/localization_extension.dart';
import '../../app/theme.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _costController = TextEditingController();
  final _noteController = TextEditingController();
  
  String? _selectedCompanyId;
  String? _selectedDriverId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProvider>().initialize();
      context.read<DriverProvider>().initialize();
    });
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate() || _selectedCompanyId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<OrderProvider>();

      final order = models.Order(
        id: '', // Will be set by Firestore
        orderNumber: _orderNumberController.text.trim(),
        customerName: _customerNameController.text.trim(),
        customerAddress: _customerAddressController.text.trim(),
        cost: double.parse(_costController.text.trim()),
        date: _selectedDate,
        state: models.OrderState.received,
        companyId: _selectedCompanyId!,
        createdBy: authProvider.user!.id,
        createdAt: DateTime.now(),
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        driverId: _selectedDriverId ?? 'unassigned', // Use selected driver or unassigned
      );

      final success = await orderProvider.createOrder(order);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.tr.data_saved} - Order created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create order. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr.operation_failed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.create_order),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr.order_details,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Order Number
                      TextFormField(
                        controller: _orderNumberController,
                        decoration: InputDecoration(
                          labelText: context.tr.order_number,
                          prefixIcon: const Icon(Icons.receipt),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr.required_field;
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Customer Name
                      TextFormField(
                        controller: _customerNameController,
                        decoration: InputDecoration(
                          labelText: context.tr.customer_name,
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr.required_field;
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Customer Address
                      TextFormField(
                        controller: _customerAddressController,
                        decoration: InputDecoration(
                          labelText: context.tr.customer_address,
                          prefixIcon: const Icon(Icons.location_on),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr.required_field;
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Cost
                      TextFormField(
                        controller: _costController,
                        decoration: InputDecoration(
                          labelText: '${context.tr.amount} (${context.tr.currency_symbol})',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr.required_field;
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${context.tr.order_date}: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Company Selection
                      Consumer<CompanyProvider>(
                        builder: (context, companyProvider, child) {
                          if (companyProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedCompanyId,
                            decoration: InputDecoration(
                              labelText: context.tr.delivery_companies,
                              prefixIcon: const Icon(Icons.business),
                              border: const OutlineInputBorder(),
                            ),
                            items: companyProvider.companies.map((company) {
                              return DropdownMenuItem(
                                value: company.id,
                                child: Text(company.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCompanyId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a delivery company';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Driver Selection (Optional)
                      Consumer<DriverProvider>(
                        builder: (context, driverProvider, child) {
                          if (driverProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedDriverId,
                            decoration: InputDecoration(
                              labelText: '${context.tr.assign_driver} (Optional)',
                              prefixIcon: const Icon(Icons.local_shipping),
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(context.tr.assign_later),
                              ),
                              ...driverProvider.drivers.map((driver) {
                                return DropdownMenuItem(
                                  value: driver.id,
                                  child: Text('${driver.name} - ${driver.phone}'),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDriverId = value;
                              });
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Note (Optional)
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: '${context.tr.order_note} (Optional)',
                          prefixIcon: const Icon(Icons.note),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Create Order Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        context.tr.create_order,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
