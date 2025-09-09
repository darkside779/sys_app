// ignore_for_file: avoid_web_libraries_in_flutter, unnecessary_import, deprecated_member_use, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../models/ai_response_models.dart';
import 'ai_service.dart';

class AIDataExportService {
  static final AIDataExportService _instance = AIDataExportService._internal();
  static AIDataExportService get instance => _instance;
  
  AIDataExportService._internal();

  /// Export dashboard data as PDF report
  Future<String?> exportToPDF({
    required Map<String, dynamic> dashboardData,
    required bool isArabic,
    String? customTitle,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ai_dashboard_report_$timestamp.pdf';

      // Generate PDF content
      final pdfContent = await _generatePDFContent(dashboardData, isArabic, customTitle);
      
      if (kIsWeb) {
        // Web platform - trigger download
        _downloadFileWeb(pdfContent, fileName, 'application/pdf');
        return fileName;
      } else {
        // Mobile platform - save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pdfContent);
        return filePath;
      }
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      return null;
    }
  }

  /// Export dashboard data as Excel spreadsheet
  Future<String?> exportToExcel({
    required Map<String, dynamic> dashboardData,
    required bool isArabic,
    String? customTitle,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ai_dashboard_data_$timestamp.xlsx';

      // Generate Excel content
      final excelContent = await _generateExcelContent(dashboardData, isArabic);
      
      if (kIsWeb) {
        // Web platform - trigger download
        _downloadFileWeb(excelContent, fileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        return fileName;
      } else {
        // Mobile platform - save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(excelContent);
        return filePath;
      }
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }

  /// Export dashboard data as JSON
  Future<String?> exportToJSON({
    required Map<String, dynamic> dashboardData,
    required bool isArabic,
    String? customTitle,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ai_dashboard_data_$timestamp.json';

      // Generate enhanced JSON with metadata
      final exportData = {
        'metadata': {
          'title': customTitle ?? (isArabic ? 'تقرير لوحة المعلومات' : 'Dashboard Report'),
          'exportDate': DateTime.now().toIso8601String(),
          'language': isArabic ? 'ar' : 'en',
          'version': '1.0',
        },
        'summary': await _generateDataSummary(dashboardData, isArabic),
        'data': dashboardData,
        'insights': await _generateAIInsights(dashboardData, isArabic),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      if (kIsWeb) {
        // Web platform - trigger download
        final bytes = utf8.encode(jsonString);
        _downloadFileWeb(bytes, fileName, 'application/json');
        return fileName;
      } else {
        // Mobile platform - save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsString(jsonString);
        return filePath;
      }
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      return null;
    }
  }

  /// Export specific chart data
  Future<String?> exportChartData({
    required String chartType,
    required Map<String, dynamic> chartData,
    required bool isArabic,
    String? title,
    String format = 'json',
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'chart_${chartType}_$timestamp.$format';
      final filePath = '${directory.path}/$fileName';

      switch (format.toLowerCase()) {
        case 'json':
          final exportData = {
            'chartType': chartType,
            'title': title ?? chartType,
            'exportDate': DateTime.now().toIso8601String(),
            'language': isArabic ? 'ar' : 'en',
            'data': chartData,
          };
          final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
          await File(filePath).writeAsString(jsonString);
          break;
          
        case 'csv':
          final csvContent = _convertToCSV(chartData, isArabic);
          await File(filePath).writeAsString(csvContent);
          break;
          
        default:
          throw UnsupportedError('Format $format not supported');
      }
      
      return filePath;
    } catch (e) {
      debugPrint('Error exporting chart data: $e');
      return null;
    }
  }

  /// Generate comprehensive analytics report
  Future<String?> generateAnalyticsReport({
    required Map<String, dynamic> dashboardData,
    required bool isArabic,
    String? dateRange,
    List<String>? includeCharts,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'analytics_report_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      // Generate AI insights and recommendations
      final response = AIService.instance.generateSystemInsights(dashboardData, isArabic);
      final insights = response.type == AIResponseType.systemInsights ? 
        (response.data as SystemInsights).recommendations : <String>[];
      final recommendations = await _generateRecommendations(dashboardData, isArabic);
      
      final reportData = {
        'metadata': {
          'title': isArabic ? 'تقرير التحليلات الشامل' : 'Comprehensive Analytics Report',
          'generatedDate': DateTime.now().toIso8601String(),
          'dateRange': dateRange ?? 'All Time',
          'language': isArabic ? 'ar' : 'en',
          'version': '1.0',
        },
        'executiveSummary': await _generateExecutiveSummary(dashboardData, isArabic),
        'keyMetrics': _extractKeyMetrics(dashboardData, isArabic),
        'trends': await _analyzeTrends(dashboardData, isArabic),
        'insights': insights,
        'recommendations': recommendations,
        'charts': includeCharts ?? ['orders_trend', 'driver_performance', 'status_distribution'],
        'rawData': dashboardData,
        'appendix': {
          'methodology': isArabic ? 'تم إنتاج هذا التقرير باستخدام الذكاء الاصطناعي' : 'This report was generated using AI analysis',
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(reportData);
      await File(filePath).writeAsString(jsonString);
      
      return filePath;
    } catch (e) {
      debugPrint('Error generating analytics report: $e');
      return null;
    }
  }

  /// Get available export formats
  List<Map<String, String>> getAvailableFormats(bool isArabic) {
    return [
      {
        'id': 'pdf',
        'name': isArabic ? 'تقرير PDF' : 'PDF Report',
        'description': isArabic ? 'تقرير منسق بصيغة PDF' : 'Formatted PDF report',
        'icon': 'picture_as_pdf',
      },
      {
        'id': 'excel',
        'name': isArabic ? 'جدول بيانات Excel' : 'Excel Spreadsheet',
        'description': isArabic ? 'بيانات قابلة للتحرير' : 'Editable data spreadsheet',
        'icon': 'table_chart',
      },
      {
        'id': 'json',
        'name': isArabic ? 'بيانات JSON' : 'JSON Data',
        'description': isArabic ? 'بيانات منظمة للمطورين' : 'Structured data for developers',
        'icon': 'code',
      },
      {
        'id': 'csv',
        'name': isArabic ? 'ملف CSV' : 'CSV File',
        'description': isArabic ? 'بيانات مفصولة بفواصل' : 'Comma-separated values',
        'icon': 'description',
      },
    ];
  }

  // Private helper methods

  Future<Uint8List> _generatePDFContent(
    Map<String, dynamic> data,
    bool isArabic,
    String? title,
  ) async {
    final pdf = pw.Document();
    final reportTitle = title ?? (isArabic ? 'تقرير لوحة المعلومات' : 'Dashboard Report');
    final dataSummary = await _generateDataSummary(data, isArabic);
    final keyMetrics = _extractKeyMetrics(data, isArabic);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Header(
                level: 0,
                child: pw.Text(
                  reportTitle,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Generated date
              pw.Text(
                '${isArabic ? 'تاريخ التوليد: ' : 'Generated: '}${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),
              
              // Key Metrics Section
              pw.Header(
                level: 1,
                child: pw.Text(
                  isArabic ? 'المؤشرات الرئيسية' : 'Key Metrics',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Metrics Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(isArabic ? 'المؤشر' : 'Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(isArabic ? 'القيمة' : 'Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(isArabic ? 'إجمالي الطلبات' : 'Total Orders')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${keyMetrics['totalOrders']}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(isArabic ? 'السائقون النشطون' : 'Active Drivers')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${keyMetrics['activeDrivers']}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(isArabic ? 'معدل الإكمال' : 'Completion Rate')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${keyMetrics['completionRate'].toStringAsFixed(1)}%')),
                  ]),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Data Summary Section
              pw.Header(
                level: 1,
                child: pw.Text(
                  isArabic ? 'ملخص البيانات' : 'Data Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(dataSummary, style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<Uint8List> _generateExcelContent(
    Map<String, dynamic> data,
    bool isArabic,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Dashboard Report'];
    
    final keyMetrics = _extractKeyMetrics(data, isArabic);
    final dataSummary = await _generateDataSummary(data, isArabic);
    
    // Add headers
    sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(isArabic ? 'تقرير لوحة المعلومات' : 'Dashboard Report');
    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue('${isArabic ? 'تاريخ التوليد: ' : 'Generated: '}${DateTime.now().toString().split('.')[0]}');
    
    // Add metrics
    int row = 4;
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(isArabic ? 'المؤشرات الرئيسية' : 'Key Metrics');
    row += 2;
    
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(isArabic ? 'المؤشر' : 'Metric');
    sheet.cell(CellIndex.indexByString("B$row")).value = TextCellValue(isArabic ? 'القيمة' : 'Value');
    row++;
    
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(isArabic ? 'إجمالي الطلبات' : 'Total Orders');
    sheet.cell(CellIndex.indexByString("B$row")).value = IntCellValue(keyMetrics['totalOrders']);
    row++;
    
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(isArabic ? 'السائقون النشطون' : 'Active Drivers');
    sheet.cell(CellIndex.indexByString("B$row")).value = IntCellValue(keyMetrics['activeDrivers']);
    row++;
    
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(isArabic ? 'الشركات النشطة' : 'Active Companies');
    sheet.cell(CellIndex.indexByString("B$row")).value = IntCellValue(keyMetrics['activeCompanies']);
    row++;
    
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(isArabic ? 'معدل الإكمال' : 'Completion Rate');
    sheet.cell(CellIndex.indexByString("B$row")).value = TextCellValue('${keyMetrics['completionRate'].toStringAsFixed(1)}%');
    row += 2;
    
    // Add data summary
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(isArabic ? 'ملخص البيانات' : 'Data Summary');
    row++;
    sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(dataSummary);
    
    // Extract orders, drivers data for detailed sheets
    final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
    final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
    
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    // Add Orders sheet
    if (orders.isNotEmpty) {
      final ordersSheet = excel['Orders'];
      ordersSheet.cell(CellIndex.indexByString("A1")).value = TextCellValue('Order ID');
      ordersSheet.cell(CellIndex.indexByString("B1")).value = TextCellValue('Status');
      ordersSheet.cell(CellIndex.indexByString("C1")).value = TextCellValue('Created At');
      ordersSheet.cell(CellIndex.indexByString("D1")).value = TextCellValue('Driver');
      
      for (int i = 0; i < orders.length; i++) {
        final order = orders[i];
        final rowIndex = i + 2;
        ordersSheet.cell(CellIndex.indexByString("A$rowIndex")).value = TextCellValue(order['id']?.toString() ?? 'N/A');
        ordersSheet.cell(CellIndex.indexByString("B$rowIndex")).value = TextCellValue(order['status']?.toString() ?? 'N/A');
        ordersSheet.cell(CellIndex.indexByString("C$rowIndex")).value = TextCellValue(order['createdAt']?.toString() ?? 'N/A');
        ordersSheet.cell(CellIndex.indexByString("D$rowIndex")).value = TextCellValue(order['driverName']?.toString() ?? 'N/A');
      }
    }
    
    // Add Drivers sheet
    if (drivers.isNotEmpty) {
      final driversSheet = excel['Drivers'];
      driversSheet.cell(CellIndex.indexByString("A1")).value = TextCellValue('Driver Name');
      driversSheet.cell(CellIndex.indexByString("B1")).value = TextCellValue('Active');
      driversSheet.cell(CellIndex.indexByString("C1")).value = TextCellValue('Rating');
      driversSheet.cell(CellIndex.indexByString("D1")).value = TextCellValue('Completed Deliveries');
      
      for (int i = 0; i < drivers.length; i++) {
        final driver = drivers[i];
        final rowIndex = i + 2;
        driversSheet.cell(CellIndex.indexByString("A$rowIndex")).value = TextCellValue(driver['name']?.toString() ?? 'N/A');
        driversSheet.cell(CellIndex.indexByString("B$rowIndex")).value = TextCellValue(driver['isActive'] == true ? 'Yes' : 'No');
        driversSheet.cell(CellIndex.indexByString("C$rowIndex")).value = TextCellValue(driver['rating']?.toString() ?? 'N/A');
        driversSheet.cell(CellIndex.indexByString("D$rowIndex")).value = TextCellValue(driver['completedDeliveries']?.toString() ?? '0');
      }
    }
    
    return Uint8List.fromList(excel.save() ?? []);
  }

  String _convertToCSV(Map<String, dynamic> data, bool isArabic) {
    final buffer = StringBuffer();
    
    // Add headers
    buffer.writeln(isArabic ? 'النوع,القيمة,التاريخ' : 'Type,Value,Date');
    
    // Add data rows
    data.forEach((key, value) {
      if (value is List) {
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            final type = item['type'] ?? key;
            final val = item['value'] ?? item['count'] ?? item['amount'] ?? '';
            final date = item['date'] ?? item['createdAt'] ?? DateTime.now().toIso8601String();
            buffer.writeln('$type,$val,$date');
          }
        }
      }
    });
    
    return buffer.toString();
  }

  Future<String> _generateDataSummary(Map<String, dynamic> data, bool isArabic) async {
    final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
    final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
    final companiesData = data['companies'] as Map<String, dynamic>? ?? {};
    
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final companies = (companiesData['companies'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    if (isArabic) {
      return '''
      • إجمالي الطلبات: ${orders.length}
      • السائقون النشطون: ${drivers.where((d) => d['isActive'] == true).length}
      • الشركات النشطة: ${companies.where((c) => c['isActive'] == true).length}
      • معدل إكمال الطلبات: ${orders.isEmpty ? '0' : ((orders.where((o) => o['status'] == 'completed').length / orders.length) * 100).toStringAsFixed(1)}%
      ''';
    } else {
      return '''
      • Total Orders: ${orders.length}
      • Active Drivers: ${drivers.where((d) => d['isActive'] == true).length}
      • Active Companies: ${companies.where((c) => c['isActive'] == true).length}
      • Order Completion Rate: ${orders.isEmpty ? '0' : ((orders.where((o) => o['status'] == 'completed').length / orders.length) * 100).toStringAsFixed(1)}%
      ''';
    }
  }

  Future<List<String>> _generateAIInsights(Map<String, dynamic> data, bool isArabic) async {
    try {
      final response = AIService.instance.generateSystemInsights(data, isArabic);
      if (response.type == AIResponseType.systemInsights) {
        final insights = response.data as SystemInsights;
        return insights.recommendations;
      }
      return isArabic ? 
        ['لا توجد رؤى متاحة حالياً'] : 
        ['No insights available at the moment'];
    } catch (e) {
      return isArabic ? 
        ['لا توجد رؤى متاحة حالياً'] : 
        ['No insights available at the moment'];
    }
  }

  Future<String> _generateExecutiveSummary(Map<String, dynamic> data, bool isArabic) async {
    final summary = await _generateDataSummary(data, isArabic);
    final insights = await _generateAIInsights(data, isArabic);
    
    if (isArabic) {
      return '''
      هذا التقرير يقدم نظرة شاملة على أداء النظام:
      
      $summary
      
      الرؤى الرئيسية:
      ${insights.take(3).map((i) => '• $i').join('\n')}
      ''';
    } else {
      return '''
      This report provides a comprehensive overview of system performance:
      
      $summary
      
      Key Insights:
      ${insights.take(3).map((i) => '• $i').join('\n')}
      ''';
    }
  }

  Map<String, dynamic> _extractKeyMetrics(Map<String, dynamic> data, bool isArabic) {
    final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
    final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
    final companiesData = data['companies'] as Map<String, dynamic>? ?? {};
    
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final companies = (companiesData['companies'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    return {
      'totalOrders': orders.length,
      'activeDrivers': drivers.where((d) => d['isActive'] == true).length,
      'activeCompanies': companies.where((c) => c['isActive'] == true).length,
      'completionRate': orders.isEmpty ? 0.0 : (orders.where((o) => o['status'] == 'completed').length / orders.length) * 100,
      'averageRating': drivers.isEmpty ? 0.0 : drivers.map((d) => d['rating'] ?? 0.0).reduce((a, b) => a + b) / drivers.length,
    };
  }

  Future<List<String>> _analyzeTrends(Map<String, dynamic> data, bool isArabic) async {
    // Simplified trend analysis
    final trends = <String>[];
    
    final ordersData = data['orders'] as Map<String, dynamic>? ?? {};
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    if (orders.isNotEmpty) {
      final recentOrders = orders.where((o) {
        final date = DateTime.tryParse(o['createdAt'] ?? '');
        return date != null && date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
      }).length;
      
      if (recentOrders > orders.length * 0.3) {
        trends.add(isArabic ? 'ازدياد في الطلبات الأسبوع الماضي' : 'Increasing orders in the past week');
      }
    }
    
    return trends;
  }

  /// Download file for web platform
  void _downloadFileWeb(List<int> bytes, String fileName, String mimeType) {
    if (kIsWeb) {
      final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<List<String>> _generateRecommendations(Map<String, dynamic> data, bool isArabic) async {
    final recommendations = <String>[];
    
    final driversData = data['drivers'] as Map<String, dynamic>? ?? {};
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final inactiveDrivers = drivers.where((d) => d['isActive'] != true).length;
    
    if (inactiveDrivers > drivers.length * 0.2) {
      recommendations.add(
        isArabic 
          ? 'يُنصح بالتواصل مع السائقين غير النشطين لتحسين الأداء'
          : 'Consider reaching out to inactive drivers to improve performance'
      );
    }
    
    return recommendations;
  }
}
