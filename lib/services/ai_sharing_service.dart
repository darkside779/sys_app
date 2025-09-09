import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import '../models/ai_response_models.dart';
import 'ai_data_export_service.dart';
import 'ai_service.dart';

class AISharingService {
  static final AISharingService _instance = AISharingService._internal();
  static AISharingService get instance => _instance;
  
  AISharingService._internal();

  /// Share dashboard as link with embedded data
  Future<bool> shareAsLink({
    required Map<String, dynamic> dashboardData,
    required bool isArabic,
    String? customMessage,
  }) async {
    try {
      // Generate shareable link with encoded data
      final linkData = {
        'type': 'dashboard',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'language': isArabic ? 'ar' : 'en',
        'summary': await _generateShareSummary(dashboardData, isArabic),
        'data': _compressData(dashboardData),
      };
      
      final encodedData = base64Encode(utf8.encode(jsonEncode(linkData)));
      final shareableLink = 'https://yourdomain.com/shared-dashboard/$encodedData';
      
      final message = customMessage ?? (isArabic 
        ? 'شاهد لوحة معلومات الذكاء الاصطناعي'
        : 'Check out this AI Dashboard');
      
      await Share.share(
        '$message\n\n$shareableLink',
        subject: isArabic ? 'لوحة معلومات الذكاء الاصطناعي' : 'AI Dashboard Report',
      );
      
      return true;
    } catch (e) {
      debugPrint('Error sharing as link: $e');
      return false;
    }
  }

  /// Share dashboard via email with attachment
  Future<bool> shareViaEmail({
    required Map<String, dynamic> dashboardData,
    required bool isArabic,
    List<String>? recipients,
    String? subject,
    String? customMessage,
    String exportFormat = 'pdf',
  }) async {
    try {
      // Export data first
      String? filePath;
      
      switch (exportFormat) {
        case 'pdf':
          filePath = await AIDataExportService.instance.exportToPDF(
            dashboardData: dashboardData,
            isArabic: isArabic,
          );
          break;
        case 'excel':
          filePath = await AIDataExportService.instance.exportToExcel(
            dashboardData: dashboardData,
            isArabic: isArabic,
          );
          break;
        case 'json':
          filePath = await AIDataExportService.instance.exportToJSON(
            dashboardData: dashboardData,
            isArabic: isArabic,
          );
          break;
      }
      
      if (filePath == null) return false;
      
      final emailSubject = subject ?? (isArabic 
        ? 'تقرير لوحة معلومات الذكاء الاصطناعي'
        : 'AI Dashboard Report');
      
      final emailBody = customMessage ?? await _generateEmailBody(dashboardData, isArabic);
      
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: emailSubject,
        text: emailBody,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error sharing via email: $e');
      return false;
    }
  }

  /// Capture and share screenshot of dashboard
  Future<bool> shareScreenshot({
    required GlobalKey widgetKey,
    required bool isArabic,
    String? customMessage,
  }) async {
    try {
      // Capture widget as image
      final boundary = widgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return false;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;
      
      // Save screenshot to temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'dashboard_screenshot_$timestamp.png';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      final message = customMessage ?? (isArabic 
        ? 'لقطة شاشة من لوحة معلومات الذكاء الاصطناعي'
        : 'AI Dashboard Screenshot');
      
      await Share.shareXFiles(
        [XFile(filePath)],
        text: message,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error sharing screenshot: $e');
      return false;
    }
  }

