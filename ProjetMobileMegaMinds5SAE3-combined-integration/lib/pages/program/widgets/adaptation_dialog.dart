import 'package:flutter/material.dart';
import '../services/adaptation_service.dart';

class AdaptationDialog extends StatelessWidget {
  final AdaptationRecommendation recommendation;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const AdaptationDialog({
    Key? key,
    required this.recommendation,
    required this.onAccept,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getColor(),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Smart Adaptation'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation.reason,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(_getIcon(), color: _getColor(), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.suggestedChange,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getExplanation(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getColor(),
          ),
          child: const Text('Apply Changes'),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (recommendation.type) {
      case AdaptationType.increase:
        return Icons.trending_up;
      case AdaptationType.decrease:
        return Icons.trending_down;
      default:
        return Icons.check_circle;
    }
  }

  Color _getColor() {
    switch (recommendation.type) {
      case AdaptationType.increase:
        return Colors.green;
      case AdaptationType.decrease:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getExplanation() {
    switch (recommendation.type) {
      case AdaptationType.increase:
        return 'We\'ll increase the number of sets and reps to challenge you more.';
      case AdaptationType.decrease:
        return 'We\'ll reduce the workout intensity to help you recover and stay consistent.';
      default:
        return 'Keep up the great work!';
    }
  }
}