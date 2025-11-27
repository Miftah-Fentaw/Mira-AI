import 'package:chatbot/screens/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chatbot/providers/onboarding_provider.dart';
import 'package:chatbot/screens/chat_screen.dart';
import 'package:chatbot/screens/onboarding_screen.dart';
import 'package:chatbot/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnboardingCompleted = ref.watch(onboardingProvider);

    return MaterialApp.router(
      title: 'Mira AI',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: GoRouter(
        initialLocation: isOnboardingCompleted ? '/chat' : '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            name: 'onboarding',
            pageBuilder: (context, state) => NoTransitionPage(
              child: OnboardingScreen(),
            ),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
          GoRoute(
            path: '/feedback',
            name: 'feedback',
            pageBuilder: (context, state) => NoTransitionPage(
              child: FeedbackScreen(),
            ),
          ),  
        ],
        redirect: (context, state) {
          final onboarding = ref.read(onboardingProvider);
          final isOnOnboardingPage = state.matchedLocation == '/onboarding';
          
          if (!onboarding && !isOnOnboardingPage) {
            return '/onboarding';
          }
          
          if (onboarding && isOnOnboardingPage) {
            return '/chat';
          }
          
          return null;
        },
      ),
    );
  }
}
