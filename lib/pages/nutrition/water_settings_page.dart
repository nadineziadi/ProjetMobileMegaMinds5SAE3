import 'package:flutter/material.dart';
import 'water_service.dart';
import 'water_intake_model.dart';

class WaterSettingsPage extends StatefulWidget {
  const WaterSettingsPage({super.key}); // ← CORRIGÉ : ajouté ')'

  @override
  State<WaterSettingsPage> createState() => _WaterSettingsPageState();
}

class _WaterSettingsPageState extends State<WaterSettingsPage> {
  int _goalAmount = 2000;
  bool _remindersEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final goal = await WaterService.getGoal();
    setState(() {
      _goalAmount = goal.dailyGoal;
      _remindersEnabled = goal.remindersEnabled;
      _isLoading = false;
    });
  }

  Future<void> _updateGoal(int newGoal) async {
    await WaterService.updateGoal(newGoal);
    setState(() => _goalAmount = newGoal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objectif mis à jour !'),
          backgroundColor: Color(0xFF0288D1),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleReminders(bool enabled) async {
    await WaterService.toggleReminders(enabled);
    setState(() => _remindersEnabled = enabled);
  }

  void _showGoalDialog() {
    final controller = TextEditingController(text: _goalAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2E32),
        title: const Text(
          'Objectif journalier',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
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
            const SizedBox(height: 16),
            const Text(
              'Recommandé : 2000-2500 ml/jour',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0 && amount <= 10000) {
                Navigator.pop(context);
                _updateGoal(amount);
              }
            },
            child: const Text('Enregistrer', style: TextStyle(color: Color(0xFF0288D1))),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2E32),
        title: const Text(
          'Réinitialiser les données',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tout l\'historique d\'hydratation ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await WaterService.clearAllData();
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Données réinitialisées'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Réinitialiser', style: TextStyle(color: Colors.red)),
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
          'Paramètres d\'hydratation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF32383E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0288D1)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Objectif journalier
                const Text(
                  'Objectif journalier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2E32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Color(0xFF0288D1),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Objectif',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_goalAmount ml/jour',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF0288D1)),
                        onPressed: _showGoalDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Rappels
                const Text(
                  'Rappels',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2E32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _remindersEnabled
                              ? const Color(0xFF0288D1).withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: _remindersEnabled ? const Color(0xFF0288D1) : Colors.grey,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rappels réguliers pour boire',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _remindersEnabled,
                        onChanged: _toggleReminders,
                        activeColor: const Color(0xFF0288D1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Objectifs prédéfinis
                const Text(
                  'Objectifs recommandés',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildPresetButton(1500, 'Léger', 'Pour activité réduite'),
                const SizedBox(height: 8),
                _buildPresetButton(2000, 'Standard', 'Recommandé pour la plupart'),
                const SizedBox(height: 8),
                _buildPresetButton(2500, 'Actif', 'Pour activité sportive'),
                const SizedBox(height: 8),
                _buildPresetButton(3000, 'Intense', 'Pour athlètes'),

                const SizedBox(height: 30),

                // Bouton de réinitialisation
                const Text(
                  'Données',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _showResetDialog,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Réinitialiser tout l\'historique'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Conseils
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0288D1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0288D1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb, color: Color(0xFF0288D1)),
                          SizedBox(width: 8),
                          Text(
                            'Conseils d\'hydratation',
                            style: TextStyle(
                              color: Color(0xFF0288D1),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Buvez régulièrement tout au long de la journée'),
                      _buildTip('Augmentez votre consommation lors d\'activités physiques'),
                      _buildTip('L\'eau est la meilleure source d\'hydratation'),
                      _buildTip('Écoutez votre corps et votre soif'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPresetButton(int amount, String title, String subtitle) {
    final isSelected = _goalAmount == amount;

    return GestureDetector(
      onTap: () => _updateGoal(amount),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0288D1).withOpacity(0.2) : const Color(0xFF2A2E32),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0288D1) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF0288D1) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amount ml',
              style: TextStyle(
                color: isSelected ? const Color(0xFF0288D1) : Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Color(0xFF0288D1), fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}