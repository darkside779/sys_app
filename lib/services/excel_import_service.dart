// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'dart:convert';
import 'package:excel/excel.dart' as excel;
import 'package:intl/intl.dart';
import '../models/order_model.dart';

class ExcelImportService {
  // Arabic to English header mapping
  static const Map<String, String> _headerMapping = {
    'التاريخ': 'date',
    'رقم تتبع الاوردر': 'orderNumber',
    'اسم الزبون': 'customerName',
    'رقم الزبون': 'customerNumber',
    'الإمارة': 'customerAddress',
    'المحتويات': 'products',
    'قيمة الاوردر': 'cost',
    'الموظفة': 'createdBy',
    'حالة الاوردر': 'status',
    'تاريخ وصول الكاش': 'cashArrivalDate',
  };

  // Status mapping from Arabic to OrderState
  static const Map<String, OrderState> _statusMapping = {
    'استلام': OrderState.received,
    'استلم': OrderState.received,
    'تسليم': OrderState.outForDelivery,
    'في الطريق': OrderState.outForDelivery,
    'تم التسليم': OrderState.returned,
    'راجع': OrderState.returned,
    'لم يتم التسليم': OrderState.notReturned,
    'لم يرجع': OrderState.notReturned,
    'مردود': OrderState.returned,
  };

  static Future<ExcelImportResult> importOrdersFromExcel({
    required Uint8List fileBytes,
    required String fileName,
    required String defaultCompanyId,
    required String defaultDriverId,
    required String adminUserId,
  }) async {
    try {
      // Check file extension to determine format
      final isCSV = fileName.toLowerCase().endsWith('.csv');
      
      if (isCSV) {
        print('DEBUG: Processing CSV file');
        return await _importFromCSV(
          fileBytes: fileBytes,
          fileName: fileName,
          defaultCompanyId: defaultCompanyId,
          defaultDriverId: defaultDriverId,
          adminUserId: adminUserId,
        );
      } else {
        print('DEBUG: Processing Excel file');
        return await _importFromExcel(
          fileBytes: fileBytes,
          fileName: fileName,
          defaultCompanyId: defaultCompanyId,
          defaultDriverId: defaultDriverId,
          adminUserId: adminUserId,
        );
      }
    } catch (e) {
      return ExcelImportResult(
        success: false,
        errorMessage: 'Failed to process file: $e',
        importedOrders: [],
      );
    }
  }

