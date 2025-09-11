// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/ai_response_models.dart';
import '../localization/app_localizations.dart';

class DriverMetricsCard extends StatelessWidget {
  final DriverMetrics metrics;

  const DriverMetricsCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: theme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.drivers,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              Icons.people,
              localizations.total,
              metrics.totalDrivers.toString(),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.check_circle,
              localizations.active,
              metrics.activeDrivers.toString(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.delivery_dining,
              'Total Deliveries',
              metrics.totalDeliveries.toString(),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.analytics,
              'Avg per Driver',
              metrics.avgDeliveriesPerDriver.toStringAsFixed(1),
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.star,
              'Top Performer',
              metrics.mostActiveDriver,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
