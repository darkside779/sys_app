// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../localization/app_localizations.dart';

class BulkEditDialog extends StatefulWidget {
  final List<String> selectedOrderIds;
  final VoidCallback onSaved;

  const BulkEditDialog({
    super.key,
    required this.selectedOrderIds,
    required this.onSaved,
  });

  @override
  State<BulkEditDialog> createState() => _BulkEditDialogState();
}

class _BulkEditDialogState extends State<BulkEditDialog> {
  String? _selectedCompanyId;
  String? _selectedDriverId;
  OrderState? _selectedStatus;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.selectedOrderIds.length} Orders'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select fields to update:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Consumer<CompanyProvider>(
              builder: (context, companyProvider, child) {
                return DropdownButtonFormField<String>(
                  initialValue: _selectedCompanyId,
                  decoration: InputDecoration(
                    labelText: 'Company (Optional)',
                    hintText: 'Leave empty to keep current',
                    prefixIcon: const Icon(Icons.business),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(AppLocalizations.of(context).no_change),
                    ),
                    ...companyProvider.companies.map(
                      (company) => DropdownMenuItem<String>(
                        value: company.id,
                        child: Text(company.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCompanyId = value;
                      if (value != null) {
                        _selectedDriverId = null; // Reset driver when company changes
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<DriverProvider>(
              builder: (context, driverProvider, child) {
                final availableDrivers = _selectedCompanyId != null
                    ? driverProvider.drivers
                        .where((d) => d.companyId == _selectedCompanyId)
                        .toList()
                    : driverProvider.drivers;

                return DropdownButtonFormField<String>(
                  initialValue: _selectedDriverId,
                  decoration: InputDecoration(
                    labelText: 'Driver (Optional)',
                    hintText: 'Leave empty to keep current',
                    prefixIcon: const Icon(Icons.local_shipping),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(AppLocalizations.of(context).no_change),
                    ),
                    DropdownMenuItem<String>(
                      value: 'unassigned',
                      child: Text(AppLocalizations.of(context).unassigned),
                    ),
                    ...availableDrivers.map(
                      (driver) => DropdownMenuItem<String>(
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
            const SizedBox(height: 16),
            DropdownButtonFormField<OrderState>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status (Optional)',
                hintText: 'Leave empty to keep current',
                prefixIcon: const Icon(Icons.info),
              ),
              items: [
                DropdownMenuItem<OrderState>(
                  value: null,
                  child: Text(AppLocalizations.of(context).no_change),
                ),
                ...OrderState.values.map(
                  (status) => DropdownMenuItem<OrderState>(
                    value: status,
                    child: Text(status.getLocalizedDisplayName(context)),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text('Update Orders'),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    // Check if any field is selected for update
    if (_selectedCompanyId == null && _selectedDriverId == null && _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one field to update'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      int successCount = 0;
      int totalCount = widget.selectedOrderIds.length;

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Updating orders...'),
            ],
          ),
        ),
      );

      // Update each order
      for (String orderId in widget.selectedOrderIds) {
        final Map<String, dynamic> updates = {};
        
        if (_selectedCompanyId != null) {
          updates['companyId'] = _selectedCompanyId;
        }
        if (_selectedDriverId != null) {
          updates['driverId'] = _selectedDriverId;
        }
        if (_selectedStatus != null) {
          updates['state'] = _selectedStatus!.value;
        }

        final success = await orderProvider.updateOrder(orderId, updates);
        if (success) successCount++;
      }

      // Close progress dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Close edit dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show results
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated $successCount of $totalCount orders'),
            backgroundColor: successCount == totalCount ? Colors.green : Colors.orange,
          ),
        );

        // Call onSaved callback
        widget.onSaved();
      }
    } catch (e) {
      // Close progress dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update orders: ${e.toString()}'),
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
}
