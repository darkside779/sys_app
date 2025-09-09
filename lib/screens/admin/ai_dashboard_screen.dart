// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import '/widgets/ai_interactive_dashboard.dart';
import '/localization/app_localizations.dart';
import '/services/ai_service.dart';
import '/services/ai_data_service.dart';
import '/services/ai_data_export_service.dart';
import '/services/ai_sharing_service.dart';
import '/models/ai_response_models.dart';

class AIDashboardScreen extends StatelessWidget {
  const AIDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    
    return Scaffold(
      body: const AIInteractiveDashboard(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(context),
        label: Text(l10n.quick_actions),
        icon: const Icon(Icons.flash_on),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quick_actions,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: Text(l10n.quick_analysis),
              subtitle: Text(l10n.analyze_current_data),
              onTap: () {
                Navigator.pop(context);
                _performQuickAnalysis(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(l10n.export_report),
              subtitle: Text(l10n.export_comprehensive_report),
              onTap: () {
                Navigator.pop(context);
                _performQuickExport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.share_results),
              subtitle: Text(l10n.share_key_findings),
              onTap: () {
                Navigator.pop(context);
                _performQuickShare(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(l10n.refresh_data),
              subtitle: Text(l10n.refresh_all_data),
              onTap: () {
                Navigator.pop(context);
                _performQuickRefresh(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performQuickAnalysis(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(l10n.analyzing),
            ],
          ),
        ),
      );

      // Get data and perform analysis
      final data = await AIDataService.instance.getAllDataForAI();
      final response = AIService.instance.generateSystemInsights(data, isArabic);
      
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show results
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.analysis_results),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (response.type == AIResponseType.systemInsights) ...[
                  ...(response.data as SystemInsights).recommendations.take(3).map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(child: Text(recommendation)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if open
      _showErrorDialog(context, 'Analysis failed: $e');
    }
  }

  Future<void> _performQuickExport(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(l10n.exporting),
            ],
          ),
        ),
      );

      final data = await AIDataService.instance.getAllDataForAI();
      final filePath = await AIDataExportService.instance.exportToPDF(
        dashboardData: data,
        isArabic: isArabic,
        customTitle: l10n.comprehensive_report,
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.report_exported_successfully),
            action: SnackBarAction(
              label: l10n.share,
              onPressed: () => AISharingService.instance.shareViaEmail(
                dashboardData: data,
                isArabic: isArabic,
                exportFormat: 'pdf',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(context, 'Export failed: $e');
    }
  }

  Future<void> _performQuickShare(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    try {
      final data = await AIDataService.instance.getAllDataForAI();
      await AISharingService.instance.shareAsLink(
        dashboardData: data,
        isArabic: isArabic,
        customMessage: l10n.system_results,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.share_link_generated),
        ),
      );
    } catch (e) {
      _showErrorDialog(context, 'Share failed: $e');
    }
  }

  Future<void> _performQuickRefresh(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(l10n.refreshing),
            ],
          ),
        ),
      );

      // Refresh all data services
      await AIDataService.instance.getAllDataForAI();
      
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.data_refreshed_successfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(context, 'Refresh failed: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
