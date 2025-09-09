// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import '../services/ai_data_service.dart';
import '../services/ai_notification_service.dart';
import '../services/ai_data_export_service.dart';
import '../services/ai_sharing_service.dart';
import '../localization/app_localizations.dart';
import 'ai_chart_widget.dart';
import 'ai_notification_panel.dart';
import 'ai_dashboard_widget.dart';

class AIInteractiveDashboard extends StatefulWidget {
  const AIInteractiveDashboard({super.key});

  @override
  State<AIInteractiveDashboard> createState() => _AIInteractiveDashboardState();
}

class _AIInteractiveDashboardState extends State<AIInteractiveDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;
  String _selectedTimeRange = '7d';
  String _selectedEntity = 'all';
  
  final List<String> _timeRanges = ['1d', '7d', '30d', '90d'];
  final List<String> _entities = ['all', 'orders', 'drivers', 'companies'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
    _startAutoRefresh();
    
    // Start AI monitoring
    AINotificationService.instance.startMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (mounted) {
        _loadDashboardData(showLoading: false);
      }
    });
  }

  Future<void> _loadDashboardData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await AIDataService.instance.getAllDataForAI();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final _ = Theme.of(context);
    final isArabic = l10n.localeName == 'ar';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'لوحة معلومات الذكاء الاصطناعي' : 'AI Interactive Dashboard'),
        actions: [
          // Time range selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            tooltip: isArabic ? 'النطاق الزمني' : 'Time Range',
            onSelected: (range) {
              setState(() {
                _selectedTimeRange = range;
              });
              _loadDashboardData();
            },
            itemBuilder: (context) => _timeRanges.map((range) {
              final labels = {
                '1d': isArabic ? 'يوم واحد' : '1 Day',
                '7d': isArabic ? '7 أيام' : '7 Days', 
                '30d': isArabic ? '30 يوم' : '30 Days',
                '90d': isArabic ? '90 يوم' : '90 Days',
              };
              return PopupMenuItem(
                value: range,
                child: Row(
                  children: [
                    if (_selectedTimeRange == range) const Icon(Icons.check, size: 16),
                    if (_selectedTimeRange == range) const SizedBox(width: 8),
                    Text(labels[range]!),
                  ],
                ),
              );
            }).toList(),
          ),
          
          // Entity filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: isArabic ? 'تصفية البيانات' : 'Filter Data',
            onSelected: (entity) {
              setState(() {
                _selectedEntity = entity;
              });
              _loadDashboardData();
            },
            itemBuilder: (context) => _entities.map((entity) {
              final labels = {
                'all': isArabic ? 'الكل' : 'All',
                'orders': isArabic ? 'الطلبات' : 'Orders',
                'drivers': isArabic ? 'السائقين' : 'Drivers',
                'companies': isArabic ? 'الشركات' : 'Companies',
              };
              return PopupMenuItem(
                value: entity,
                child: Row(
                  children: [
                    if (_selectedEntity == entity) const Icon(Icons.check, size: 16),
                    if (_selectedEntity == entity) const SizedBox(width: 8),
                    Text(labels[entity]!),
                  ],
                ),
              );
            }).toList(),
          ),
          
          // Refresh button
          IconButton(
            onPressed: () => _loadDashboardData(),
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),
          
          // Export button
          IconButton(
            onPressed: _exportDashboard,
            icon: const Icon(Icons.download),
            tooltip: isArabic ? 'تصدير' : 'Export',
          ),
          
          // Share button
          IconButton(
            onPressed: _shareDashboard,
            icon: const Icon(Icons.share),
            tooltip: isArabic ? 'مشاركة' : 'Share',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard),
              text: isArabic ? 'نظرة عامة' : 'Overview',
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: isArabic ? 'التحليلات' : 'Analytics',
            ),
            Tab(
              icon: const Icon(Icons.notifications),
              text: isArabic ? 'التنبيهات' : 'Alerts',
            ),
            Tab(
              icon: const Icon(Icons.settings),
              text: isArabic ? 'الإعدادات' : 'Settings',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget(isArabic)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isArabic),
                    _buildAnalyticsTab(isArabic),
                    _buildAlertsTab(isArabic),
                    _buildSettingsTab(isArabic),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAIAssistant,
        tooltip: isArabic ? 'المساعد الذكي' : 'AI Assistant',
        heroTag: "ai_dashboard_fab",
        child: const Icon(Icons.psychology),
      ),
    );
  }

  Widget _buildErrorWidget(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'خطأ في تحميل البيانات' : 'Error loading data',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadDashboardData(),
            child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Dashboard Widget
          const AIDashboardWidget(),
          
          // Quick Stats Grid
          _buildQuickStatsGrid(isArabic),
          
          const SizedBox(height: 16),
          
          // Key Performance Indicators
          _buildKPISection(isArabic),
          
          const SizedBox(height: 16),
          
          // Recent Activity
          _buildRecentActivitySection(isArabic),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(bool isArabic) {
    if (_dashboardData == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Charts Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 2 : 1,
            childAspectRatio: 1.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              AIChartWidget(
                title: isArabic ? 'اتجاه الطلبات' : 'Orders Trend',
                chartType: 'line_chart',
                data: _dashboardData!,
                isArabic: isArabic,
              ),
              AIChartWidget(
                title: isArabic ? 'توزيع حالات الطلبات' : 'Order Status Distribution',
                chartType: 'pie_chart',
                data: _dashboardData!,
                isArabic: isArabic,
              ),
              AIChartWidget(
                title: isArabic ? 'أداء السائقين' : 'Driver Performance',
                chartType: 'scatter_plot',
                data: _dashboardData!,
                isArabic: isArabic,
              ),
              AIChartWidget(
                title: isArabic ? 'إحصائيات الشركات' : 'Company Statistics',
                chartType: 'bar_chart',
                data: _dashboardData!,
                isArabic: isArabic,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(bool isArabic) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          AINotificationPanel(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'إعدادات التحديث التلقائي' : 'Auto-Refresh Settings',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(isArabic ? 'تفعيل التحديث التلقائي' : 'Enable Auto-Refresh'),
                    subtitle: Text(isArabic ? 'تحديث البيانات كل دقيقتين' : 'Refresh data every 2 minutes'),
                    value: _refreshTimer?.isActive ?? false,
                    onChanged: (value) {
                      if (value) {
                        _startAutoRefresh();
                      } else {
                        _refreshTimer?.cancel();
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'إعدادات التنبيهات' : 'Notification Settings',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(isArabic ? 'تنبيهات الأنماط غير العادية' : 'Unusual Pattern Alerts'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: Text(isArabic ? 'تنبيهات مشاكل الأداء' : 'Performance Issue Alerts'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: Text(isArabic ? 'توصيات التحسين' : 'Optimization Suggestions'),
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(bool isArabic) {
    if (_dashboardData == null) return const SizedBox.shrink();
    
    final ordersData = _dashboardData!['orders'] as Map<String, dynamic>? ?? {};
    final driversData = _dashboardData!['drivers'] as Map<String, dynamic>? ?? {};
    final companiesData = _dashboardData!['companies'] as Map<String, dynamic>? ?? {};
    
    final orders = (ordersData['recent_orders'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final drivers = (driversData['drivers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final companies = (companiesData['companies'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    
    final stats = [
      {
        'title': isArabic ? 'إجمالي الطلبات' : 'Total Orders',
        'value': orders.length.toString(),
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
      },
      {
        'title': isArabic ? 'السائقون النشطون' : 'Active Drivers',
        'value': drivers.where((d) => d['isActive'] == true).length.toString(),
        'icon': Icons.local_shipping,
        'color': Colors.green,
      },
      {
        'title': isArabic ? 'الشركات النشطة' : 'Active Companies',
        'value': companies.where((c) => c['isActive'] == true).length.toString(),
        'icon': Icons.business,
        'color': Colors.orange,
      },
      {
        'title': isArabic ? 'معدل النجاح' : 'Success Rate',
        'value': orders.isEmpty ? '0%' : '${((orders.where((o) => o['status'] == 'completed').length / orders.length) * 100).toStringAsFixed(1)}%',
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stat['icon'] as IconData,
                  size: 32,
                  color: stat['color'] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKPISection(bool isArabic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'مؤشرات الأداء الرئيسية' : 'Key Performance Indicators',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Add KPI widgets here
            const Text('KPI widgets will be implemented here'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(bool isArabic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'النشاط الأخير' : 'Recent Activity',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Add recent activity list here
            const Text('Recent activity list will be implemented here'),
          ],
        ),
      ),
    );
  }

  void _showAIAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'AI Assistant',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const Expanded(
              child: Center(
                child: Text('AI Assistant chat interface will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportDashboard() async {
    if (_dashboardData == null) return;
    
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    
    // Show export options
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تصدير لوحة المعلومات' : 'Export Dashboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(isArabic ? 'تقرير PDF' : 'PDF Report'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: Text(isArabic ? 'جدول بيانات Excel' : 'Excel Spreadsheet'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(isArabic ? 'بيانات JSON' : 'JSON Data'),
              onTap: () => Navigator.pop(context, 'json'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        String? filePath;
        
        switch (result) {
          case 'pdf':
            filePath = await AIDataExportService.instance.exportToPDF(
              dashboardData: _dashboardData!,
              isArabic: isArabic,
            );
            break;
          case 'excel':
            filePath = await AIDataExportService.instance.exportToExcel(
              dashboardData: _dashboardData!,
              isArabic: isArabic,
            );
            break;
          case 'json':
            filePath = await AIDataExportService.instance.exportToJSON(
              dashboardData: _dashboardData!,
              isArabic: isArabic,
            );
            break;
        }
        
        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArabic ? 'تم تصدير البيانات بنجاح' : 'Data exported successfully'),
              action: SnackBarAction(
                label: isArabic ? 'عرض' : 'View',
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'فشل في تصدير البيانات' : 'Failed to export data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareDashboard() async {
    if (_dashboardData == null) return;
    
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    
    // Show sharing options
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'مشاركة لوحة المعلومات' : 'Share Dashboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(isArabic ? 'رابط المشاركة' : 'Share Link'),
              subtitle: Text(isArabic ? 'إنشاء رابط للمشاركة' : 'Generate shareable link'),
              onTap: () => Navigator.pop(context, 'link'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(isArabic ? 'البريد الإلكتروني' : 'Send via Email'),
              subtitle: Text(isArabic ? 'إرسال التقرير بالبريد' : 'Email dashboard report'),
              onTap: () => Navigator.pop(context, 'email'),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(isArabic ? 'مشاركة لقطة الشاشة' : 'Share Screenshot'),
              subtitle: Text(isArabic ? 'مشاركة العرض الحالي' : 'Share current view'),
              onTap: () => Navigator.pop(context, 'screenshot'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        bool success = false;
        
        switch (result) {
          case 'link':
            success = await AISharingService.instance.shareAsLink(
              dashboardData: _dashboardData!,
              isArabic: isArabic,
            );
            break;
          case 'email':
            success = await AISharingService.instance.shareViaEmail(
              dashboardData: _dashboardData!,
              isArabic: isArabic,
              exportFormat: 'pdf',
            );
            break;
          case 'screenshot':
            // For screenshot sharing, we would need widget key
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isArabic ? 'ستتوفر ميزة مشاركة لقطة الشاشة قريباً' : 'Screenshot sharing will be available soon'),
              ),
            );
            return;
        }
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArabic ? 'تم مشاركة لوحة المعلومات بنجاح' : 'Dashboard shared successfully'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'فشل في مشاركة لوحة المعلومات' : 'Failed to share dashboard'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
