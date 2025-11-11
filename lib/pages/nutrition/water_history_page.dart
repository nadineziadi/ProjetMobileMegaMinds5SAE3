import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'water_service.dart';
import 'water_intake_model.dart';

class WaterHistoryPage extends StatefulWidget {
  const WaterHistoryPage({super.key});

  @override
  State<WaterHistoryPage> createState() => _WaterHistoryPageState();
}

class _WaterHistoryPageState extends State<WaterHistoryPage> {
  Map<DateTime, int> _weeklyData = {};
  List<WaterIntake> _todayIntakes = [];
  bool _isLoading = true;
  int _goalAmount = 2000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final weeklyData = await WaterService.getWeeklyData();
    final todayIntakes = await WaterService.getTodayIntakes();
    final goal = await WaterService.getGoal();
    
    setState(() {
      _weeklyData = weeklyData;
      _todayIntakes = todayIntakes;
      _goalAmount = goal.dailyGoal;
      _isLoading = false;
    });
  }

  String _getDayName(DateTime date) {
    final days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: const Text(
          'Historique d\'hydratation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0288D1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Graphique hebdomadaire
                  const Text(
                    'Les 7 derniers jours',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2E32),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: _buildBarChart(),
                        ),
                        const SizedBox(height: 16),
                        _buildLegend(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Statistiques
                  const Text(
                    'Statistiques',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        'Moyenne/jour',
                        '${_calculateAverage().toInt()} ml',
                        Icons.water_drop,
                        const Color(0xFF0288D1),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        'Maximum',
                        '${_getMaximum()} ml',
                        Icons.trending_up,
                        Colors.green,
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        'Total 7 jours',
                        '${_getTotal()} ml',
                        Icons.analytics,
                        const Color(0xFFC7F000),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(
                        'Objectif atteint',
                        '${_getDaysGoalMet()}/7 jours',
                        Icons.check_circle,
                        Colors.orange,
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Liste détaillée du jour
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Détails d\'aujourd\'hui',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_todayIntakes.length} verre${_todayIntakes.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_todayIntakes.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.water_drop_outlined, 
                               size: 60, color: Colors.grey[700]),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune consommation aujourd\'hui',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._todayIntakes.map((intake) => _buildIntakeItem(intake)),
                ],
              ),
            ),
    );
  }

  Widget _buildBarChart() {
    final sortedDates = _weeklyData.keys.toList()..sort();
    
    return BarChart(
      BarChartData(
        maxY: _goalAmount.toDouble() * 1.2,
        barGroups: sortedDates.asMap().entries.map((entry) {
          final index = entry.key;
          final date = entry.value;
          final amount = _weeklyData[date] ?? 0;
          final reachedGoal = amount >= _goalAmount;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount.toDouble(),
                color: reachedGoal ? Colors.green : const Color(0xFF0288D1),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedDates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getDayName(sortedDates[index]),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _goalAmount / 4,
          getDrawingHorizontalLine: (value) {
            // Ligne de l'objectif
            if (value == _goalAmount) {
              return const FlLine(
                color: Colors.orange,
                strokeWidth: 2,
                dashArray: [5, 5],
              );
            }
            return FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, 'Objectif atteint'),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFF0288D1), 'En cours'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.orange, '--- Objectif'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeItem(WaterIntake intake) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0288D1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.water_drop,
              color: Color(0xFF0288D1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${intake.amount} ml',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  intake.formattedTime,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAverage() {
    if (_weeklyData.isEmpty) return 0;
    final total = _weeklyData.values.fold<int>(0, (sum, val) => sum + val);
    return total / _weeklyData.length;
  }

  int _getMaximum() {
    if (_weeklyData.isEmpty) return 0;
    return _weeklyData.values.reduce((a, b) => a > b ? a : b);
  }

  int _getTotal() {
    return _weeklyData.values.fold<int>(0, (sum, val) => sum + val);
  }

  int _getDaysGoalMet() {
    return _weeklyData.values.where((amount) => amount >= _goalAmount).length;
  }
}