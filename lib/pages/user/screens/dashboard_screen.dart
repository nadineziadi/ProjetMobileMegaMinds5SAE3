import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _userService = UserService();
  UserProfile? _currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser().then((_) {
      _debugWeightHistory();
    });
  }

  Future<void> _loadUser() async {
    await _userService.init();
    final user = await _userService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _debugWeightHistory() {
    if (_currentUser == null) {
      print('⚠️ Aucun utilisateur chargé');
      return;
    }
    
    print('\n=== DEBUG HISTORIQUE POIDS ===');
    print('Utilisateur: ${_currentUser!.name}');
    print('Poids actuel: ${_currentUser!.weight}kg');
    print('Nombre d\'entrées: ${_currentUser!.weightHistory.length}');
    
    if (_currentUser!.weightHistory.isEmpty) {
      print('❌ Historique vide!');
    } else {
      final sortedHistory = List<WeightEntry>.from(_currentUser!.weightHistory)
        ..sort((a, b) => a.date.compareTo(b.date));
      
      print('\nEntrées triées par date:');
      for (int i = 0; i < sortedHistory.length; i++) {
        final entry = sortedHistory[i];
        print('  $i. ${entry.weight}kg - ${entry.date}');
      }
    }
    print('==============================\n');
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello ${_currentUser!.name.split(' ')[0]} 👋',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Ready to workout?',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.monitor_weight,
                    label: 'Poids',
                    value: '${_currentUser!.weight.toStringAsFixed(1)} kg',
                    color: const Color(0xFFa3e635),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_up,
                    label: 'IMC',
                    value: _currentUser!.bmi.toStringAsFixed(1),
                    color: _currentUser!.bmiColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.flag,
                    label: 'Objectif',
                    value: _getGoalEmoji(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.emoji_events,
                    label: 'Badges',
                    value: '${_currentUser!.badges.length}',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _currentUser!.bmiColor.withOpacity(0.2),
                    _currentUser!.bmiColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _currentUser!.bmiColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _currentUser!.bmiColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.health_and_safety,
                          color: _currentUser!.bmiColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser!.bmiCategory,
                            style: TextStyle(
                              color: _currentUser!.bmiColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'État de santé',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser!.personalizedAdvice,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Évolution du poids',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2d2d2d),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildWeightChart(),
            ),
            _buildWeightProgressIndicator(),
            const SizedBox(height: 24),
            
            const Text(
              'Actions rapides',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Dans la section "Actions rapides" de votre DashboardScreen, ajoutez :
const SizedBox(height: 16),
Row(
  children: [
    Expanded(
      child: _buildQuickAction(
        icon: Icons.cloud,
        label: 'Météo &\nEntraînement',
        color: Colors.cyan,
        onTap: () {
          Navigator.pushNamed(context, '/weather');
        },
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _buildQuickAction(
        icon: Icons.dashboard,
        label: 'Navigation\ncomplète',
        color: Colors.purple,
        onTap: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
      ),
    ),
  ],
),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.add_chart,
                    label: 'Mettre à jour\nle poids',
                    color: const Color(0xFFa3e635),
                    onTap: () => _showUpdateWeightDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.edit,
                    label: 'Modifier\nle profil',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/profile').then((_) {
                        _loadUser();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.settings,
                    label: 'Paramètres',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.dashboard,
                    label: 'Navigation\ncomplète',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/profile').then((_) {
              _loadUser();
            });
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          }
        },
        backgroundColor: const Color(0xFF2d2d2d),
        selectedItemColor: const Color(0xFFa3e635),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
  final weightHistory = _currentUser!.weightHistory;
  
  if (weightHistory.isEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.show_chart, color: Colors.grey, size: 48),
        const SizedBox(height: 8),
        const Text(
          'Aucune donnée de poids',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _showUpdateWeightDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFa3e635),
          ),
          child: const Text(
            'Ajouter mon premier poids',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  // Trier par date
  final sortedHistory = List<WeightEntry>.from(weightHistory)
    ..sort((a, b) => a.date.compareTo(b.date));

  print('📊 Génération graphique: ${sortedHistory.length} points');

  // Créer les points pour le graphique
  final spots = <FlSpot>[];
  for (int i = 0; i < sortedHistory.length; i++) {
    spots.add(FlSpot(i.toDouble(), sortedHistory[i].weight));
    print('   Point $i: ${sortedHistory[i].weight}kg');
  }

  // Calculer min/max pour adapter l'échelle
  double minY = sortedHistory.first.weight;
  double maxY = sortedHistory.first.weight;
  
  for (var entry in sortedHistory) {
    if (entry.weight < minY) minY = entry.weight;
    if (entry.weight > maxY) maxY = entry.weight;
  }

  // Ajouter une marge
  minY = minY - 2;
  maxY = maxY + 2;

  return LineChart(
    LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < sortedHistory.length) {
                return Text(
                  _formatDate(sortedHistory[index].date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}kg',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              );
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
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: const Color(0xFFa3e635),
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // Le dernier point est plus gros
              final isLast = index == spots.length - 1;
              return FlDotCirclePainter(
                radius: isLast ? 6 : 4,
                color: isLast ? Colors.white : const Color(0xFFa3e635),
                strokeWidth: 2,
                strokeColor: const Color(0xFFa3e635),
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFFa3e635).withOpacity(0.2),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: const Color(0xFF2d2d2d),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < sortedHistory.length) {
                return LineTooltipItem(
                  '${sortedHistory[index].weight.toStringAsFixed(1)} kg',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    ),
  );
}

  double _getMinWeight(List<WeightEntry> history) {
    if (history.isEmpty) return 60;
    return history.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxWeight(List<WeightEntry> history) {
    if (history.isEmpty) return 80;
    return history.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
  }

  double _getGridInterval(List<WeightEntry> history) {
    final range = _getMaxWeight(history) - _getMinWeight(history);
    if (range <= 1) return 0.5;
    if (range <= 3) return 1;
    if (range <= 6) return 2;
    if (range <= 12) return 3;
    return 5;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _formatFullDate(DateTime date) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 
                    'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getGoalEmoji() {
    switch (_currentUser!.goal) {
      case 'weight_loss':
        return '🔥';
      case 'muscle_gain':
        return '💪';
      case 'maintenance':
        return '⚖️';
      case 'endurance':
        return '🏃';
      default:
        return '🎯';
    }
  }

  void _showUpdateWeightDialog() {
    final controller = TextEditingController(
      text: _currentUser!.weight.toStringAsFixed(1),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text(
          'Mettre à jour le poids',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrez votre poids actuel :',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '70.5',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1a1a1a),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixText: 'kg',
                suffixStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            if (_currentUser!.weightHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Dernier poids: ${_currentUser!.weightHistory.last.weight.toStringAsFixed(1)}kg '
                'le ${_formatDate(_currentUser!.weightHistory.last.date)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text.replaceAll(',', '.'));
              if (weight != null && weight > 20 && weight < 300) {
                await _updateWeight(weight);
                if (mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Veuillez entrer un poids valide (20-300 kg)'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFa3e635),
            ),
            child: const Text('Enregistrer', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

Future<void> _updateWeight(double newWeight) async {
  try {
    print('\n📊 ========== DÉBUT UPDATE POIDS ==========');
    print('Nouveau poids: $newWeight kg');
    
    // 1. Récupérer l'utilisateur actuel
    final user = await _userService.getCurrentUser();
    if (user == null) {
      print('❌ Utilisateur non trouvé');
      return;
    }
    
    print('👤 Utilisateur: ${user.name} (${user.id})');
    print('📊 Historique AVANT: ${user.weightHistory.length} entrées');
    
    // 2. Créer la nouvelle entrée
    final newEntry = WeightEntry(
      date: DateTime.now(),
      weight: newWeight,
    );
    
    // 3. Ajouter l'entrée via le service
    await _userService.addWeightToHistory(user.id, newWeight);
    
    print('💾 Entrée ajoutée dans la BD');
    
    // 4. Recharger l'utilisateur depuis la BD
    await Future.delayed(const Duration(milliseconds: 100)); // Petit délai pour la BD
    final updatedUser = await _userService.getCurrentUser();
    
    if (updatedUser != null) {
      print('📖 Historique APRÈS: ${updatedUser.weightHistory.length} entrées');
      print('Détail des poids:');
      for (int i = 0; i < updatedUser.weightHistory.length; i++) {
        final entry = updatedUser.weightHistory[i];
        print('  [$i] ${entry.weight}kg - ${entry.date}');
      }
      
      // 5. Forcer le rebuild du widget
      if (mounted) {
        setState(() {
          _currentUser = updatedUser;
        });
        
        print('🔄 Interface mise à jour avec ${_currentUser!.weightHistory.length} entrées');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Poids mis à jour: ${newWeight.toStringAsFixed(1)} kg',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFa3e635),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      print('========== FIN UPDATE POIDS ==========\n');
    } else {
      print('❌ Erreur: impossible de recharger l\'utilisateur');
    }
  } catch (e, stackTrace) {
    print('❌ ERREUR UPDATE POIDS:');
    print('   Message: $e');
    print('   Stack: $stackTrace');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Widget _buildWeightProgressIndicator() {
    final weightHistory = _currentUser!.weightHistory;
    if (weightHistory.length < 2) {
      return const SizedBox();
    }
    
    final sortedHistory = List<WeightEntry>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final firstWeight = sortedHistory.first.weight;
    final lastWeight = sortedHistory.last.weight;
    final difference = lastWeight - firstWeight;
    final isWeightLoss = difference < 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2d2d),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isWeightLoss ? Icons.trending_down : Icons.trending_up,
            color: isWeightLoss ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${isWeightLoss ? 'Perte' : 'Gain'} de ${difference.abs().toStringAsFixed(1)}kg '
              'depuis le ${_formatDate(sortedHistory.first.date)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}