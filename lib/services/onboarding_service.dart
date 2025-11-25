import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class OnboardingService {
  static const String _onboardingKey = 'onboarding_completed';

  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
    }
  }
}
