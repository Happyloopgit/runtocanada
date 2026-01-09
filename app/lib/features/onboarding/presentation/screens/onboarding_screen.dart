import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/navigation/app_router.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/features/onboarding/data/onboarding_service.dart';
import 'package:run_to_canada/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:run_to_canada/features/onboarding/presentation/widgets/page_indicator.dart';

/// Onboarding screen with 4 pages introducing the app
/// Shows once on first launch
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding completion status to Hive
    await OnboardingService.completeOnboarding();

    // Navigate to login screen
    if (mounted) {
      AppRouter.navigateAndRemoveUntil(
        context,
        RouteConstants.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Page view with onboarding pages
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: const [
                OnboardingPage(
                  icon: Icons.directions_run,
                  iconGradient: LinearGradient(
                    colors: [Color(0xFF0D7FF2), Color(0xFF0A66C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  title: 'Welcome to\nRun to Canada',
                  description:
                      'Transform your daily runs into an epic virtual journey across Canada. Track your progress, discover cities, and stay motivated!',
                ),
                OnboardingPage(
                  icon: Icons.near_me,
                  iconGradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  title: 'GPS Tracking',
                  description:
                      'Every kilometer you run in real life moves you forward on your virtual journey. Accurate GPS tracking ensures precise distance measurement.',
                ),
                OnboardingPage(
                  icon: Icons.flag,
                  iconGradient: LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  title: 'Journey Progress',
                  description:
                      'Set a destination goal and watch your virtual location move along the route. Celebrate milestones as you virtually pass through Canadian cities!',
                ),
                OnboardingPage(
                  icon: Icons.photo_camera,
                  iconGradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  title: 'Discover Cities',
                  description:
                      'Unlock city photos and fun facts as you reach each milestone. Learn about Canada while staying fit and motivated!',
                ),
              ],
            ),

            // Skip button (top right)
            if (_currentPage < 3)
              Positioned(
                top: 16,
                right: 24,
                child: CustomTextButton(
                  text: 'Skip',
                  onPressed: _skipOnboarding,
                  fontSize: 16,
                ),
              ),

            // Bottom section with page indicators and button
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  PageIndicator(
                    currentPage: _currentPage,
                    pageCount: 4,
                  ),

                  const SizedBox(height: 32),

                  // Next/Get Started button
                  CustomButton(
                    text: _currentPage == 3 ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                    icon: _currentPage == 3 ? null : Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