  /// Share specific chart or widget
  Future<bool> shareChart({
    required String chartType,
    required Map<String, dynamic> chartData,
    required GlobalKey? chartKey,
    required bool isArabic,
    String? title,
    String shareMethod = 'image',
  }) async {
    try {
      switch (shareMethod) {
        case 'image':
          return await _shareChartAsImage(chartKey, chartType, isArabic, title);
        case 'data':
          return await _shareChartAsData(chartType, chartData, isArabic, title);
        case 'link':
          return await _shareChartAsLink(chartType, chartData, isArabic, title);
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Error sharing chart: $e');
      return false;
    }
  }

  /// Generate shareable insight cards
  Future<bool> shareInsights({
    required List<String> insights,
    required bool isArabic,
    String? customMessage,
  }) async {
    try {
      final insightText = insights.map((insight) => '• $insight').join('\n');
      
      final message = customMessage ?? (isArabic 
        ? 'رؤى من الذكاء الاصطناعي:\n\n$insightText'
        : 'AI Insights:\n\n$insightText');
      
      await Share.share(message);
      return true;
    } catch (e) {
      debugPrint('Error sharing insights: $e');
      return false;
    }
  }

  /// Share performance report
  Future<bool> sharePerformanceReport({
    required Map<String, dynamic> performanceData,
    required bool isArabic,
    String? customMessage,
    String format = 'summary',
  }) async {
    try {
      String reportContent;
      
      switch (format) {
        case 'summary':
          reportContent = await _generatePerformanceSummary(performanceData, isArabic);
          break;
        case 'detailed':
          reportContent = await _generateDetailedPerformanceReport(performanceData, isArabic);
          break;
        default:
          reportContent = await _generatePerformanceSummary(performanceData, isArabic);
      }
      
      final message = customMessage ?? (isArabic 
        ? 'تقرير الأداء:\n\n$reportContent'
        : 'Performance Report:\n\n$reportContent');
      
      await Share.share(message);
      return true;
    } catch (e) {
      debugPrint('Error sharing performance report: $e');
      return false;
    }
  }

  /// Share AI recommendations
  Future<bool> shareRecommendations({
    required List<String> recommendations,
    required bool isArabic,
    String? customMessage,
  }) async {
    try {
      final recText = recommendations.map((rec) => '• $rec').join('\n');
      
      final message = customMessage ?? (isArabic 
        ? 'توصيات الذكاء الاصطناعي:\n\n$recText'
        : 'AI Recommendations:\n\n$recText');
      
      await Share.share(message);
      return true;
    } catch (e) {
      debugPrint('Error sharing recommendations: $e');
      return false;
    }
  }

  /// Copy data to clipboard
  Future<bool> copyToClipboard({
    required String content,
    required bool isArabic,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: content));
      return true;
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      return false;
    }
  }

  /// Get available sharing methods
  List<Map<String, dynamic>> getAvailableSharingMethods(bool isArabic) {
    return [
      {
        'id': 'link',
        'name': isArabic ? 'رابط قابل للمشاركة' : 'Shareable Link',
        'description': isArabic ? 'إنشاء رابط للمشاركة' : 'Generate shareable link',
        'icon': Icons.link,
      },
      {
        'id': 'email',
        'name': isArabic ? 'البريد الإلكتروني' : 'Email',
        'description': isArabic ? 'إرسال عبر البريد الإلكتروني' : 'Send via email',
        'icon': Icons.email,
      },
      {
        'id': 'screenshot',
        'name': isArabic ? 'لقطة شاشة' : 'Screenshot',
        'description': isArabic ? 'مشاركة لقطة شاشة' : 'Share screenshot',
        'icon': Icons.camera_alt,
      },
      {
        'id': 'social',
        'name': isArabic ? 'وسائل التواصل الاجتماعي' : 'Social Media',
        'description': isArabic ? 'مشاركة على وسائل التواصل' : 'Share on social media',
        'icon': Icons.share,
      },
      {
        'id': 'clipboard',
        'name': isArabic ? 'نسخ للحافظة' : 'Copy to Clipboard',
        'description': isArabic ? 'نسخ البيانات للحافظة' : 'Copy data to clipboard',
        'icon': Icons.copy,
      },
    ];
  }

  // Private helper methods

  Future<String> _generateShareSummary(Map<String, dynamic> data, bool isArabic) async {
    final orders = data['orders'] as List<Map<String, dynamic>>? ?? [];
    final drivers = data['drivers'] as List<Map<String, dynamic>>? ?? [];
    final companies = data['companies'] as List<Map<String, dynamic>>? ?? [];
    
    if (isArabic) {
      return 'لوحة المعلومات تظهر ${orders.length} طلب، ${drivers.where((d) => d['isActive'] == true).length} سائق نشط، و${companies.where((c) => c['isActive'] == true).length} شركة نشطة.';
    } else {
      return 'Dashboard shows ${orders.length} orders, ${drivers.where((d) => d['isActive'] == true).length} active drivers, and ${companies.where((c) => c['isActive'] == true).length} active companies.';
    }
  }

  Map<String, dynamic> _compressData(Map<String, dynamic> data) {
    // Compress data by keeping only essential fields
    return {
      'orderCount': (data['orders'] as List?)?.length ?? 0,
      'driverCount': (data['drivers'] as List?)?.length ?? 0,
      'companyCount': (data['companies'] as List?)?.length ?? 0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<String> _generateEmailBody(Map<String, dynamic> data, bool isArabic) async {
    final summary = await _generateShareSummary(data, isArabic);
    
    if (isArabic) {
      return '''
      السلام عليكم،

      أرفق معكم تقرير لوحة معلومات الذكاء الاصطناعي.

      ملخص البيانات:
      $summary

      تم إنشاء هذا التقرير في: ${DateTime.now().toString()}

      مع أطيب التحيات
      ''';
    } else {
      return '''
      Hello,

      Please find attached the AI Dashboard report.

      Data Summary:
      $summary

      Generated on: ${DateTime.now().toString()}

      Best regards
      ''';
    }
  }

  Future<bool> _shareChartAsImage(GlobalKey? chartKey, String chartType, bool isArabic, String? title) async {
    if (chartKey?.currentContext == null) return false;
    
    try {
      final boundary = chartKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return false;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;
      
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'chart_${chartType}_$timestamp.png';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      final message = title ?? (isArabic ? 'مخطط من الذكاء الاصطناعي' : 'AI Chart');
      
      await Share.shareXFiles([XFile(filePath)], text: message);
      return true;
    } catch (e) {
      debugPrint('Error sharing chart as image: $e');
      return false;
    }
  }

  Future<bool> _shareChartAsData(String chartType, Map<String, dynamic> chartData, bool isArabic, String? title) async {
    try {
      final filePath = await AIDataExportService.instance.exportChartData(
        chartType: chartType,
        chartData: chartData,
        isArabic: isArabic,
        title: title,
        format: 'json',
      );
      
      if (filePath == null) return false;
      
      await Share.shareXFiles([XFile(filePath)]);
      return true;
    } catch (e) {
      debugPrint('Error sharing chart as data: $e');
      return false;
    }
  }

  Future<bool> _shareChartAsLink(String chartType, Map<String, dynamic> chartData, bool isArabic, String? title) async {
    try {
      final linkData = {
        'type': 'chart',
        'chartType': chartType,
        'title': title ?? chartType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'language': isArabic ? 'ar' : 'en',
        'data': chartData,
      };
      
      final encodedData = base64Encode(utf8.encode(jsonEncode(linkData)));
      final shareableLink = 'https://yourdomain.com/shared-chart/$encodedData';
      
      final message = title ?? (isArabic ? 'مخطط من الذكاء الاصطناعي' : 'AI Chart');
      
      await Share.share('$message\n\n$shareableLink');
      return true;
    } catch (e) {
      debugPrint('Error sharing chart as link: $e');
      return false;
    }
  }

  Future<String> _generatePerformanceSummary(Map<String, dynamic> data, bool isArabic) async {
    final orders = data['orders'] as List<Map<String, dynamic>>? ?? [];
    final completedOrders = orders.where((o) => o['status'] == 'completed').length;
    final successRate = orders.isEmpty ? 0.0 : (completedOrders / orders.length) * 100;
    
    if (isArabic) {
      return '''
      • إجمالي الطلبات: ${orders.length}
      • الطلبات المكتملة: $completedOrders
      • معدل النجاح: ${successRate.toStringAsFixed(1)}%
      • تاريخ التقرير: ${DateTime.now().toString().split('.')[0]}
      ''';
    } else {
      return '''
      • Total Orders: ${orders.length}
      • Completed Orders: $completedOrders
      • Success Rate: ${successRate.toStringAsFixed(1)}%
      • Report Date: ${DateTime.now().toString().split('.')[0]}
      ''';
    }
  }

  Future<String> _generateDetailedPerformanceReport(Map<String, dynamic> data, bool isArabic) async {
    final summary = await _generatePerformanceSummary(data, isArabic);
    final response = AIService.instance.generateSystemInsights(data, isArabic);
    final insights = response.type == AIResponseType.systemInsights ? 
      (response.data as SystemInsights).recommendations : <String>[];
    
    if (isArabic) {
      return '''
      تقرير الأداء المفصل
      ==================
      
      $summary
      
      الرؤى والتوصيات:
      ${insights.take(5).map((i) => '• $i').join('\n')}
      
      تم إنشاء التقرير بواسطة الذكاء الاصطناعي
      ''';
    } else {
      return '''
      Detailed Performance Report
      ==========================
      
      $summary
      
      Insights & Recommendations:
      ${insights.take(5).map((i) => '• $i').join('\n')}
      
      Report generated by AI
      ''';
    }
  }
}
