import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/routes/routes.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_update);
    _confirmPasswordController.addListener(_update);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _phone = '';
  String _otp = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phone = args['phone'] ?? '';
      _otp = args['otp'] ?? '';
    }
  }

  bool get _isValid =>
      _passwordController.text.length >= 6 &&
      _passwordController.text == _confirmPasswordController.text;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (!state.isLoading && state.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تغيير كلمة المرور بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'كلمة مرور جديدة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الرجاء إدخال كلمة المرور الجديدة الخاصة بك',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'كلمة المرور الجديدة',
                    obscureText: _obscurePassword,
                    rightWidget: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.lock,
                        color: Color(0xFF222222),
                        size: 24,
                      ),
                    ),
                    leftWidget: IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'تأكيد كلمة المرور',
                    obscureText: _obscureConfirmPassword,
                    rightWidget: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.lock,
                        color: Color(0xFF222222),
                        size: 24,
                      ),
                    ),
                    leftWidget: IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  if (_passwordController.text.isNotEmpty &&
                      _confirmPasswordController.text.isNotEmpty &&
                      _passwordController.text !=
                          _confirmPasswordController.text)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'كلمات المرور غير متطابقة',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 48),
                  CustomButton(
                    text: state.isLoading ? 'جاري الحفظ...' : 'تأكيد وحفظ',
                    height: 50,
                    borderRadius: 50,
                    textColor: AppColors.background,
                    onPressed: (_isValid && !state.isLoading)
                        ? () => context.read<UserCubit>().resetPassword(
                            phone: _phone,
                            otp: _otp,
                            newPassword: _passwordController.text,
                          )
                        : () {},
                    color: _isValid
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
