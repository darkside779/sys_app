// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_import, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../localization/app_localizations.dart';
import 'order_components.dart';
import 'bulk_edit_dialog.dart';
import '../../models/driver_model.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';
import '../../services/excel_import_service.dart';

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

  // Multiple selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedOrderIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
      context.read<CompanyProvider>().loadAllCompanies();
      context.read<DriverProvider>().loadAllDrivers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _importOrdersFromExcel() async {
    try {
      // Pick Excel or CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User canceled
      }

      final file = result.files.first;
      if (file.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check file size limit (500KB max)
      const maxFileSizeBytes = 500 * 1024; // 500KB
      final fileSizeKB = (file.bytes!.length / 1024).toStringAsFixed(2);
      print('DEBUG: File size: ${fileSizeKB}KB');

      if (file.bytes!.length > maxFileSizeBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File too large. Maximum size is 500KB.\nFile size: ${fileSizeKB}KB',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing orders from Excel...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Get required data for import
      final companyProvider = context.read<CompanyProvider>();
      final driverProvider = context.read<DriverProvider>();

      // Use first company and driver as defaults, or create defaults if none exist
      String defaultCompanyId = '';
      String defaultDriverId = 'unassigned';

      if (companyProvider.companies.isNotEmpty) {
        defaultCompanyId = companyProvider.companies.first.id;
      }
      if (driverProvider.drivers.isNotEmpty) {
        defaultDriverId = driverProvider.drivers.first.id;
      }

      // Import orders
      final importResult = await ExcelImportService.importOrdersFromExcel(
        fileBytes: file.bytes!,
        fileName: file.name,
        defaultCompanyId: defaultCompanyId,
        defaultDriverId: defaultDriverId,
        adminUserId: 'admin', // Default admin user ID
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (importResult.success) {
        // Add orders to provider
        final orderProvider = context.read<OrderProvider>();
        int addedCount = 0;

        for (final order in importResult.importedOrders) {
          final success = await orderProvider.createOrder(order);
          if (success) addedCount++;
        }

        // Show results dialog
        _showImportResultsDialog(importResult, addedCount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult.errorMessage ?? 'Import failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import Excel file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportResultsDialog(ExcelImportResult result, int addedCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total rows processed: ${result.totalRows ?? 0}'),
            Text('Orders parsed: ${result.importedOrders.length}'),
            Text('Orders added to system: $addedCount'),
            if (result.errors != null && result.errors!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Errors (${result.errors!.length}):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result.errors!
                        .map(
                          (error) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $error',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCreateOrderDialog() {
    showDialog(context: context, builder: (context) => OrderDialog());
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
              context.read<OrderProvider>().deleteOrder(orderId).then((
                success,
              ) {
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete order'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
            child: Text(
              AppLocalizations.of(context).delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Bulk selection methods
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedOrderIds.clear();
      }
    });
  }

  void _selectAllOrders(List<Order> orders) {
    setState(() {
      _selectedOrderIds.addAll(orders.map((order) => order.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedOrderIds.clear();
    });
  }

  void _showBulkEditDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkEditDialog(
        selectedOrderIds: _selectedOrderIds.toList(),
        onSaved: () {
          // Clear selection and exit selection mode after successful edit
          setState(() {
            _selectedOrderIds.clear();
            _isSelectionMode = false;
          });
        },
      ),
    );
  }

  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Orders'),
        content: Text(
          'Are you sure you want to delete ${_selectedOrderIds.length} selected orders? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _bulkDeleteOrders();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkDeleteOrders() async {
    final orderProvider = context.read<OrderProvider>();
    int successCount = 0;
    int totalCount = _selectedOrderIds.length;

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
            Text('Deleting orders...'),
          ],
        ),
      ),
    );

    // Delete orders one by one
    final orderIdsToDelete = _selectedOrderIds.toList();
    for (String orderId in orderIdsToDelete) {
      final success = await orderProvider.deleteOrder(orderId);
      if (success) successCount++;
    }

    // Close progress dialog
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Clear selection and exit selection mode
    setState(() {
      _selectedOrderIds.clear();
      _isSelectionMode = false;
    });

    // Show results
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $successCount of $totalCount orders'),
          backgroundColor: successCount == totalCount
              ? Colors.green
              : Colors.orange,
        ),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
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

  void _showUpdateStatusDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderState.values
              .map(
                (status) => ListTile(
                  title: Text(status.getLocalizedDisplayName(context)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<OrderProvider>().updateOrderStatus(
                      order.id,
                      status,
                    );
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
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
      filtered = filtered
          .where((order) => order.companyId == _selectedCompanyFilter)
          .toList();
    }

    if (_selectedDriverFilter != null && _selectedDriverFilter!.isNotEmpty) {
      filtered = filtered
          .where((order) => order.driverId == _selectedDriverFilter)
          .toList();
    }

    if (_selectedStatusFilter != null) {
      filtered = filtered
          .where((order) => order.state == _selectedStatusFilter)
          .toList();
    }

    if (_selectedDateRange != null) {
      filtered = filtered.where((order) {
        return order.date.isAfter(
              _selectedDateRange!.start.subtract(Duration(days: 1)),
            ) &&
            order.date.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            order.customerName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            order.customerAddress.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
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
          if (_isSelectionMode) ...[
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                final orderProvider = context.read<OrderProvider>();
                final filteredOrders = _getFilteredOrders(orderProvider.orders);
                _selectAllOrders(filteredOrders);
              },
              tooltip: 'Select All',
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: 'Clear Selection',
            ),
            if (_selectedOrderIds.isNotEmpty) ...[
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: _showBulkEditDialog,
                tooltip: 'Edit Selected',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: _showBulkDeleteConfirmation,
                tooltip: 'Delete Selected',
              ),
            ],
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _toggleSelectionMode,
              tooltip: 'Exit Selection Mode',
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select Multiple',
            ),
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: _importOrdersFromExcel,
              tooltip: 'Import from Excel',
            ),
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
                    hintText:
                        'Enter order number, customer name, or address...',
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
                                  child: Text(
                                    AppLocalizations.of(context).all_companies,
                                  ),
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
                          final availableDrivers =
                              _selectedCompanyFilter != null
                              ? driverProvider.drivers
                                    .where(
                                      (d) =>
                                          d.companyId == _selectedCompanyFilter,
                                    )
                                    .toList()
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
                                  child: Text(
                                    AppLocalizations.of(context).all_drivers,
                                  ),
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
                              child: Text(
                                AppLocalizations.of(context).all_statuses,
                              ),
                            ),
                            ...OrderState.values.map(
                              (status) => DropdownMenuItem<OrderState>(
                                value: status,
                                child: Text(
                                  status.getLocalizedDisplayName(context),
                                ),
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
                        label: Text(
                          _selectedDateRange == null
                              ? 'Date Range'
                              : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                        ),
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
              builder:
                  (
                    context,
                    orderProvider,
                    companyProvider,
                    driverProvider,
                    child,
                  ) {
                    if (orderProvider.isLoading &&
                        orderProvider.orders.isEmpty) {
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
                                      style: TextStyle(
                                        color: AppTheme.errorColor,
                                      ),
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

                    final filteredOrders = _getFilteredOrders(
                      orderProvider.orders,
                    );

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
                          final company = companyProvider.getCompanyById(
                            order.companyId,
                          );
                          final driver = driverProvider.getDriverById(
                            order.driverId,
                          );
                          return OrderCard(
                            order: order,
                            company: company,
                            driver: driver,
                            onEdit: () => _showEditOrderDialog(order),
                            onDelete: () => _showDeleteConfirmation(order.id),
                            onUpdateStatus: () =>
                                _showUpdateStatusDialog(order),
                            isSelected: _selectedOrderIds.contains(order.id),
                            isSelectionMode: _isSelectionMode,
                            onSelectionChanged: (isSelected) {
                              if (isSelected) {
                                _selectedOrderIds.add(order.id);
                              } else {
                                _selectedOrderIds.remove(order.id);
                              }
                              setState(() {});
                            },
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
