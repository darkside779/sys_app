// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/ai_response_models.dart';

class OrderMetricsCard extends StatelessWidget {
  final OrderMetrics metrics;

  const OrderMetricsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "📦 Order Metrics",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Live Data",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Order Status Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildMetricTile("Total Orders", metrics.totalOrders.toString(), Icons.shopping_cart, Colors.blue),
                _buildMetricTile("✅ Completed", metrics.completed.toString(), Icons.check_circle, Colors.green),
                _buildMetricTile("⏳ Pending", metrics.pending.toString(), Icons.pending, Colors.orange),
                _buildMetricTile("🚚 Out for Delivery", metrics.outForDelivery.toString(), Icons.local_shipping, Colors.purple),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Financial Overview
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    "💰 Total Revenue", 
                    "\$${metrics.revenue.toStringAsFixed(2)}", 
                    Colors.green
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialCard(
                    "📊 Average Order", 
                    "\$${metrics.avgOrder.toStringAsFixed(2)}", 
                    Colors.blue
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Recent Activity
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timeline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "📅 ${metrics.recentOrdersCount} orders in last 7 days",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class DriverMetricsCard extends StatelessWidget {
  final DriverMetrics metrics;

  const DriverMetricsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "🚚 Driver Performance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Live Data",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Driver Overview
            Row(
              children: [
                Expanded(
                  child: _buildDriverStatCard(
                    "👤 Total Drivers", 
                    metrics.totalDrivers.toString(), 
                    Colors.blue
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDriverStatCard(
                    "🟢 Active Now", 
                    metrics.activeDrivers.toString(), 
                    Colors.green
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildDriverStatCard(
                    "🚛 Total Deliveries", 
                    metrics.totalDeliveries.toString(), 
                    Colors.purple
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDriverStatCard(
                    "📊 Avg per Driver", 
                    metrics.avgDeliveriesPerDriver.toStringAsFixed(1), 
                    Colors.orange
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Top Performer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🥇 Top Performer",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metrics.mostActiveDriver,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildDriverStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyMetricsCard extends StatelessWidget {
  final CompanyMetrics metrics;

  const CompanyMetricsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "🏢 Company Analytics",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Live Data",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Company Stats
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildCompanyStatTile(
                  "🏢 Total", 
                  metrics.totalCompanies.toString(), 
                  Colors.teal
                ),
                _buildCompanyStatTile(
                  "🟢 Active", 
                  metrics.activeCompanies.toString(), 
                  Colors.green
                ),
                _buildCompanyStatTile(
                  "⚪ Inactive", 
                  metrics.inactiveCompanies.toString(), 
                  Colors.grey
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Best Performing Company
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.teal, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "👑 Best Performing Company",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metrics.bestPerformingCompany,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildCompanyStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SystemInsightsCard extends StatelessWidget {
  final SystemInsights insights;

  const SystemInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "🔍 System Insights",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Live Analysis",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quick Overview
            Row(
              children: [
                Expanded(
                  child: _buildOverviewTile(
                    "📦 Orders", 
                    insights.orderMetrics.totalOrders.toString(), 
                    Colors.blue
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOverviewTile(
                    "🚚 Drivers", 
                    insights.driverMetrics.activeDrivers.toString(), 
                    Colors.orange
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOverviewTile(
                    "🏢 Companies", 
                    insights.companyMetrics.activeCompanies.toString(), 
                    Colors.teal
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Recommendations
            const Text(
              "💡 Recommendations",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            
            ...insights.recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // System Health
            const Text(
              "🔄 System Health",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: insights.systemHealth.entries.map((entry) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    "${entry.key}: ${entry.value}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
