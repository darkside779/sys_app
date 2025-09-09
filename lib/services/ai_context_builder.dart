// ignore_for_file: avoid_print

import 'ai_data_service.dart';

class AIContextBuilder {
  static AIContextBuilder? _instance;
  static AIContextBuilder get instance => _instance ??= AIContextBuilder._internal();
  
  AIContextBuilder._internal();

  final AIDataService _dataService = AIDataService.instance;

  /// Build system context for AI assistant
  Future<String> buildSystemContext() async {
    try {
      final data = await _dataService.getAllDataForAI();
      
      return '''
You are an AI assistant for a delivery management system. You help analyze delivery data, provide insights, and answer questions about orders, drivers, and delivery companies.

CURRENT SYSTEM DATA:
${_formatSystemData(data)}

CAPABILITIES:
- Analyze order trends and performance metrics
- Compare delivery company performance
- Evaluate driver efficiency
- Identify patterns and anomalies
- Provide actionable recommendations
- Answer questions about delivery data
- Generate reports and summaries

RESPONSE GUIDELINES:
- Be concise and professional
- Use data to support your insights
- Provide specific numbers and percentages when available
- Suggest practical improvements
- Format responses clearly with bullet points or sections when appropriate
- If asked about specific data not available, explain what data you do have access to

LANGUAGE: Respond in English, but be prepared to handle Arabic queries about delivery addresses or names.
''';
    } catch (e) {
      print('Error building system context: $e');
      return _getBasicSystemContext();
    }
  }

