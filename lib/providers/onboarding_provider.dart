import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatbot/services/onboarding_service.dart';

final onboardingServiceProvider = Provider((ref) => OnboardingService());

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  late OnboardingService _service;

  @override
  bool build() {
    _service = ref.read(onboardingServiceProvider);
    _checkOnboarding();
    return false;
  }

  Future<void> _checkOnboarding() async {
    state = await _service.isOnboardingCompleted();
  }

  Future<void> completeOnboarding() async {
    await _service.completeOnboarding();
    state = true;
  }

  Future<void> resetOnboarding() async {
    await _service.resetOnboarding();
    state = false;
  }
}
