// ignore_for_file: unused_import, deprecated_member_use, avoid_print, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show Border, BorderSide;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import '../../providers/order_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/order_model.dart';
import '../../models/company_model.dart';
import '../../models/driver_model.dart';
import '../../models/user_model.dart';
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
  String? _selectedCreatedBy;
  OrderState? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  bool _isFiltersExpanded = true;

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
    final userProvider = context.read<UserProvider>();

    // Load users if not already loaded
    if (userProvider.users.isEmpty) {
      userProvider.loadUsers();
    }

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
      orders = orders
          .where(
            (order) => order.orderNumber.toLowerCase().contains(
              _orderNumberController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    // Filter by company
    if (_selectedCompanyId != null) {
      orders = orders
          .where((order) => order.companyId == _selectedCompanyId)
          .toList();
    }

    // Filter by driver
    if (_selectedDriverId != null) {
      orders = orders
          .where((order) => order.driverId == _selectedDriverId)
          .toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      orders = orders.where((order) => order.state == _selectedStatus).toList();
    }

    // Filter by created by user
    if (_selectedCreatedBy != null) {
      orders = orders
          .where((order) => order.createdBy == _selectedCreatedBy)
          .toList();
    }

    // Filter by date range
    if (_startDate != null) {
      orders = orders
          .where(
            (order) =>
                order.date.isAfter(_startDate!) ||
                order.date.isAtSameMomentAs(_startDate!),
          )
          .toList();
    }
    if (_endDate != null) {
      orders = orders
          .where(
            (order) => order.date.isBefore(_endDate!.add(Duration(days: 1))),
          )
          .toList();
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
      _selectedCreatedBy = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
    _loadInitialData();
  }

  Map<String, dynamic> _generateStatistics() {
    final stats = <String, dynamic>{};

    stats['totalOrders'] = _filteredOrders.length;
    stats['receivedOrders'] = _filteredOrders
        .where((o) => o.state == OrderState.received)
        .length;
    stats['returnedOrders'] = _filteredOrders
        .where((o) => o.state == OrderState.returned)
        .length;
    stats['notReturnedOrders'] = _filteredOrders
        .where((o) => o.state == OrderState.notReturned)
        .length;

    stats['totalRevenue'] = _filteredOrders.fold<double>(
      0,
      (sum, order) => sum + order.cost,
    );
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

  Future<void> _printReport() async {
    try {
      final pdf = await _generatePdfReport();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        CommonWidgets.showLocalizedSnackBar(
          context: context,
          getMessage: (tr) => 'An error occurred while printing',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<pw.Document> _generatePdfReport() async {
    final pdf = pw.Document();
    final stats = _generateStatistics();
    final companyProvider = context.read<CompanyProvider>();
    final driverProvider = context.read<DriverProvider>();
    final userProvider = context.read<UserProvider>();

    // Ensure users are loaded
    if (userProvider.users.isEmpty) {
      await userProvider.loadUsers();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'Order Reports',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Date range
            if (_startDate != null && _endDate != null)
              pw.Text(
                'Date Range: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                style: pw.TextStyle(fontSize: 12),
              ),
            pw.Text(
              'Generated on: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 20),

            // Statistics
            pw.Header(level: 1, child: pw.Text('Summary Statistics')),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Value'],
              data: [
                ['Total Orders', stats['totalOrders'].toString()],
                ['Received Orders', stats['receivedOrders'].toString()],
                ['Returned Orders', stats['returnedOrders'].toString()],
                ['Not Returned Orders', stats['notReturnedOrders'].toString()],
                [
                  'Total Revenue',
                  'AED ${stats['totalRevenue'].toStringAsFixed(2)}',
                ],
                [
                  'Average Order Value',
                  'AED ${stats['averageOrderValue'].toStringAsFixed(2)}',
                ],
              ],
            ),
            pw.SizedBox(height: 20),

            // Orders table
            pw.Header(
              level: 1,
              child: pw.Text(
                'Order Details (${_filteredOrders.length} orders)',
              ),
            ),
            if (_filteredOrders.isEmpty)
              pw.Text(
                'No orders found. Please check your filters or ensure orders are loaded.',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.red),
              )
            else
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: pw.TextStyle(fontSize: 9),
                headers: [
                  'Order #',
                  'Customer',
                  'Address',
                  'Company',
                  'Driver',
                  'Status',
                  'Amount',
                  'Date',
                  'Created By',
                  'Notes',
                ],
                data: _filteredOrders.map((order) {
                  final company = companyProvider.companies
                      .where((c) => c.id == order.companyId)
                      .firstOrNull;
                  final driver = driverProvider.drivers
                      .where((d) => d.id == order.driverId)
                      .firstOrNull;
                  final createdByUser = userProvider.getUserById(
                    order.createdBy,
                  );
                  print(
                    'DEBUG PDF: Looking for user ID: ${order.createdBy}, found: ${createdByUser?.name ?? 'NULL'}',
                  );
                  print(
                    'DEBUG PDF: Available users: ${userProvider.users.map((u) => '${u.id}:${u.name}').join(', ')}',
                  );
                  return [
                    order.orderNumber,
                    order.customerName,
                    order.customerAddress,
                    company?.name ?? 'Unknown',
                    driver?.name ?? 'Unassigned',
                    order.state.name,
                    'AED ${order.cost.toStringAsFixed(2)}',
                    DateFormat('MMM dd, yyyy').format(order.date),
                    createdByUser?.name ?? 'Unknown User',
                    (order.note?.isNotEmpty ?? false) ? order.note! : 'N/A',
                  ];
                }).toList(),
              ),
          ];
        },
      ),
    );

    return pdf;
  }

  Future<void> _exportToExcel() async {
    try {
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Order Reports'];
      final stats = _generateStatistics();
      final companyProvider = context.read<CompanyProvider>();
      final driverProvider = context.read<DriverProvider>();
      final userProvider = context.read<UserProvider>();

      // Ensure users are loaded
      if (userProvider.users.isEmpty) {
        await userProvider.loadUsers();
      }

      int currentRow = 0;

      // Title
      sheet.cell(
          excel.CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: currentRow,
          ),
        )
        ..value = excel.TextCellValue('Order Reports')
        ..cellStyle = excel.CellStyle(bold: true, fontSize: 16);
      currentRow += 2;

      // Generation info
      sheet
          .cell(
            excel.CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: currentRow,
            ),
          )
          .value = excel.TextCellValue(
        'Generated on: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
      );
      currentRow++;

      // Date range
      if (_startDate != null && _endDate != null) {
        sheet
            .cell(
              excel.CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: currentRow,
              ),
            )
            .value = excel.TextCellValue(
          'Date Range: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
        );
        currentRow += 2;
      } else {
        sheet
            .cell(
              excel.CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: currentRow,
              ),
            )
            .value = excel.TextCellValue(
          'Date Range: All dates',
        );
        currentRow += 2;
      }

      // Statistics section
      sheet.cell(
          excel.CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: currentRow,
          ),
        )
        ..value = excel.TextCellValue('Summary Statistics')
        ..cellStyle = excel.CellStyle(bold: true, fontSize: 14);
      currentRow++;

      // Statistics data
      final statisticsData = [
        ['Metric', 'Value'],
        ['Total Orders', stats['totalOrders'].toString()],
        ['Received Orders', stats['receivedOrders'].toString()],
        ['Returned Orders', stats['returnedOrders'].toString()],
        ['Not Returned Orders', stats['notReturnedOrders'].toString()],
        ['Total Revenue', 'AED ${stats['totalRevenue'].toStringAsFixed(2)}'],
        [
          'Average Order Value',
          'AED ${stats['averageOrderValue'].toStringAsFixed(2)}',
        ],
      ];

      for (int i = 0; i < statisticsData.length; i++) {
        for (int j = 0; j < statisticsData[i].length; j++) {
          final cell = sheet.cell(
            excel.CellIndex.indexByColumnRow(
              columnIndex: j,
              rowIndex: currentRow + i,
            ),
          );
          cell.value = excel.TextCellValue(statisticsData[i][j]);
          if (i == 0) {
            cell.cellStyle = excel.CellStyle(bold: true);
          }
        }
      }
      currentRow += statisticsData.length + 2;

      // Orders section
      sheet.cell(
          excel.CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: currentRow,
          ),
        )
        ..value = excel.TextCellValue(
          'Order Details (${_filteredOrders.length} orders)',
        )
        ..cellStyle = excel.CellStyle(bold: true, fontSize: 14);
      currentRow++;

      if (_filteredOrders.isEmpty) {
        sheet
            .cell(
              excel.CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: currentRow,
              ),
            )
            .value = excel.TextCellValue(
          'No orders found. Please check your filters or ensure orders are loaded.',
        );
        currentRow++;
      } else {
        // Headers
        final headers = [
          'Order Number',
          'Customer Name',
          'Customer Address',
          'Company',
          'Driver',
          'Status',
          'Amount (AED)',
          'Order Date',
          'Created At',
          'Created By',
          'Notes',
        ];

        for (int i = 0; i < headers.length; i++) {
          sheet.cell(
              excel.CellIndex.indexByColumnRow(
                columnIndex: i,
                rowIndex: currentRow,
              ),
            )
            ..value = excel.TextCellValue(headers[i])
            ..cellStyle = excel.CellStyle(bold: true);
        }
        currentRow++;

        // Orders data
        for (final order in _filteredOrders) {
          final company = companyProvider.companies
              .where((c) => c.id == order.companyId)
              .firstOrNull;
          final driver = driverProvider.drivers
              .where((d) => d.id == order.driverId)
              .firstOrNull;
          final createdByUser = userProvider.getUserById(order.createdBy);
          final rowData = [
            order.orderNumber,
            order.customerName,
            order.customerAddress,
            company?.name ?? 'Unknown Company',
            driver?.name ?? 'Unassigned',
            order.state.name,
            order.cost.toStringAsFixed(2),
            DateFormat('MMM dd, yyyy').format(order.date),
            DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
            createdByUser?.name ?? 'Unknown User',
            (order.note?.isNotEmpty ?? false) ? order.note! : 'No notes',
          ];

          for (int i = 0; i < rowData.length; i++) {
            sheet
                .cell(
                  excel.CellIndex.indexByColumnRow(
                    columnIndex: i,
                    rowIndex: currentRow,
                  ),
                )
                .value = excel.TextCellValue(
              rowData[i].toString(),
            );
          }
          currentRow++;
        }
      }

      // Save the file
      final excelBytes = excelFile.save()!;
      final fileName =
          'Order_Reports_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        // Web platform
        final blob = html.Blob([excelBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile/Desktop platforms
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(excelBytes);
      }

      if (mounted) {
        CommonWidgets.showLocalizedSnackBar(
          context: context,
          getMessage: (tr) =>
              'Export successful: $fileName (${_filteredOrders.length} orders)',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        CommonWidgets.showLocalizedSnackBar(
          context: context,
          getMessage: (tr) => 'Export failed: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
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
            InkWell(
              onTap: () {
                setState(() {
                  _isFiltersExpanded = !_isFiltersExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).filters,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isFiltersExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Spacer(),
                  if (_isFiltersExpanded) ...[
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: Text(AppLocalizations.of(context).clear),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.search),
                      label: Text(AppLocalizations.of(context).apply),
                    ),
                  ] else ...[
                    // Show compact apply button when collapsed
                    ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.search),
                      label: Text(AppLocalizations.of(context).apply),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isFiltersExpanded ? Column(
                children: [
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
                      labelText: AppLocalizations.of(context).order_number,
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
                          labelText: AppLocalizations.of(context).company,
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(),
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
                            _selectedCompanyId = value;
                            _selectedDriverId =
                                null; // Reset driver when company changes
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
                          ? driverProvider.drivers
                                .where((d) => d.companyId == _selectedCompanyId)
                                .toList()
                          : driverProvider.drivers;

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedDriverId,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).driver,
                          prefixIcon: const Icon(Icons.local_shipping),
                          border: OutlineInputBorder(),
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
                            _selectedDriverId = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCreatedBy,
                        decoration: InputDecoration(
                          labelText: 'Created By',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Users'),
                          ),
                          ...userProvider.users
                              .where((user) => user.role != UserRole.superAdmin)
                              .map(
                            (user) => DropdownMenuItem<String>(
                              value: user.id,
                              child: Text(user.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCreatedBy = value;
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
                      labelText: AppLocalizations.of(context).status,
                      prefixIcon: const Icon(Icons.info),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem<OrderState>(
                        value: null,
                        child: Text(AppLocalizations.of(context).all_statuses),
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
                ),
                SizedBox(
                  width: 250,
                  child: InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
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
                                  : AppLocalizations.of(
                                      context,
                                    ).select_date_range,
                              style: TextStyle(
                                color: _startDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
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
              ) : const SizedBox.shrink(),
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
          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _printReport,
                icon: const Icon(Icons.print),
                label: Text('Print'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.file_download),
                label: Text('Export to Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Statistics
          Text(
            AppLocalizations.of(context).summary_statistics,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildStatisticsGrid(stats),

          const SizedBox(height: 24),

          // Company Performance
          if (stats['companyBreakdown'].isNotEmpty) ...[
            Text(
              AppLocalizations.of(context).company_performance,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildCompanyPerformance(stats['companyBreakdown']),
            const SizedBox(height: 24),
          ],

          // Driver Performance
          if (stats['driverBreakdown'].isNotEmpty) ...[
            Text(
              AppLocalizations.of(context).driver_performance,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDriverPerformance(stats['driverBreakdown']),
            const SizedBox(height: 24),
          ],

          // Orders List
          Text(
            '${AppLocalizations.of(context).filtered_orders} (${_filteredOrders.length})',
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
        _buildStatCard(
          AppLocalizations.of(context).total_orders,
          stats['totalOrders'].toString(),
          Icons.shopping_bag,
          AppTheme.primaryColor,
        ),
        _buildStatCard(
          AppLocalizations.of(context).received,
          stats['receivedOrders'].toString(),
          Icons.inbox,
          AppTheme.infoColor,
        ),
        _buildStatCard(
          AppLocalizations.of(context).returned,
          stats['returnedOrders'].toString(),
          Icons.check_circle,
          AppTheme.successColor,
        ),
        _buildStatCard(
          AppLocalizations.of(context).not_returned,
          stats['notReturnedOrders'].toString(),
          Icons.cancel,
          AppTheme.errorColor,
        ),
        _buildStatCard(
          AppLocalizations.of(context).total_revenue,
          'AED ${stats['totalRevenue'].toStringAsFixed(2)}',
          Icons.attach_money,
          AppTheme.warningColor,
        ),
        _buildStatCard(
          AppLocalizations.of(context).average_order,
          'AED ${stats['averageOrderValue'].toStringAsFixed(2)}',
          Icons.trending_up,
          AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(
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
                    name: AppLocalizations.of(context).unknown_company,
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
                  subtitle: Text(
                    '${entry.value}${AppLocalizations.of(context).orders}',
                  ),
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
                    name: AppLocalizations.of(context).unknown_driver,
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
                  subtitle: Text(
                    '${entry.value}${AppLocalizations.of(context).orders}',
                  ),
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
                  AppLocalizations.of(context).no_orders_found,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).try_adjusting_filters,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).order_hash,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).customer,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).status,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).amount,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).date,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
      case OrderState.outForDelivery:
        statusColor = Colors.blue;
        break;
      case OrderState.returned:
        statusColor = AppTheme.successColor;
        break;
      case OrderState.notReturned:
        statusColor = AppTheme.errorColor;
        break;
    }

    final isStale = order.isStale;
    final daysSinceUpdate = order.daysSinceLastUpdate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        // Add warning background for stale orders
        color: isStale ? Colors.orange.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(order.orderNumber)),
          Expanded(child: Text(order.customerName)),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Text(
                      order.state.getLocalizedDisplayName(context),
                      style: TextStyle(color: statusColor, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                if (isStale) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'This order needs attention - no status change for $daysSinceUpdate days',
                    child: const Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: Text('  AED ${order.cost.toStringAsFixed(2)}')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(order.date)),
                if (isStale)
                  Text(
                    'Order has been $daysSinceUpdate days without status change!',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
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
