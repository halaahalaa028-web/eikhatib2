// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: AppAssets.onboarding1,
      titleKey: 'توصيل سريع و موثوق',
      descriptionKey:
          'نوصل طلبك باسرع وقت ممكن مع كباتن محترفين لضمان وصول شحنتك بسلام ',
      accent: AppColors.primary,
    ),
    OnboardingData(
      image: AppAssets.onboarding2,
      titleKey: 'تتبع لحظة بلحظة',
      descriptionKey:
          'تتبع طلبك علي الخريطة مباشرة من لحظه الاستلام حتي التسليم بنجاح',
      accent: AppColors.secondary,
    ),
    OnboardingData(
      image: AppAssets.onboarding3,
      titleKey: 'خدمة توصيل سريعة و سهلة',
      descriptionKey:
          'اطلب اوردر من اي مكتن و سيقوم الكابتن باستلامه و توصيله بكل سهولة علي مدار 24 ساعة',
      accent: AppColors.accent,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() async {
    await context.read<UserCubit>().completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.appLogo2, width: 100, height: 100),
                ],
              ),

              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 13,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: _currentPage == _pages.length - 1 ? 'ابدأ' : 'التالي',
                  height: 50,
                  borderRadius: 10,
                  textColor: AppColors.background,
                  onPressed: _nextPage,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: _navigateToHome,
                child: Text(
                  'تخطي',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset(data.image, width: 250, height: 250)),
          const SizedBox(height: 36),
          Text(
            data.titleKey.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.descriptionKey.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: Color.fromARGB(255, 97, 97, 97),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String titleKey;

  final String image;
  final String descriptionKey;
  final Color accent;

  OnboardingData({
    required this.titleKey,
    required this.image,
    required this.descriptionKey,
    required this.accent,
  });
}
