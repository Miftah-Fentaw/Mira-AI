import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:chatbot/providers/onboarding_provider.dart';
import 'package:chatbot/theme.dart';
import 'package:chatbot/widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    OnboardingPage(
      imagePath: 'assets/onb1.gif',
      title: 'Welcome to Mira AI',
      description: 'Your intelligent AI companion for meaningful conversations',
    ),
    OnboardingPage(
      imagePath: 'assets/onb2.png',
      title: 'Smart Conversations',
      description: 'Experience natural and engaging discussions powered by AI',
    ),
    OnboardingPage(
      imagePath: 'assets/onb3.png',
      title: 'Always Available',
      description: 'Get instant responses anytime you need assistance',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _handleNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ref.read(onboardingProvider.notifier).completeOnboarding();
    }
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.lg,
            child: TextButton(
              onPressed: _handleSkip,
              child: Text(
                'Skip',
                style: context.textStyles.titleMedium?.copyWith(
                  color: AppColors.neonGreen,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.xxl,
            left: 0,
            right: 0,
            child: Padding(
              padding: AppSpacing.horizontalXl,
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotColor: AppColors.darkGreen,
                      activeDotColor: AppColors.neonGreen,
                      dotHeight: 12,
                      dotWidth: 12,
                      spacing: 8,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