  /// Format system data for AI context
  String _formatSystemData(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    
    // Overview
    if (data['summary']?['overview'] != null) {
      final overview = data['summary']['overview'];
      buffer.writeln('OVERVIEW:');
      buffer.writeln('- Total Orders: ${overview['total_orders']}');
      buffer.writeln('- Total Companies: ${overview['total_companies']}');
      buffer.writeln('- Total Drivers: ${overview['total_drivers']}');
      buffer.writeln('- Overall Completion Rate: ${overview['overall_completion_rate']}%');
      buffer.writeln('- Total Revenue: AED ${overview['total_revenue']}');
      buffer.writeln('');
    }

    // Orders Statistics
    if (data['orders'] != null) {
      final orders = data['orders'];
      buffer.writeln('ORDER STATISTICS:');
      buffer.writeln('- Completed: ${orders['completed_orders']}');
      buffer.writeln('- Pending: ${orders['pending_orders']}');
      buffer.writeln('- Out for Delivery: ${orders['out_for_delivery']}');
      buffer.writeln('- Not Returned: ${orders['not_returned']}');
      buffer.writeln('- Average Order Value: AED ${orders['average_cost']}');
      buffer.writeln('- Recent Orders (7 days): ${orders['recent_orders_count']}');
      buffer.writeln('');
    }

    // Performance Insights
    if (data['summary']?['performance'] != null) {
      final performance = data['summary']['performance'];
      buffer.writeln('PERFORMANCE INSIGHTS:');
      buffer.writeln('- Best Company: ${performance['best_performing_company']}');
      buffer.writeln('- Most Active Driver: ${performance['most_active_driver']}');
      buffer.writeln('- Recent Trend: ${performance['recent_trend']}');
      buffer.writeln('');
    }

    // Alerts
    if (data['summary']?['alerts'] != null && (data['summary']['alerts'] as List).isNotEmpty) {
      buffer.writeln('CURRENT ALERTS:');
      for (final alert in data['summary']['alerts'] as List) {
        buffer.writeln('- $alert');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Build context for specific query types
  Future<String> buildQueryContext(String queryType, {Map<String, dynamic>? filters}) async {
    try {
      switch (queryType.toLowerCase()) {
        case 'orders':
          return await _buildOrdersContext(filters);
        case 'drivers':
          return await _buildDriversContext(filters);
        case 'companies':
          return await _buildCompaniesContext(filters);
        case 'performance':
          return await _buildPerformanceContext(filters);
        case 'analytics':
          return await _buildAnalyticsContext(filters);
        default:
          return await buildSystemContext();
      }
    } catch (e) {
      print('Error building query context for $queryType: $e');
      return await buildSystemContext();
    }
  }

  /// Build orders-specific context
  Future<String> _buildOrdersContext(Map<String, dynamic>? filters) async {
    final data = await _dataService.getOrdersData();
    
    return '''
ORDERS DATA ANALYSIS:

Total Orders: ${data['total_orders']}
Status Breakdown:
- Received: ${data['pending_orders']}
- Out for Delivery: ${data['out_for_delivery']}
- Returned: ${data['completed_orders']}
- Not Returned: ${data['not_returned']}

Financial Summary:
- Total Value: AED ${data['total_cost']}
- Average Order Value: AED ${data['average_cost']}
- Completion Rate: ${data['completion_rate']}%

Recent Activity:
- Orders in last 7 days: ${data['recent_orders_count']}

You can answer questions about order trends, completion rates, financial performance, and specific order details.
''';
  }

  /// Build drivers-specific context
  Future<String> _buildDriversContext(Map<String, dynamic>? filters) async {
    final data = await _dataService.getDriversData();
    
    return '''
DRIVERS DATA ANALYSIS:

Total Drivers: ${data['total_drivers']}
Active Drivers: ${data['active_drivers']}

Driver Performance:
${_formatDriverStats(data['driver_stats'] as Map<String, dynamic>? ?? {})}

You can answer questions about driver performance, workload distribution, and efficiency metrics.
''';
  }

  /// Build companies-specific context
  Future<String> _buildCompaniesContext(Map<String, dynamic>? filters) async {
    final data = await _dataService.getCompaniesData();
    
    return '''
DELIVERY COMPANIES DATA ANALYSIS:

Total Companies: ${data['total_companies']}
Active Companies: ${data['active_companies']}

Company Performance:
${_formatCompanyStats(data['company_stats'] as Map<String, dynamic>? ?? {})}

You can answer questions about company performance comparisons, revenue analysis, and partnership insights.
''';
  }

  /// Build performance-specific context
  Future<String> _buildPerformanceContext(Map<String, dynamic>? filters) async {
    final allData = await _dataService.getAllDataForAI();
    
    return '''
PERFORMANCE ANALYSIS:

${_formatSystemData(allData)}

PERFORMANCE METRICS TO FOCUS ON:
- Completion rates by company and driver
- Order fulfillment times
- Revenue per company/driver
- Customer satisfaction indicators
- Operational efficiency metrics

You should provide comparative analysis and recommendations for improvement.
''';
  }

  /// Build analytics-specific context
  Future<String> _buildAnalyticsContext(Map<String, dynamic>? filters) async {
    final allData = await _dataService.getAllDataForAI();
    
    return '''
ANALYTICS DATA FOR DEEP INSIGHTS:

${_formatSystemData(allData)}

ANALYTICS CAPABILITIES:
- Trend analysis over time periods
- Comparative performance metrics
- Predictive insights based on historical data
- Anomaly detection in delivery patterns
- Cost optimization opportunities
- Resource allocation recommendations

Provide detailed analytical insights with supporting data and actionable recommendations.
''';
  }

  /// Format driver statistics
  String _formatDriverStats(Map<String, dynamic> driverStats) {
    final buffer = StringBuffer();
    
    final topDrivers = driverStats.entries
        .where((entry) => (entry.value['total_orders'] as int? ?? 0) > 0)
        .toList()
        ..sort((a, b) => (b.value['total_orders'] as int).compareTo(a.value['total_orders'] as int));

    for (int i = 0; i < 3 && i < topDrivers.length; i++) {
      final driver = topDrivers[i].value;
      buffer.writeln('- ${driver['name']}: ${driver['total_orders']} orders (${driver['completion_rate']}% completion rate)');
    }

    return buffer.toString();
  }

  /// Format company statistics
  String _formatCompanyStats(Map<String, dynamic> companyStats) {
    final buffer = StringBuffer();
    
    final topCompanies = companyStats.entries
        .where((entry) => (entry.value['total_orders'] as int? ?? 0) > 0)
        .toList()
        ..sort((a, b) => (b.value['completion_rate'] as int).compareTo(a.value['completion_rate'] as int));

    for (int i = 0; i < 3 && i < topCompanies.length; i++) {
      final company = topCompanies[i].value;
      buffer.writeln('- ${company['name']}: ${company['total_orders']} orders (${company['completion_rate']}% completion rate)');
    }

    return buffer.toString();
  }

  /// Get basic system context when data fetch fails
  String _getBasicSystemContext() {
    return '''
You are an AI assistant for a delivery management system. You help analyze delivery data and provide insights about orders, drivers, and delivery companies.

I can help you with:
- Analyzing order trends and performance
- Comparing delivery companies
- Evaluating driver efficiency
- Identifying patterns in delivery data
- Providing recommendations for improvement
- Answering questions about your delivery operations

Please ask me specific questions about your delivery data, and I'll provide insights based on the available information.
''';
  }

  /// Build context for natural language queries
  String buildNLQueryContext(String userQuery) {
    final queryLower = userQuery.toLowerCase();
    
    if (queryLower.contains('order') || queryLower.contains('delivery')) {
      return 'orders';
    } else if (queryLower.contains('driver')) {
      return 'drivers';
    } else if (queryLower.contains('company') || queryLower.contains('companies')) {
      return 'companies';
    } else if (queryLower.contains('performance') || queryLower.contains('rate') || queryLower.contains('efficiency')) {
      return 'performance';
    } else if (queryLower.contains('analyz') || queryLower.contains('trend') || queryLower.contains('report')) {
      return 'analytics';
    } else {
      return 'general';
    }
  }

  /// Clear any cached contexts
  void clearCache() {
    _dataService.clearCache();
  }
}
