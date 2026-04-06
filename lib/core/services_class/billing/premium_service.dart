import 'package:goatlearning/core/services_class/billing/billing_manager.dart';

class PremiumService {
  static bool get isPremium => BillingManager.instance.isPremium.value;

  static bool canAccessChapter(int indexZeroBased) {
    if (isPremium) return true;
    // Allow first 4 chapters (0..3) for free; gate the rest.
    return indexZeroBased <= 3;
  }

  static bool canAccessExerciseForChapter(int indexZeroBased) {
    return canAccessChapter(indexZeroBased);
  }
}
