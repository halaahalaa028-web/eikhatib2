import 'package:permission_handler/permission_handler.dart';

import 'package:eikhatib/core/theme/typography.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/colors.dart';
import '../auth/logic/user_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loaderController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _loadingFade;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _setupAnimations();
    _initApp();
  }

  Future<void> _initApp() async {
    final startTime = DateTime.now();

    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(seconds: 4) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;
    _checkAndNavigate();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();

    await Permission.location.request();
  }

  void _setupAnimations() {
    /// 🔥 لوجو (مرة واحدة بس)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _rotationAnimation = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    /// 🔥 اللودينج (بيكرر)
    _loaderController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    /// تشغيل
    _logoController.forward(); // مرة واحدة
    _loaderController.repeat(); // يفضل شغال
  }

  void _checkAndNavigate() {
    final userCubit = context.read<UserCubit>();

    // If cubit is not ready yet, wait a bit and try again
    if (!userCubit.state.isReady) {
      Future.delayed(const Duration(milliseconds: 500), _checkAndNavigate);
      return;
    }

    if (userCubit.state.user != null) {
      final user = userCubit.state.user!;
      if (!user.isApproved) {
        Navigator.pushReplacementNamed(context, Routes.waitingApproval);
      } else {
        if (user.role == 'driver') {
          Navigator.pushReplacementNamed(context, Routes.driverHome);
        } else {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      }
    } else if (userCubit.state.requiresOtpVerification) {
      Navigator.pushReplacementNamed(
        context,
        Routes.otp,
        arguments: {
          'phone': userCubit.state.registeredPhone,
          'name': userCubit.state.registeredName,
        },
      );
    } else if (userCubit.state.hasOnboarded) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      Navigator.pushReplacementNamed(context, Routes.onboarding);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  /// 🔥 Loader احترافي (نقط بتطلع وتنزل)
  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _loadingFade,
      child: Column(
        children: [
          const SizedBox(height: 24),

          AnimatedBuilder(
            animation: _loaderController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  double delay = index * 0.2;
                  double value = (_loaderController.value - delay).clamp(
                    0.0,
                    1.0,
                  );

                  return Transform.translate(
                    offset: Offset(0, -12 * value),
                    child: Opacity(
                      opacity: 0.5 + (value * 0.5),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              /// 🔥 اللوجو
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: Container(
                      height: 150,
                      width: 150,

                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.appLogo2,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// 🔥 اللودينج
              _buildLoadingIndicator(),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "1.0.5",
                    style: AppTypography.h6.copyWith(
                      color: AppColors.primary.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "V",
                    style: AppTypography.h6.copyWith(
                      color: AppColors.primary2,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
