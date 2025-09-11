// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/ai_response_models.dart';
import '../localization/app_localizations.dart';

class OrderMetricsCard extends StatelessWidget {
  final OrderMetrics metrics;

  const OrderMetricsCard({
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
                  Icons.shopping_cart,
                  color: theme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.orders,
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
              Icons.inventory,
              localizations.total,
              metrics.totalOrders.toString(),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.check_circle,
              localizations.completed,
              metrics.completed.toString(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.pending,
              localizations.pending,
              metrics.pending.toString(),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.local_shipping,
              localizations.status_out_for_delivery,
              metrics.outForDelivery.toString(),
              Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildMetricRow(
              context,
              Icons.attach_money,
              localizations.total_cost,
              '\$${metrics.revenue.toStringAsFixed(2)}',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.analytics,
              localizations.averagePrice,
              '\$${metrics.avgOrder.toStringAsFixed(2)}',
              Colors.purple,
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
