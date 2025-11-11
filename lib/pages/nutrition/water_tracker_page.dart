import 'package:flutter/material.dart';
import 'water_intake_model.dart';
import 'water_service.dart';
import 'water_bottle_widget.dart';
import 'water_history_page.dart';
import 'water_settings_page.dart';

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key});

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> {
  int _currentAmount = 0;
  int _goalAmount = 2000;
  double _percentage = 0.0;
  List<WaterIntake> _todayIntakes = [];
  bool _isLoading = true;

  final List<int> _quickAmounts = [100, 200, 250, 500];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final total = await WaterService.getTodayTotal();
    final goal = await WaterService.getGoal();
    final percentage = await WaterService.getProgressPercentage();
    final intakes = await WaterService.getTodayIntakes();
    
    setState(() {
      _currentAmount = total;
      _goalAmount = goal.dailyGoal;
      _percentage = percentage;
      _todayIntakes = intakes;
      _isLoading = false;
    });
  }

  Future<void> _addWater(int amount) async {
    await WaterService.addWaterIntake(amount);
    await _loadData();
    
    // Animation de succès
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.white),
              const SizedBox(width: 8),
              Text('+$amount ml ajouté !'),
            ],
          ),
          backgroundColor: const Color(0xFF0288D1),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCustomAmountDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2E32),
        title: const Text(
          'Quantité personnalisée',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Quantité en ml',
            hintStyle: const TextStyle(color: Colors.white38),
            suffixText: 'ml',
            suffixStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0288D1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _addWater(amount);
              }
            },
            child: const Text('Ajouter', style: TextStyle(color: Color(0xFF0288D1))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191C),
      appBar: AppBar(
        title: const Text(
          'Hydratation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF0288D1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WaterHistoryPage(),
                ),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF0288D1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WaterSettingsPage(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0288D1)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Bouteille animée
                  WaterBottleWidget(
                    percentage: _percentage,
                    currentAmount: _currentAmount,
                    goalAmount: _goalAmount,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Barre de progression
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _percentage / 100,
                            minHeight: 20,
                            backgroundColor: const Color(0xFF2A2E32),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _percentage >= 100
                                  ? Colors.green
                                  : const Color(0xFF0288D1),
                            ),
                          ),
                        ),
                        if (_percentage >= 100) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.celebration, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Objectif atteint ! 🎉',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Boutons d'ajout rapide
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ajout rapide',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2,
                          children: [
                            ..._quickAmounts.map((amount) => _buildQuickButton(amount)),
                            _buildCustomButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Historique du jour
                  if (_todayIntakes.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Aujourd\'hui',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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
                    ),
                    const SizedBox(height: 16),
                    ..._todayIntakes.take(5).map((intake) => _buildIntakeCard(intake)),
                    if (_todayIntakes.length > 5) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WaterHistoryPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Voir tout l\'historique',
                          style: TextStyle(color: Color(0xFF0288D1)),
                        ),
                      ),
                    ],
                  ],
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickButton(int amount) {
    return ElevatedButton(
      onPressed: () => _addWater(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A2E32),
        foregroundColor: const Color(0xFF0288D1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF0288D1)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop, size: 28),
          const SizedBox(height: 4),
          Text(
            '$amount ml',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton() {
    return ElevatedButton(
      onPressed: _showCustomAmountDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0288D1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit, size: 28),
          SizedBox(height: 4),
          Text(
            'Personnalisé',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeCard(WaterIntake intake) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () async {
              await WaterService.deleteIntake(intake.id);
              _loadData();
            },
          ),
        ],
      ),
    );
  }
}