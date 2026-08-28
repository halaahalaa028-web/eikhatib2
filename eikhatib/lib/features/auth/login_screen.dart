import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/routes/routes.dart';
import '../../core/services/auth_credential_storage.dart';
import 'logic/user_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthCredentialStorage _credentialStorage = AuthCredentialStorage();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _hasAutoTriggeredLogin = false;

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await _credentialStorage.loadLoginCredentials();
    if (!mounted) return;

    final rememberMe = credentials['rememberMe'] == true;
    final phone = credentials['phone'] as String?;
    final password = credentials['password'] as String?;

    setState(() {
      _rememberMe = rememberMe;
      phoneController.text = phone ?? '';
      passwordController.text = password ?? '';
    });

    if (rememberMe &&
        phone != null &&
        phone.isNotEmpty &&
        password != null &&
        password.isNotEmpty &&
        !_hasAutoTriggeredLogin) {
      _hasAutoTriggeredLogin = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<UserCubit>().login(
          phone.trim(),
          password,
          rememberMe: true,
        );
      });
    }
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final phoneText = phoneController.text.trim();
    final isPhoneValid =
        (phoneText.startsWith('0') && phoneText.length == 10) ||
        (!phoneText.startsWith('0') && phoneText.length == 9);
    return isPhoneValid && passwordController.text.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.status == 'waiting_approval') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.waitingApproval,
            (route) => false,
          );
        } else if (state.requiresOtpVerification) {
          final cleanPhone = phoneController.text.trim().startsWith('0')
              ? phoneController.text.trim().substring(1)
              : phoneController.text.trim();
          Navigator.pushReplacementNamed(
            context,
            Routes.otp,
            arguments: {'phone': '+962$cleanPhone'},
          );
        } else if (state.user != null) {
          if (!state.user!.isApproved) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.waitingApproval,
              (route) => false,
            );
          } else {
            if (state.user!.role == 'driver') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.driverHome,
                (route) => false,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.home,
                (route) => false,
              );
            }
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Container with Gradient and Curved corners
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,

                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.appLogo2),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Color.fromARGB(166, 0, 0, 0),
                        BlendMode.darken,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 40),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    Routes.home,
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                label: const Text(
                                  'تخطي',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(
                                    0.35,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Text(
                                'مرحباً بعودتك! الرجاء إدخال بياناتك للمتابعة.',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Container
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 30.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPhoneField(),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: passwordController,
                        hintText: 'كلمة المرور',
                        obscureText: _obscurePassword,
                        rightWidget: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.lock_outline),
                        ),
                        leftWidget: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            onChanged: (value) async {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                              await _credentialStorage.saveLoginCredentials(
                                rememberMe: _rememberMe,
                                phone: phoneController.text,
                                password: passwordController.text,
                              );
                            },
                          ),
                          const Text(
                            'تذكرني',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary2,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              Routes.forgotPassword,
                            ),
                            child: const Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      CustomButton(
                        text: state.isLoading
                            ? 'جاري التحميل...'
                            : 'تسجيل الدخول',
                        height: 50,
                        borderRadius: 50,
                        textColor: AppColors.background,
                        onPressed: state.isLoading
                            ? () {}
                            : (_isValid
                                  ? () {
                                      context.read<UserCubit>().login(
                                        phoneController.text.trim(),
                                        passwordController.text,
                                        rememberMe: _rememberMe,
                                      );
                                    }
                                  : () {}),
                        color: _isValid
                            ? AppColors.primary
                            : const Color(0xFFCCCCCC),
                      ),

                      const SizedBox(height: 16),

                      CustomButton(
                        text: 'إنشاء حساب جديد',
                        height: 50,
                        borderRadius: 50,
                        textColor: AppColors.background,
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.register),
                        color: AppColors.primary2,
                        icon: Icons.person_add_alt_1_outlined,
                      ),

                      const SizedBox(height: 14),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.home,
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: Text(
                          'تصفح المنتجات كزائر',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,

                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneField() {
    return CustomTextField(
      controller: phoneController,
      hintText: 'رقم الهاتف',
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      rightWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              children: [
                const Text(
                  '+962',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🇯🇴', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}
