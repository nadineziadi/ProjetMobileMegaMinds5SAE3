enum SupplementCategory {
  weightGain,
  weightLoss,
  maintainWeight,
  energy,
  health;

  String get displayName {
    switch (this) {
      case SupplementCategory.weightGain:
        return 'Weight Gain';
      case SupplementCategory.weightLoss:
        return 'Weight Loss';
      case SupplementCategory.maintainWeight:
        return 'Maintain Weight';
      case SupplementCategory.energy:
        return 'Energy';
      case SupplementCategory.health:
        return 'Health and Wellness';
    }
  }
}

