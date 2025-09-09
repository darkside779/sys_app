class OrderMetrics {
  final int totalOrders;
  final int completed;
  final int pending;
  final int outForDelivery;
  final int notReturned;
  final double revenue;
  final double avgOrder;
  final int recentOrdersCount;

  OrderMetrics({
    required this.totalOrders,
    required this.completed,
    required this.pending,
    required this.outForDelivery,
    required this.notReturned,
    required this.revenue,
    required this.avgOrder,
    required this.recentOrdersCount,
  });

  factory OrderMetrics.fromMap(Map<String, dynamic> data) {
    return OrderMetrics(
      totalOrders: data['total_orders'] ?? 0,
      completed: data['completed_orders'] ?? 0,
      pending: data['pending_orders'] ?? 0,
      outForDelivery: data['out_for_delivery'] ?? 0,
      notReturned: data['not_returned'] ?? 0,
      revenue: (data['total_cost'] ?? 0.0).toDouble(),
      avgOrder: (data['average_cost'] ?? 0.0).toDouble(),
      recentOrdersCount: data['recent_orders_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'completed_orders': completed,
      'pending_orders': pending,
      'out_for_delivery': outForDelivery,
      'not_returned': notReturned,
      'total_cost': revenue,
      'average_cost': avgOrder,
      'recent_orders_count': recentOrdersCount,
    };
  }
}

class DriverMetrics {
  final int totalDrivers;
  final int activeDrivers;
  final int totalDeliveries;
  final double avgDeliveriesPerDriver;
  final String mostActiveDriver;

  DriverMetrics({
    required this.totalDrivers,
    required this.activeDrivers,
    required this.totalDeliveries,
    required this.avgDeliveriesPerDriver,
    required this.mostActiveDriver,
  });

  factory DriverMetrics.fromMap(Map<String, dynamic> data) {
    return DriverMetrics(
      totalDrivers: data['total_drivers'] ?? 0,
      activeDrivers: data['active_drivers'] ?? 0,
      totalDeliveries: data['total_deliveries'] ?? 0,
      avgDeliveriesPerDriver: (data['average_deliveries_per_driver'] ?? 0.0).toDouble(),
      mostActiveDriver: data['most_active_driver'] ?? 'No data',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_drivers': totalDrivers,
      'active_drivers': activeDrivers,
      'total_deliveries': totalDeliveries,
      'average_deliveries_per_driver': avgDeliveriesPerDriver,
      'most_active_driver': mostActiveDriver,
    };
  }
}

class CompanyMetrics {
  final int totalCompanies;
  final int activeCompanies;
  final int inactiveCompanies;
  final String bestPerformingCompany;

  CompanyMetrics({
    required this.totalCompanies,
    required this.activeCompanies,
    required this.inactiveCompanies,
    required this.bestPerformingCompany,
  });

  factory CompanyMetrics.fromMap(Map<String, dynamic> data) {
    return CompanyMetrics(
      totalCompanies: data['total_companies'] ?? 0,
      activeCompanies: data['active_companies'] ?? 0,
      inactiveCompanies: data['inactive_companies'] ?? 0,
      bestPerformingCompany: data['best_performing_company'] ?? 'No data',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_companies': totalCompanies,
      'active_companies': activeCompanies,
      'inactive_companies': inactiveCompanies,
      'best_performing_company': bestPerformingCompany,
    };
  }
}

class SystemInsights {
  final OrderMetrics orderMetrics;
  final DriverMetrics driverMetrics;
  final CompanyMetrics companyMetrics;
  final List<String> recommendations;
  final Map<String, String> systemHealth;

  SystemInsights({
    required this.orderMetrics,
    required this.driverMetrics,
    required this.companyMetrics,
    required this.recommendations,
    required this.systemHealth,
  });

  factory SystemInsights.fromData({
    required Map<String, dynamic> ordersData,
    required Map<String, dynamic> driversData,
    required Map<String, dynamic> companiesData,
  }) {
    return SystemInsights(
      orderMetrics: OrderMetrics.fromMap(ordersData),
      driverMetrics: DriverMetrics.fromMap(driversData),
      companyMetrics: CompanyMetrics.fromMap(companiesData),
      recommendations: [
        'Monitor driver performance trends',
        'Optimize company partnerships',
        'Track order completion rates',
        'Analyze revenue patterns',
      ],
      systemHealth: {
        'Firebase': 'Connected & Synced',
        'Real-time': 'Active',
        'Data Quality': 'Live & Accurate',
        'Performance': 'Optimal',
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_metrics': orderMetrics.toJson(),
      'driver_metrics': driverMetrics.toJson(),
      'company_metrics': companyMetrics.toJson(),
      'recommendations': recommendations,
      'system_health': systemHealth,
    };
  }
}

enum AIResponseType {
  orderMetrics,
  driverMetrics,
  companyMetrics,
  systemInsights,
  textResponse,
  error,
  help,
}

class AIStructuredResponse {
  final AIResponseType type;
  final dynamic data;
  final String? message;
  final bool isLiveData;

  AIStructuredResponse({
    required this.type,
    this.data,
    this.message,
    this.isLiveData = true,
  });

  factory AIStructuredResponse.orderMetrics(OrderMetrics metrics) {
    return AIStructuredResponse(
      type: AIResponseType.orderMetrics,
      data: metrics,
      isLiveData: true,
    );
  }

  factory AIStructuredResponse.driverMetrics(DriverMetrics metrics) {
    return AIStructuredResponse(
      type: AIResponseType.driverMetrics,
      data: metrics,
      isLiveData: true,
    );
  }

  factory AIStructuredResponse.companyMetrics(CompanyMetrics metrics) {
    return AIStructuredResponse(
      type: AIResponseType.companyMetrics,
      data: metrics,
      isLiveData: true,
    );
  }

  factory AIStructuredResponse.systemInsights(SystemInsights insights) {
    return AIStructuredResponse(
      type: AIResponseType.systemInsights,
      data: insights,
      isLiveData: true,
    );
  }

  factory AIStructuredResponse.textResponse(String message) {
    return AIStructuredResponse(
      type: AIResponseType.textResponse,
      message: message,
      isLiveData: false,
    );
  }

  factory AIStructuredResponse.error(String message) {
    return AIStructuredResponse(
      type: AIResponseType.error,
      message: message,
      isLiveData: false,
    );
  }

  factory AIStructuredResponse.help() {
    return AIStructuredResponse(
      type: AIResponseType.help,
      message: '''**Available Commands:**
• "Show today's orders" - View order statistics
• "Analyze performance" - Driver & delivery metrics  
• "Check company stats" - Business analytics
• "System insights" - Operational recommendations

**Demo Features:**
✅ Real-time Firebase data
✅ Interactive cards and charts
✅ Context-aware responses
✅ Live system monitoring''',
      isLiveData: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'data': data?.toJson?.call() ?? data,
      'message': message,
      'is_live_data': isLiveData,
    };
  }
}
