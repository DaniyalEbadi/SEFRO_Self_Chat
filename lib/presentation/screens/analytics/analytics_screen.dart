import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/responsive_layout.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(PersianStrings.analytics)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ContentContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductivityScoreCard(score: 78),
              const SizedBox(height: 20),
              _SectionTitle(title: PersianStrings.taskCompletion),
              const SizedBox(height: 12),
              _TaskCompletionChart(),
              const SizedBox(height: 20),
              _SectionTitle(title: PersianStrings.habitConsistency),
              const SizedBox(height: 12),
              _HabitConsistencyChart(),
              const SizedBox(height: 20),
              _SectionTitle(title: 'آمار کلی'),
              const SizedBox(height: 12),
              _OverallStats(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductivityScoreCard extends StatelessWidget {
  final int score;
  const _ProductivityScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gold.withValues(alpha: 0.15), AppTheme.gold.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(PersianStrings.productivityScore, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Text('$score%', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 42, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('نسبت به هفته گذشته ۵٪ افزایش', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: score.toDouble(),
                        color: AppTheme.gold,
                        radius: 40,
                      ),
                      PieChartSectionData(
                        value: (100 - score).toDouble(),
                        color: AppTheme.divider,
                        radius: 40,
                      ),
                    ],
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                  ),
                ),
                Text('$score%', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary));
  }
}

class _TaskCompletionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barGroups: [
            _barGroup(0, 5), _barGroup(1, 7), _barGroup(2, 4),
            _barGroup(3, 8), _barGroup(4, 6), _barGroup(5, 9), _barGroup(6, 7),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: AppTheme.textMuted));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, int y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y.toDouble(),
        color: AppTheme.gold,
        width: 16,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
    ]);
  }
}

class _HabitConsistencyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: AppTheme.textMuted));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 3), FlSpot(1, 5), FlSpot(2, 4),
                FlSpot(3, 6), FlSpot(4, 5), FlSpot(5, 7), FlSpot(6, 6),
              ],
              isCurved: true,
              color: AppTheme.emerald,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: AppTheme.emerald,
                      strokeWidth: 2,
                      strokeColor: AppTheme.bg,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.emerald.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 500;
        final children = [
          _StatTile(icon: Icons.check_circle, value: '۴۲', label: 'وظایف انجام شده', color: AppTheme.emerald),
          const SizedBox(width: 12),
          _StatTile(icon: Icons.local_fire_department, value: '۱۲', label: 'رکورد روزها', color: AppTheme.gold),
          const SizedBox(width: 12),
          _StatTile(icon: Icons.timer, value: '۲۸س', label: 'زمان تمرکز', color: AppTheme.teal),
        ];

        if (isWide) {
          return Row(children: children);
        }
        return Column(
          children: [
            Row(children: [children[0], children[1]]),
            const SizedBox(height: 12),
            Row(children: [const Spacer(), children[2]]),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatTile({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
