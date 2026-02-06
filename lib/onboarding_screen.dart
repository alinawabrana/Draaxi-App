import 'package:draaxi/src/common/widgets/circular_action.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/constant/images.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onSkip() {
    if (_currentIndex == 2) {
      context.goNamed(ARouter.welcome);
    } else {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onAction() {
    if (_currentIndex == 2) {
      context.goNamed(ARouter.welcome);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    final pages = [
      _OnboardingPage(
        skip: _onSkip,
        imagePath: AImages.anywhereYouAre,
        title: ATexts.onBoardingTitle1,
        description: ATexts.onBoardingDescCommon,
        action: CircularAction(
          progressValue: 1 / 3,
          icon: Icons.arrow_forward,
          onPressed: _onAction,
        ),
        size: size,
        textTheme: textTheme,
      ),
      _OnboardingPage(
        skip: _onSkip,
        imagePath: AImages.atAnytime,
        title: ATexts.onBoardingTitle2,
        description: ATexts.onBoardingDescCommon,
        action: CircularAction(
          progressValue: 2 / 3,
          icon: Icons.arrow_forward,
          onPressed: _onAction,
        ),
        size: size,
        textTheme: textTheme,
      ),
      _OnboardingPage(
        skip: _onSkip,
        imagePath: AImages.bookYourCar,
        title: ATexts.onBoardingTitle3,
        description: ATexts.onBoardingDescCommon,
        action: CircularAction(
          progressValue: 1,
          label: 'Go',
          onPressed: _onAction,
        ),
        size: size,
        textTheme: textTheme,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          children: pages,
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.skip,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.action,
    required this.size,
    required this.textTheme,
  });

  final VoidCallback skip;
  final String imagePath;
  final String title;
  final String description;
  final Widget action;
  final Size size;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              const Spacer(),
              SizedBox(
                width: 35,
                child: TextButton(
                  onPressed: skip,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF414141),
                    minimumSize: const Size(35, 35),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('Skip', style: textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: 208,
            width: size.width,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 43),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 57),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AHelperFunction.isDarkMode(context)
                      ? const Color(0xFFD0D0D0)
                      : null,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Center(child: action),
      ],
    );
  }
}
