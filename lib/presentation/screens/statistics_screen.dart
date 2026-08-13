import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/repositories/savings_repository.dart';
import '../../data/models/wishlist_item.dart';
import '../helpers.dart';

class StatisticsScreen extends StatelessWidget {
  final WishlistRepository repository;

  const StatisticsScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: repository.listenable,
          builder: (context, box, child) {
            final stats = WishlistStats.compute(repository.getAll());
            final allItems = repository.getAll();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingXl),
                      child: Column(
                        children: [
                          Text(
                            'Progress Keseluruhan',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimens.spacingLg),
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: stats.overallProgress,
                                    strokeWidth: 12,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(stats.overallProgress * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'dana tercapai',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingMd),
                  _StatItem(
                    label: 'Total Wishlist',
                    value: '${stats.totalItems}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Total Target Harga',
                    value: Formatters.currency(stats.totalTarget),
                    icon: Icons.flag_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Total Dana Terkumpul',
                    value: Formatters.currency(stats.totalSaved),
                    icon: Icons.savings_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Dana Masih Dibutuhkan',
                    value: Formatters.currency(stats.totalRemaining),
                    icon: Icons.remove_circle_outline,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Wishlist Tercapai',
                    value: '${stats.completedItems}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppDimens.spacingMd),
                  // Trend chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tren Dana',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimens.spacingSm),
                          _TrendChart(
                            monthlyData: _getMonthlySavings(allItems),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingMd),
                  // Category allocation
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alokasi Kategori',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimens.spacingSm),
                          _CategoryAllocationChart(allItems),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingMd),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppDimens.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color == AppColors.error
                          ? Theme.of(context).colorScheme.onSurface
                          : color,
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
}

Map<String, double> _getMonthlySavings(List<WishlistItem> items) {
  final savingsRepo = SavingsRepository();
  final now = DateTime.now();
  final Map<String, double> monthly = {};

  for (int i = 5; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i, 1);
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    monthly[key] = 0.0;
  }

  for (final item in items) {
    final entries = savingsRepo.getForWishlist(item.id);
    for (final entry in entries) {
      final key = '${entry.addedAt.year}-${entry.addedAt.month.toString().padLeft(2, '0')}';
      if (monthly.containsKey(key)) {
        monthly[key] = (monthly[key] ?? 0) + entry.amount;
      }
    }
  }

  return monthly;
}

class _TrendChart extends StatelessWidget {
  final Map<String, double> monthlyData;

  const _TrendChart({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Belum ada data dana',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final sortedKeys = monthlyData.keys.toList()..sort();
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = monthlyData[key] ?? 0;
      spots.add(FlSpot(i.toDouble(), value));
      final parts = key.split('-');
      final monthName = _getMonthName(int.parse(parts[1]));
      labels.add(monthName);
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getInterval(spots),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) return const SizedBox();
                  return Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: _getInterval(spots),
                getTitlesWidget: (value, meta) {
                  return Text(
                    Formatters.currencyShort(value),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (sortedKeys.length - 1).toDouble(),
          minY: 0,
          maxY: spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2 : 1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= labels.length) return null;
                  return LineTooltipItem(
                    '${labels[index]}: ${Formatters.currency(spot.y)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    if (maxY <= 100000) return 20000;
    if (maxY <= 500000) return 100000;
    if (maxY <= 1000000) return 200000;
    return (maxY / 5).ceilToDouble();
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month];
  }
}

class _CategoryAllocationChart extends StatelessWidget {
  final List<WishlistItem> items;

  const _CategoryAllocationChart(this.items);

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData(items);

    if (categoryData.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'Belum ada data kategori',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final total = categoryData.values.fold(0.0, (a, b) => a + b);
    final categories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: total,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final cat = categories[group.x.toInt()];
                    return BarTooltipItem(
                      '${cat.key}: ${Formatters.currency(cat.value)} (${(cat.value / total * 100).toStringAsFixed(1)}%)',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= categories.length) return const SizedBox();
                      return Text(
                        categories[index].key,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(categories.length, (i) {
                final cat = categories[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: cat.value,
                      color: _getCategoryColor(cat.key),
                      width: 24,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: total,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spacingMd),
        Wrap(
          spacing: AppDimens.spacingMd,
          runSpacing: AppDimens.spacingSm,
          children: categories.map((cat) {
            final pct = total > 0 ? (cat.value / total * 100) : 0.0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(cat.key),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${cat.key}: ${pct.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Map<String, double> _getCategoryData(List<WishlistItem> items) {
    final Map<String, double> data = {};
    for (final item in items) {
      final cat = item.category.label;
      data[cat] = (data[cat] ?? 0) + item.savedAmount;
    }
    return data;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Elektronik': return const Color(0xFF6C63FF);
      case 'Fashion': return const Color(0xFFEC4899);
      case 'Gaming': return const Color(0xFFF59E0B);
      case 'Pendidikan': return const Color(0xFF10B981);
      case 'Kendaraan': return const Color(0xFFEF4444);
      case 'Lainnya': return const Color(0xFF64748B);
      default: return AppColors.primary;
    }
  }
}