  // CSV import logic
  static Future<ExcelImportResult> _importFromCSV({
    required Uint8List fileBytes,
    required String fileName,
    required String defaultCompanyId,
    required String defaultDriverId,
    required String adminUserId,
  }) async {
    try {
      // Convert bytes to string
      final csvContent = utf8.decode(fileBytes);
      final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      if (lines.isEmpty) {
        return ExcelImportResult(
          success: false,
          errorMessage: 'CSV file is empty',
          importedOrders: [],
        );
      }

      // Limit rows (increased for larger CSV files)
      const maxRows = 2000;
      if (lines.length > maxRows + 1) {
        return ExcelImportResult(
          success: false,
          errorMessage: 'File has too many rows (${lines.length - 1}). Maximum allowed: $maxRows',
          importedOrders: [],
        );
      }

      // Parse header row
      final headerLine = lines.first;
      final headers = _parseCSVLine(headerLine);
      final Map<String, int> columnIndexes = {};
      
      for (int i = 0; i < headers.length; i++) {
        final cellValue = headers[i].trim();
        if (_headerMapping.containsKey(cellValue)) {
          columnIndexes[_headerMapping[cellValue]!] = i;
        }
      }

      // Log available columns for debugging (all columns are optional)
      print('DEBUG: Available columns: ${columnIndexes.keys.toList()}');

      // Process data rows
      final List<Order> orders = [];
      final List<String> errors = [];
      
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        try {
          final row = _parseCSVLine(line);
          final order = _parseOrderFromCSVRow(
            row: row,
            columnIndexes: columnIndexes,
            rowNumber: i + 1,
            defaultCompanyId: defaultCompanyId,
            defaultDriverId: defaultDriverId,
            adminUserId: adminUserId,
          );
          
          if (order != null) {
            orders.add(order);
          }
        } catch (e) {
          errors.add('Row ${i + 1}: $e');
        }
      }

      return ExcelImportResult(
        success: true,
        importedOrders: orders,
        errors: errors.isNotEmpty ? errors : null,
        totalRows: lines.length - 1,
        successfulRows: orders.length,
      );
    } catch (e) {
      return ExcelImportResult(
        success: false,
        errorMessage: 'Failed to process CSV file: $e',
        importedOrders: [],
      );
    }
  }

  // Excel import logic (existing code)
  static Future<ExcelImportResult> _importFromExcel({
    required Uint8List fileBytes,
    required String fileName,
    required String defaultCompanyId,
    required String defaultDriverId,
    required String adminUserId,
  }) async {
    try {
      // Limit maximum rows to prevent memory issues
      const maxRows = 25;
      
      print('DEBUG: Starting Excel decode, file size: ${fileBytes.length} bytes');
      
      excel.Excel? excelFile;
      try {
        excelFile = excel.Excel.decodeBytes(fileBytes);
        print('DEBUG: Excel decode successful');
      } catch (e) {
        print('DEBUG: Excel decode failed: $e');
        return ExcelImportResult(
          success: false,
          errorMessage: 'Failed to decode Excel file. File may be corrupted or too large.',
          importedOrders: [],
        );
      }
      
      final sheet = excelFile.tables[excelFile.tables.keys.first];
      print('DEBUG: Got sheet with ${sheet?.rows.length ?? 0} rows');
      
      if (sheet == null || sheet.rows.isEmpty) {
        return ExcelImportResult(
          success: false,
          errorMessage: 'Excel file is empty or invalid',
          importedOrders: [],
        );
      }

      // Check row count limit
      if (sheet.rows.length > maxRows + 1) { // +1 for header
        return ExcelImportResult(
          success: false,
          errorMessage: 'File has too many rows (${sheet.rows.length - 1}). Maximum allowed: $maxRows',
          importedOrders: [],
        );
      }

      // Get header row (first row)
      final headerRow = sheet.rows.first;
      final Map<String, int> columnIndexes = {};
      
      // Map Arabic headers to column indexes
      for (int i = 0; i < headerRow.length; i++) {
        final cellValue = headerRow[i]?.value?.toString().trim();
        if (cellValue != null && _headerMapping.containsKey(cellValue)) {
          columnIndexes[_headerMapping[cellValue]!] = i;
        }
      }

      // Validate required columns
      final requiredFields = ['orderNumber', 'customerName', 'customerAddress', 'cost'];
      final missingFields = requiredFields.where((field) => !columnIndexes.containsKey(field)).toList();
      
      if (missingFields.isNotEmpty) {
        return ExcelImportResult(
          success: false,
          errorMessage: 'Missing required columns: ${missingFields.join(', ')}',
          importedOrders: [],
        );
      }

      // Process data rows in batches to manage memory
      final List<Order> orders = [];
      final List<String> errors = [];
      const batchSize = 10; // Very small batches
      
      print('DEBUG: Starting to process ${sheet.rows.length - 1} rows in batches of $batchSize');
      
      for (int startIndex = 1; startIndex < sheet.rows.length; startIndex += batchSize) {
        final endIndex = (startIndex + batchSize > sheet.rows.length) 
            ? sheet.rows.length 
            : startIndex + batchSize;
        
        // Process batch
        for (int rowIndex = startIndex; rowIndex < endIndex; rowIndex++) {
          final row = sheet.rows[rowIndex];
          
          // Skip empty rows
          if (_isEmptyRow(row)) continue;
          
          try {
            final order = _parseOrderFromRow(
              row: row,
              columnIndexes: columnIndexes,
              rowNumber: rowIndex + 1,
              defaultCompanyId: defaultCompanyId,
              defaultDriverId: defaultDriverId,
              adminUserId: adminUserId,
            );
            
            if (order != null) {
              orders.add(order);
            }
          } catch (e) {
            errors.add('Row ${rowIndex + 1}: $e');
          }
        }
        
        print('DEBUG: Processed batch $startIndex-$endIndex, orders so far: ${orders.length}');
        
        // Allow event loop to process to prevent freezing
        await Future.delayed(const Duration(milliseconds: 10));
      }

      return ExcelImportResult(
        success: true,
        importedOrders: orders,
        errors: errors.isNotEmpty ? errors : null,
        totalRows: sheet.rows.length - 1, // Exclude header
        successfulRows: orders.length,
      );

    } catch (e) {
      return ExcelImportResult(
        success: false,
        errorMessage: 'Failed to process Excel file: $e',
        importedOrders: [],
      );
    }
  }

  // Helper method to check if a row is empty
  static bool _isEmptyRow(List<excel.Data?> row) {
    return row.every((cell) => 
        cell == null || 
        cell.value == null || 
        cell.value.toString().trim().isEmpty
    );
  }

  // CSV parsing helper methods
  static List<String> _parseCSVLine(String line) {
    final List<String> result = [];
    bool inQuotes = false;
    String currentField = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(currentField.trim());
        currentField = '';
      } else {
        currentField += char;
      }
    }
    
    result.add(currentField.trim());
    return result;
  }

  static Order? _parseOrderFromCSVRow({
    required List<String> row,
    required Map<String, int> columnIndexes,
    required int rowNumber,
    required String defaultCompanyId,
    required String defaultDriverId,
    required String adminUserId,
  }) {
    try {
      // Helper function to get cell value
      String? getCellValue(String fieldName) {
        final index = columnIndexes[fieldName];
        if (index == null || index >= row.length) return null;
        return row[index].trim();
      }

      // Parse fields (all optional, use defaults for missing values)
      final orderNumber = getCellValue('orderNumber') ?? 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
      final customerName = getCellValue('customerName') ?? '';
      final customerAddress = getCellValue('customerAddress') ?? '';
      final costStr = getCellValue('cost') ?? '0';

      // Parse cost (default to 0 if invalid)
      final cost = double.tryParse(costStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

      // Parse date
      DateTime orderDate;
      final dateStr = getCellValue('date');
      if (dateStr != null && dateStr.isNotEmpty) {
        try {
          orderDate = _parseDate(dateStr);
        } catch (e) {
          throw Exception('Invalid date format: $dateStr');
        }
      } else {
        orderDate = DateTime.now();
      }

      // Parse cash arrival date (optional)
      DateTime? cashArrivalDate;
      final cashDateStr = getCellValue('cashArrivalDate');
      if (cashDateStr != null && cashDateStr.isNotEmpty) {
        try {
          cashArrivalDate = _parseDate(cashDateStr);
        } catch (e) {
          // Ignore invalid cash arrival dates
        }
      }

      // Parse status
      OrderState status = OrderState.received;
      final statusStr = getCellValue('status');
      if (statusStr != null && statusStr.isNotEmpty) {
        status = _statusMapping[statusStr] ?? OrderState.received;
      }

      // Get optional fields
      final customerNumber = getCellValue('customerNumber');
      final products = getCellValue('products');

      return Order(
        id: '',
        companyId: defaultCompanyId,
        driverId: defaultDriverId,
        customerName: customerName,
        customerNumber: customerNumber,
        customerAddress: customerAddress,
        products: products,
        date: orderDate,
        cost: cost,
        orderNumber: orderNumber,
        state: status,
        cashArrivalDate: cashArrivalDate,
        createdBy: adminUserId,
        createdAt: DateTime.now(),
      );

    } catch (e) {
      throw Exception('Failed to parse row: $e');
    }
  }

  static Order? _parseOrderFromRow({
    required List<excel.Data?> row,
    required Map<String, int> columnIndexes,
    required int rowNumber,
    required String defaultCompanyId,
    required String defaultDriverId,
    required String adminUserId,
  }) {
    try {
      // Helper function to get cell value
      String? getCellValue(String fieldName) {
        final index = columnIndexes[fieldName];
        if (index == null || index >= row.length) return null;
        final cell = row[index];
        return cell?.value?.toString().trim();
      }

      // Parse required fields
      final orderNumber = getCellValue('orderNumber');
      final customerName = getCellValue('customerName');
      final customerAddress = getCellValue('customerAddress');
      final costStr = getCellValue('cost');

      if (orderNumber == null || orderNumber.isEmpty ||
          customerName == null || customerName.isEmpty ||
          customerAddress == null || customerAddress.isEmpty ||
          costStr == null || costStr.isEmpty) {
        throw Exception('Missing required fields');
      }

      // Parse cost
      final cost = double.tryParse(costStr.replaceAll(RegExp(r'[^\d.]'), ''));
      if (cost == null) {
        throw Exception('Invalid cost value: $costStr');
      }

      // Parse date
      DateTime orderDate;
      final dateStr = getCellValue('date');
      if (dateStr != null && dateStr.isNotEmpty) {
        try {
          // Try multiple date formats
          orderDate = _parseDate(dateStr);
        } catch (e) {
          throw Exception('Invalid date format: $dateStr');
        }
      } else {
        orderDate = DateTime.now(); // Default to today
      }

      // Parse cash arrival date (optional)
      DateTime? cashArrivalDate;
      final cashDateStr = getCellValue('cashArrivalDate');
      if (cashDateStr != null && cashDateStr.isNotEmpty) {
        try {
          cashArrivalDate = _parseDate(cashDateStr);
        } catch (e) {
          // Ignore invalid cash arrival dates
        }
      }

      // Parse status
      OrderState status = OrderState.received; // Default
      final statusStr = getCellValue('status');
      if (statusStr != null && statusStr.isNotEmpty) {
        status = _statusMapping[statusStr] ?? OrderState.received;
      }

      // Get optional fields
      final customerNumber = getCellValue('customerNumber');
      final products = getCellValue('products');

      return Order(
        id: '', // Will be generated by Firestore
        companyId: defaultCompanyId,
        driverId: defaultDriverId,
        customerName: customerName,
        customerNumber: customerNumber,
        customerAddress: customerAddress,
        products: products,
        date: orderDate,
        cost: cost,
        orderNumber: orderNumber,
        state: status,
        cashArrivalDate: cashArrivalDate,
        createdBy: adminUserId,
        createdAt: DateTime.now(),
      );

    } catch (e) {
      throw Exception('Failed to parse row: $e');
    }
  }

  static DateTime _parseDate(String dateStr) {
    // Remove any extra whitespace
    dateStr = dateStr.trim();
    
    // Try different date formats
    final formats = [
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
      'dd-MM-yyyy',
      'MM-dd-yyyy',
      'dd.MM.yyyy',
      'MM.dd.yyyy',
    ];

    for (final format in formats) {
      try {
        final formatter = DateFormat(format);
        return formatter.parse(dateStr);
      } catch (e) {
        // Continue to next format
      }
    }

    // If all formats fail, try parsing as Excel date number
    try {
      final excelDateNumber = double.parse(dateStr);
      // Excel date starts from 1900-01-01, but has a bug where 1900 is treated as leap year
      final excelEpoch = DateTime(1899, 12, 30);
      return excelEpoch.add(Duration(days: excelDateNumber.toInt()));
    } catch (e) {
      throw Exception('Unable to parse date: $dateStr');
    }
  }
}

class ExcelImportResult {
  final bool success;
  final String? errorMessage;
  final List<Order> importedOrders;
  final List<String>? errors;
  final int? totalRows;
  final int? successfulRows;

  const ExcelImportResult({
    required this.success,
    this.errorMessage,
    required this.importedOrders,
    this.errors,
    this.totalRows,
    this.successfulRows,
  });

  String get summaryMessage {
    if (!success) return errorMessage ?? 'Import failed';
    
    final successCount = successfulRows ?? importedOrders.length;
    final totalCount = totalRows ?? importedOrders.length;
    
    if (errors != null && errors!.isNotEmpty) {
      return 'Imported $successCount of $totalCount orders (${errors!.length} errors)';
    } else {
      return 'Successfully imported $successCount orders';
    }
  }
}
