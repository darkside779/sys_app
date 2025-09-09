// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/ai_response_models.dart';
import '../localization/app_localizations.dart';

class AIDashboardWidget extends StatefulWidget {
  const AIDashboardWidget({super.key});

  @override
  State<AIDashboardWidget> createState() => _AIDashboardWidgetState();
}

class _AIDashboardWidgetState extends State<AIDashboardWidget> {
  AIStructuredResponse? _dailyInsights;
  List<String> _quickStats = [];
  List<String> _actionableInsights = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get daily insights
      final insights = await AIService.instance.sendMessage('analyze system performance today');
      
      // Get quick stats
      final statsResponse = await AIService.instance.sendMessage('show daily summary');
      
      // Get actionable insights
      final recommendations = await AIService.instance.sendMessage('suggest optimizations');

      setState(() {
        _dailyInsights = insights;
        _quickStats = _extractQuickStats(statsResponse);
        _actionableInsights = _extractActionableInsights(recommendations);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<String> _extractQuickStats(AIStructuredResponse response) {
    // Extract key metrics from response
    if (response.type == AIResponseType.systemInsights) {
      final insights = response.data as SystemInsights;
      return [
        'Active Orders: ${insights.orderMetrics.recentOrdersCount}',
        'Success Rate: ${(insights.orderMetrics.revenue / insights.orderMetrics.totalOrders * 100).toStringAsFixed(1)}%',
        'Active Drivers: ${insights.driverMetrics.activeDrivers}',
        'Top Company: ${insights.companyMetrics.bestPerformingCompany}',
      ];
    }
    return ['No data available'];
  }

  List<String> _extractActionableInsights(AIStructuredResponse response) {
    if (response.type == AIResponseType.systemInsights) {
      final insights = response.data as SystemInsights;
      return insights.recommendations.take(3).toList();
    }
    return ['No recommendations available'];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.dashboard, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'لوحة معلومات الذكاء الاصطناعي' : 'AI Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadDashboardData,
                  icon: const Icon(Icons.refresh),
                  tooltip: isArabic ? 'تحديث' : 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        isArabic ? 'خطأ في تحميل البيانات' : 'Error loading data',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Quick Stats Section
              _buildQuickStatsSection(l10n, theme),
              const SizedBox(height: 20),
              
              // Daily Recommendations Section
              _buildRecommendationsSection(l10n, theme),
              const SizedBox(height: 20),
              
              // Actionable Insights Section
              _buildActionableInsightsSection(l10n, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(AppLocalizations l10n, ThemeData theme) {
    final isArabic = l10n.localeName == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'إحصائيات سريعة' : 'Quick Stats',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: _quickStats.map((stat) => _buildStatChip(stat, theme)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatChip(String stat, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        stat,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.localeName == 'ar' ? '💡 توصيات اليوم' : '💡 Today\'s Recommendations',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_dailyInsights?.type == AIResponseType.systemInsights) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.localeName == 'ar' 
                      ? 'نظامك يعمل بكفاءة جيدة اليوم!'
                      : 'Your system is performing well today!',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionableInsightsSection(AppLocalizations l10n, ThemeData theme) {
    final isArabic = l10n.localeName == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'رؤى قابلة للتنفيذ' : 'Actionable Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_actionableInsights.take(3).map((insight) => _buildInsightItem(insight, theme)).toList()),
        if (_actionableInsights.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to full insights page
            },
            child: Text(isArabic ? 'عرض المزيد' : 'View More'),
          ),
      ],
    );
  }

  Widget _buildInsightItem(String insight, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              insight,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
