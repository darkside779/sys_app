// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/ai_response_models.dart';
import '../localization/app_localizations.dart';

class ProductMetricsCard extends StatelessWidget {
  final ProductMetrics metrics;

  const ProductMetricsCard({
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
                  Icons.inventory_2,
                  color: theme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.productMetrics,
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
              localizations.totalProducts,
              metrics.totalProducts.toString(),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.check_circle,
              localizations.activeProducts,
              metrics.activeProducts.toString(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.shopping_bag,
              localizations.availableProducts,
              metrics.availableProducts.toString(),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.warning,
              localizations.outOfStock,
              metrics.outOfStock.toString(),
              metrics.outOfStock > 0 ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.low_priority,
              localizations.lowStock,
              metrics.lowStock.toString(),
              metrics.lowStock > 3 ? Colors.orange : Colors.grey,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.attach_money,
              localizations.averagePrice,
              '\$${metrics.averagePrice.toStringAsFixed(2)}',
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              context,
              Icons.account_balance_wallet,
              localizations.inventoryValue,
              '\$${metrics.totalInventoryValue.toStringAsFixed(2)}',
              Colors.indigo,
            ),
            const SizedBox(height: 16),
            if (metrics.outOfStock > 0 || metrics.lowStock > 3)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        metrics.outOfStock > 0
                            ? (localizations.restockNeeded)
                            : (localizations.lowStockWarning),
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
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
