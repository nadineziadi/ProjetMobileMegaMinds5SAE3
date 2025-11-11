import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'meal_model.dart';
import 'meal_service.dart';

class NutritionStatsPage extends StatefulWidget {
  const NutritionStatsPage({super.key});

  @override
  State<NutritionStatsPage> createState() => _NutritionStatsPageState();
}

class _NutritionStatsPageState extends State<NutritionStatsPage> {
  String _selectedPeriod = 'Semaine'; // Jour, Semaine, Mois
  bool _isLoading = true;
  Map<String, int> _data = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final now = DateTime.now();
    Map<String, int> newData = {};

    if (_selectedPeriod == 'Jour') {
      // Données par catégorie pour aujourd'hui
      final todayMeals = await MealService.getTodayMeals();
      newData = {
        'Petit-déjeuner': 0,
        'Déjeuner': 0,
        'Dîner': 0,
        'Collation': 0,
      };
      for (var meal in todayMeals) {
        newData[meal.categoryName] = (newData[meal.categoryName] ?? 0) + meal.calories;
      }
    } else if (_selectedPeriod == 'Semaine') {
      // Données des 7 derniers jours
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayName = _getDayName(date.weekday);
        final meals = await MealService.getMealsByDate(date);
        final totalCal = meals.fold<int>(0, (sum, meal) => sum + meal.calories);
        newData[dayName] = totalCal;
      }
    } else {
      // Données des 4 dernières semaines
      for (int i = 3; i >= 0; i--) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
        final weekEnd = weekStart.add(const Duration(days: 6));
        
        int weekTotal = 0;
        for (int day = 0; day < 7; day++) {
          final date = weekStart.add(Duration(days: day));
          final meals = await MealService.getMealsByDate(date);
          weekTotal += meals.fold<int>(0, (sum, meal) => sum + meal.calories);
        }
        
        newData['S${4 - i}'] = weekTotal;
      }
    }

    setState(() {
      _data = newData;
      _isLoading = false;
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lun';
      case 2: return 'Mar';
      case 3: return 'Mer';
      case 4: return 'Jeu';
      case 5: return 'Ven';
      case 6: return 'Sam';
      case 7: return 'Dim';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: const Text(
          'Statistiques',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC7F000)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Period selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2E32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: ['Jour', 'Semaine', 'Mois'].map((period) {
                        final isSelected = _selectedPeriod == period;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPeriod = period);
                              _loadData();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFC7F000)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                period,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2E32),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _selectedPeriod == 'Jour'
                              ? 'Calories par catégorie'
                              : 'Calories totales',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 250,
                          child: _selectedPeriod == 'Jour'
                              ? _buildPieChart()
                              : _buildBarChart(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2E32),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Résumé',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          'Total',
                          '${_data.values.fold<int>(0, (sum, val) => sum + val)} kcal',
                          Icons.local_fire_department,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Moyenne',
                          '${_data.isEmpty ? 0 : (_data.values.reduce((a, b) => a + b) / _data.length).round()} kcal',
                          Icons.trending_up,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Maximum',
                          '${_data.isEmpty ? 0 : _data.values.reduce((a, b) => a > b ? a : b)} kcal',
                          Icons.arrow_upward,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFC7F000).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFC7F000), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFC7F000),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final total = _data.values.fold<int>(0, (sum, val) => sum + val);
    if (total == 0) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.green,
    ];

    return PieChart(
      PieChartData(
        sections: _data.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final percentage = (data.value / total * 100).round();
          
          return PieChartSectionData(
            value: data.value.toDouble(),
            title: '$percentage%',
            color: colors[index % colors.length],
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 0,
      ),
    );
  }

  Widget _buildBarChart() {
    if (_data.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final maxY = _data.values.isEmpty 
        ? 2000.0 
        : (_data.values.reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: _data.entries.toList().asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: const Color(0xFFC7F000),
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
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _data.keys.toList()[index],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
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
}
