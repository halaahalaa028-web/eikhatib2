// ignore_for_file: unused_field, deprecated_member_use

import 'dart:async';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_assets.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/routes/routes.dart';
import 'logic/user_cubit.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with WidgetsBindingObserver {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  String _phone = '';
  String? _name;
  bool _isResetPassword = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (index) => TextEditingController());
    _focusNodes = List.generate(4, (index) => FocusNode());
    WidgetsBinding.instance.addObserver(this);
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phone = args['phone'] ?? '';
      _name = args['name'];
      _isResetPassword = args['isResetPassword'] ?? false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForOtp();
    }
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _checkClipboardForOtp() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data?.text != null &&
        data!.text!.length == 4 &&
        _isNumeric(data.text!)) {
      _fillOtp(data.text!);
    }
  }

  bool _isNumeric(String s) => double.tryParse(s) != null;

  void _fillOtp(String otp) {
    for (int i = 0; i < 4; i++) {
      _otpControllers[i].text = otp[i];
    }
    setState(() {
      _errorMessage = null;
    });

    if (_isValid) {
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    setState(() {
      _errorMessage = null;
    });
    String otpCode = _otpControllers.map((c) => c.text).join();
    if (_isResetPassword) {
      Navigator.pushReplacementNamed(
        context,
        Routes.newPassword,
        arguments: {'phone': _phone, 'otp': otpCode},
      );
    } else {
      context.read<UserCubit>().verifyOtp(_phone, otpCode);
    }
  }

  bool get _isValid => _otpControllers.every((c) => c.text.isNotEmpty);

  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, Routes.login);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // We use WillPopScope to safely handle back button
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            if (mounted) {
              setState(() {
                _errorMessage = 'الكود غير صحيح';
                for (var c in _otpControllers) {
                  c.clear();
                }
                if (_focusNodes.isNotEmpty) {
                  _focusNodes[0].requestFocus();
                }
              });
            }
          } else if (!state.isLoading && state.error == null) {
            if (!_isResetPassword &&
                state.user != null &&
                !state.requiresOtpVerification) {
              final user = state.user!;
              if (user.role == 'driver') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.driverDocs,
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppAssets.otp,
                          height: 120,
                          width: 120,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'رمز التحقق',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لقد أرسلنا رمز المكون من 4 أرقام إلى هاتفك.\nالرجاء إدخاله للمتابعة.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        color: const Color(0xFF757575),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Fields
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _errorMessage != null
                                    ? Colors.red
                                    : AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? Colors.red.shade300
                                        : Colors.grey.shade200,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? Colors.red
                                        : AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                                if (value.isNotEmpty) {
                                  if (index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    _focusNodes[index].unfocus();
                                    if (_isValid) {
                                      _verifyOtp();
                                    }
                                  }
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                                setState(() {});
                              },
                            ),
                          );
                        }),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Paste Chip
                    Center(
                      child: TextButton.icon(
                        onPressed: _checkClipboardForOtp,
                        icon: const Icon(Icons.paste_rounded, size: 18),
                        label: Text(
                          'لصق من الحافظة',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    CustomButton(
                      text: state.isLoading ? 'جاري التحقق...' : 'تحقق',
                      height: 55,
                      borderRadius: 16,
                      textColor: Colors.white,
                      onPressed: state.isLoading
                          ? () {}
                          : (_isValid ? _verifyOtp : () {}),
                      color: _isValid
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),

                    const SizedBox(height: 24),

                    // Resend Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لم يصلك الرمز؟ ',
                          style: GoogleFonts.tajawal(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        _canResend
                            ? GestureDetector(
                                onTap: () {
                                  _startTimer();
                                  context.read<UserCubit>().resendOtp(_phone);
                                },
                                child: Text(
                                  'إعادة إرسال',
                                  style: GoogleFonts.tajawal(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            : Text(
                                'إعادة إرسال خلال 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                style: GoogleFonts.tajawal(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
