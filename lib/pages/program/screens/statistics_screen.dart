import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StatisticsProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF181A20);
    const cardBg = Color(0xFF23252B);
    const accentGreen = Color(0xFF6DFD7D);
    const accentBlue = Color(0xFF4886FE);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: accentGreen),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accentBlue, accentGreen],
          ).createShader(bounds),
          child: const Text(
            'Your Progress',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.1,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentGreen),
            onPressed: () {
              context.read<StatisticsProvider>().loadStatistics();
            },
          ),
        ],
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.loadStatistics(),
            color: accentGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards Row
                  _buildOverviewCards(provider, accentGreen, accentBlue, cardBg),
                  const SizedBox(height: 25),

                  _sectionHeader('Weekly Activity', accentGreen),
                  const SizedBox(height: 11),
                  _buildWorkoutChart(provider, accentGreen, cardBg),

                  const SizedBox(height: 25),

                  _sectionHeader('Fatigue Trend', accentBlue),
                  const SizedBox(height: 11),
                  _buildFatigueChart(provider, accentBlue, cardBg),

                  const SizedBox(height: 25),

                  _sectionHeader('Recent Workouts', accentGreen),
                  const SizedBox(height: 12),
                  _buildRecentWorkoutsList(provider, cardBg, accentGreen, accentBlue),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(StatisticsProvider provider, Color accentGreen, Color accentBlue, Color cardBg) {
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.fitness_center, iconColor: accentGreen, label: 'Total Workouts', value: '${provider.totalCompletedWorkouts}', cardColor: cardBg)),
        const SizedBox(width: 14),
        Expanded(child: _StatCard(icon: Icons.local_fire_department, iconColor: accentBlue, label: 'Current Streak', value: '${provider.currentStreak}', suffix: 'days', cardColor: cardBg)),
        const SizedBox(width: 14),
        Expanded(child: _StatCard(icon: Icons.show_chart, iconColor: accentGreen, label: 'Weekly Rate', value: '${provider.weeklyCompletionRate.toStringAsFixed(0)}', suffix: '%', cardColor: cardBg)),
      ],
    );
  }

  Widget _buildWorkoutChart(StatisticsProvider provider, Color accent, Color cardBg) {
    final data = provider.getWeeklyWorkoutData();
    if (data.values.every((v) => v == 0)) return _buildEmptyChart('No workouts logged this week', cardBg, accent);
    return _ChartCard(
      child: BarChart(
        BarChartData(
          maxY: (data.values.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
          barGroups: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: accent,
                  width: 17,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 11, color: Colors.grey));
            })),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final keys = data.keys.toList();
              if (value.toInt() >= 0 && value.toInt() < keys.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              }
              return const Text('');
            })),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade700, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildFatigueChart(StatisticsProvider provider, Color accent, Color cardBg) {
    final data = provider.getWeeklyFatigueData();
    if (data.values.every((v) => v == 0)) return _buildEmptyChart('No fatigue data logged this week', cardBg, accent);
    return _ChartCard(
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 5,
          lineBarsData: [
            LineChartBarData(
              spots: data.entries.map((entry) {
                final index = data.keys.toList().indexOf(entry.key);
                return FlSpot(index.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              color: accent,
              barWidth: 3,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(radius: 4, color: accent, strokeWidth: 2, strokeColor: Colors.white);
              }),
              belowBarData: BarAreaData(show: true, color: accent.withOpacity(0.11)),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey));
            })),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final keys = data.keys.toList();
              if (value.toInt() >= 0 && value.toInt() < keys.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              }
              return const Text('');
            })),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade700, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message, Color cardBg, Color accent) {
    return _ChartCard(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 44, color: accent.withOpacity(0.26)),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkoutsList(StatisticsProvider provider, Color cardBg, Color accentGreen, Color accentBlue) {
    final recentLogs = provider.recentLogs.take(10).toList();
    if (recentLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.fitness_center, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text('No workouts logged yet', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recentLogs.map((log) {
        return Card(
          color: cardBg,
          margin: const EdgeInsets.only(bottom: 9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: log.completed ? accentGreen : Colors.grey.shade700,
              child: Icon(
                log.completed ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(_formatDate(log.date), style: TextStyle(fontWeight: FontWeight.bold, color: accentBlue)),
            subtitle: log.fatigueLevel != null
                ? Row(
                    children: [
                      const Icon(Icons.speed, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Fatigue: ${log.fatigueLevel}/5', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  )
                : null,
            trailing: log.notes != null && log.notes!.isNotEmpty
                ? Icon(Icons.notes, size: 20, color: accentBlue)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionHeader(String text, Color accent) => Padding(
        padding: const EdgeInsets.only(left: 1.5, bottom: 4),
        child: Text(text, style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold, color: accent)),
      );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF23252B),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? suffix;
  final Color cardColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.suffix,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 29),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    suffix!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
