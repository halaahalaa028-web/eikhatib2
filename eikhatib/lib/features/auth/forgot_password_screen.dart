import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/routes/routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_update);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (!state.isLoading && state.error == null) {
          // Success, navigate to Reset Status
          final phoneText = _phoneController.text.trim();
          final cleanPhone = phoneText.startsWith('0') ? phoneText.substring(1) : phoneText;
          Navigator.pushReplacementNamed(
            context,
            Routes.resetStatus,
            arguments: {'phone': '+962$cleanPhone'},
          );
        }
      },
      builder: (context, state) {
        final phoneText = _phoneController.text.trim();
        final isPhoneValid = (phoneText.startsWith('0') && phoneText.length == 10) ||
                             (!phoneText.startsWith('0') && phoneText.length == 9);
        final cleanPhone = phoneText.startsWith('0') && phoneText.isNotEmpty ? phoneText.substring(1) : phoneText;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset(
                    AppAssets.forgotpassword,
                    height: 160,
                    width: 160,
                  ),
                  const Text(
                    'نسيت كلمة المرور؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'أدخل رقم هاتفك لتلقي رمز التحقق لإعادة تعيين كلمة المرور',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    controller: _phoneController,
                    hintText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    rightWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.ltr,
                            children: [
                              Text(
                                '+962',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('🇯🇴', style: TextStyle(fontSize: 22)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  CustomButton(
                    text: state.isLoading ? 'جاري الإرسال...' : 'إرسال الرمز',
                    height: 50,
                    borderRadius: 50,
                    textColor: AppColors.background,
                    onPressed:
                        (isPhoneValid && !state.isLoading)
                        ? () => context.read<UserCubit>().forgotPassword(
                            '+962$cleanPhone',
                          )
                        : () {},
                    color: isPhoneValid
                        ? AppColors.primary
                        : const Color(0xFFCCCCCC),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
