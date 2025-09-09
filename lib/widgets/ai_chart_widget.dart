// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/ai_data_export_service.dart';
import '../services/ai_sharing_service.dart';

class AIChartWidget extends StatefulWidget {
  final String title;
  final String chartType;
  final Map<String, dynamic> data;
  final bool isArabic;

  const AIChartWidget({
    super.key,
    required this.title,
    required this.chartType,
    required this.data,
    this.isArabic = false,
  });

  @override
  State<AIChartWidget> createState() => _AIChartWidgetState();
}

class _AIChartWidgetState extends State<AIChartWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  _getChartIcon(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'export':
                          _exportChart();
                          break;
                        case 'share':
                          _shareChart();
                          break;
                        case 'fullscreen':
                          _showFullscreen();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            const Icon(Icons.download),
                            const SizedBox(width: 8),
                            Text(widget.isArabic ? 'تصدير' : 'Export'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            const Icon(Icons.share),
                            const SizedBox(width: 8),
                            Text(widget.isArabic ? 'مشاركة' : 'Share'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'fullscreen',
                        child: Row(
                          children: [
                            const Icon(Icons.fullscreen),
                            const SizedBox(width: 8),
                            Text(widget.isArabic ? 'ملء الشاشة' : 'Fullscreen'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Chart
              SizedBox(
                height: 250,
                child: _buildChart(),
              ),
              
              // Chart insights
              const SizedBox(height: 12),
              _buildInsights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getChartIcon() {
    switch (widget.chartType.toLowerCase()) {
      case 'line_chart':
        return const Icon(Icons.trending_up, color: Colors.blue);
      case 'bar_chart':
        return const Icon(Icons.bar_chart, color: Colors.green);
      case 'pie_chart':
        return const Icon(Icons.pie_chart, color: Colors.orange);
      case 'scatter_plot':
        return const Icon(Icons.scatter_plot, color: Colors.purple);
      default:
        return const Icon(Icons.analytics, color: Colors.indigo);
    }
  }

  Widget _buildChart() {
    switch (widget.chartType.toLowerCase()) {
      case 'line_chart':
        return _buildLineChart();
      case 'bar_chart':
        return _buildBarChart();
      case 'pie_chart':
        return _buildPieChart();
      case 'scatter_plot':
        return _buildScatterPlot();
      default:
        return _buildDefaultChart();
    }
  }

  Widget _buildLineChart() {
    final ordersData = widget.data['orders'] as Map<String, dynamic>? ?? {};
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    // Group orders by day for the last 7 days
    final Map<DateTime, int> ordersByDay = {};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      ordersByDay[day] = 0;
    }
    
    for (final order in orders) {
      try {
        final orderTime = order['timestamp'] is String 
            ? DateTime.parse(order['timestamp']) 
            : DateTime.now();
        final day = DateTime(orderTime.year, orderTime.month, orderTime.day);
        
        if (ordersByDay.containsKey(day)) {
          ordersByDay[day] = ordersByDay[day]! + 1;
        }
      } catch (e) {
        // Skip invalid timestamps
      }
    }
    
    final spots = ordersByDay.entries.map((entry) {
      final dayIndex = ordersByDay.keys.toList().indexOf(entry.key).toDouble();
      return FlSpot(dayIndex, entry.value.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final ordersData = widget.data['orders'] as Map<String, dynamic>? ?? {};
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    // Count orders by status
    final Map<String, int> statusCounts = {
      'completed': 0,
      'pending': 0,
      'out_for_delivery': 0,
      'cancelled': 0,
    };
    
    for (final order in orders) {
      final status = order['status'] as String? ?? 'unknown';
      if (statusCounts.containsKey(status)) {
        statusCounts[status] = statusCounts[status]! + 1;
      }
    }

    final barGroups = statusCounts.entries.map((entry) {
      final index = statusCounts.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: _getStatusColor(entry.key),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: statusCounts.values.isEmpty ? 10 : statusCounts.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final labels = widget.isArabic 
                    ? ['مكتمل', 'معلق', 'قيد التوصيل', 'ملغي']
                    : ['Completed', 'Pending', 'Delivering', 'Cancelled'];
                if (value.toInt() < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget _buildPieChart() {
    final ordersData = widget.data['orders'] as Map<String, dynamic>? ?? {};
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    // Count orders by status
    final Map<String, int> statusCounts = {
      'completed': 0,
      'pending': 0,
      'out_for_delivery': 0,
      'cancelled': 0,
    };
    
    for (final order in orders) {
      final status = order['status'] as String? ?? 'unknown';
      if (statusCounts.containsKey(status)) {
        statusCounts[status] = statusCounts[status]! + 1;
      }
    }

    final total = statusCounts.values.fold(0, (sum, count) => sum + count);
    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    final sections = statusCounts.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getStatusColor(entry.key),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: statusCounts.entries.map((entry) {
              final labels = widget.isArabic 
                  ? {'completed': 'مكتمل', 'pending': 'معلق', 'out_for_delivery': 'قيد التوصيل', 'cancelled': 'ملغي'}
                  : {'completed': 'Completed', 'pending': 'Pending', 'out_for_delivery': 'Delivering', 'cancelled': 'Cancelled'};
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${labels[entry.key]} (${entry.value})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScatterPlot() {
    final driversData = widget.data['drivers'] as Map<String, dynamic>? ?? {};
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    final spots = drivers.map((driver) {
      final deliveries = (driver['completedDeliveries'] as int? ?? 0).toDouble();
      final rating = (driver['rating'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(deliveries, rating);
    }).toList();

    return ScatterChart(
      ScatterChartData(
        scatterSpots: spots.map((spot) => ScatterSpot(
          spot.x,
          spot.y,
          dotPainter: FlDotCirclePainter(
            color: Colors.blue,
            radius: 6,
          ),
        )).toList(),
        minX: 0,
        maxX: spots.isEmpty ? 100 : spots.map((s) => s.x).reduce((a, b) => a > b ? a : b) * 1.1,
        minY: 0,
        maxY: 5,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget _buildDefaultChart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chart type not supported',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'out_for_delivery':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInsights() {
    final theme = Theme.of(context);
    
    // Generate AI insights for this chart
    final insights = _generateChartInsights();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.isArabic ? 'رؤى AI' : 'AI Insights',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 6, right: 6),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    insight,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _generateChartInsights() {
    final ordersData = widget.data['orders'] as Map<String, dynamic>? ?? {};
    final driversData = widget.data['drivers'] as Map<String, dynamic>? ?? {};
    
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    List<String> insights = [];
    
    switch (widget.chartType.toLowerCase()) {
      case 'line_chart':
        if (orders.isNotEmpty) {
          final recent = orders.where((o) {
            try {
              final orderTime = o['timestamp'] is String 
                  ? DateTime.parse(o['timestamp']) 
                  : DateTime.now();
              return orderTime.isAfter(DateTime.now().subtract(const Duration(days: 3)));
            } catch (e) {
              return false;
            }
          }).length;
          
          insights.add(widget.isArabic 
              ? 'نمو بنسبة ${((recent / orders.length) * 100).toStringAsFixed(1)}% في آخر 3 أيام'
              : '${((recent / orders.length) * 100).toStringAsFixed(1)}% growth in last 3 days');
        }
        break;
        
      case 'bar_chart':
      case 'pie_chart':
        final completed = orders.where((o) => o['status'] == 'completed').length;
        if (orders.isNotEmpty) {
          final rate = (completed / orders.length) * 100;
          insights.add(widget.isArabic 
              ? 'معدل إنجاز ${rate.toStringAsFixed(1)}%'
              : '${rate.toStringAsFixed(1)}% completion rate');
        }
        break;
        
      case 'scatter_plot':
        if (drivers.isNotEmpty) {
          final avgRating = drivers.fold<double>(0, (sum, d) => sum + ((d['rating'] as num?)?.toDouble() ?? 0)) / drivers.length;
          insights.add(widget.isArabic 
              ? 'متوسط التقييم ${avgRating.toStringAsFixed(2)}/5'
              : 'Average rating ${avgRating.toStringAsFixed(2)}/5');
        }
        break;
    }
    
    if (insights.isEmpty) {
      insights.add(widget.isArabic 
          ? 'لا توجد رؤى متاحة للبيانات الحالية'
          : 'No insights available for current data');
    }
    
    return insights;
  }

  void _exportChart() async {
    try {
      final filePath = await AIDataExportService.instance.exportChartData(
        chartType: widget.chartType,
        chartData: widget.data,
        isArabic: widget.isArabic,
        title: widget.title,
        format: 'json',
      );
      
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'تم تصدير المخطط بنجاح' : 'Chart exported successfully'),
            action: SnackBarAction(
              label: widget.isArabic ? 'عرض' : 'View',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'فشل في تصدير المخطط' : 'Failed to export chart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareChart() async {
    try {
      final success = await AISharingService.instance.shareChart(
        chartType: widget.chartType,
        chartData: widget.data,
        chartKey: null, // We'll implement screenshot sharing later
        isArabic: widget.isArabic,
        title: widget.title,
        shareMethod: 'data',
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'تم مشاركة المخطط بنجاح' : 'Chart shared successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'فشل في مشاركة المخطط' : 'Failed to share chart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                onPressed: _exportChart,
                icon: const Icon(Icons.download),
              ),
              IconButton(
                onPressed: _shareChart,
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(child: _buildChart()),
                const SizedBox(height: 16),
                _buildInsights(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
