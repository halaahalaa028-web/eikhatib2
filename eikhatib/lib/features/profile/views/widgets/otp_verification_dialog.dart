// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:eikhatib/features/profile/logic/security_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String title;
  final String initialPhoneNumber;
  final Function(String) onVerify;

  const OtpVerificationDialog({
    super.key,
    required this.title,
    required this.initialPhoneNumber,
    required this.onVerify,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  int _currentStep = 0; // 0: Phone Confirmation, 1: OTP Verification
  late TextEditingController _phoneController;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  // Countdown timer logic
  Timer? _resendTimer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _resendTimer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  void _sendOTP() async {
    if (_phoneController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final success = await context.read<SecurityCubit>().sendSecureOtp();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (success) {
        _currentStep = 1;
        _startResendTimer();
        // Autofocus first field
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNodes[0].requestFocus();
        });
      }
    });
  }

  void _verifyAndConfirm() async {
    if (_otp.length < 6) return;

    setState(() => _isLoading = true);

    final success = await context.read<SecurityCubit>().verifySecureOtp(_otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      widget.onVerify(_otp);
      Navigator.pop(context);
    } else {
      // Clear OTP on failure
      for (var c in _otpControllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      // Visual feedback for error
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SecurityCubit, SecurityState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!, style: GoogleFonts.tajawal()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideInRight(from: 30, child: child),
                ),
                child: _currentStep == 0 ? _buildPhoneStep() : _buildOtpStep(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      key: const ValueKey(0),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Color(0xFF25D366),
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.grey,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'تأكيد الدخول عبر الواتساب',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            color: const Color(0xFF25D366),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'سيصلك كود تحقق سري على الواتساب المربوط بهذا الرقم لضمان أعلى مستويات الأمان.',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: Colors.blueGrey,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.phoneFlip,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  enabled: false,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),

                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF25D366).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    'ارسل الكود الآن',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() => _currentStep = 0),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Color(0xFF25D366),
              size: 40,
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'أدخل رمز التحقق',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'تم إرسال الرمز إلى الواتساب الخاص بك:\n${_phoneController.text}',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          textDirection: TextDirection.ltr,
          children: List.generate(6, (index) {
            return Container(
              width: 52,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFFBFBFE),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2.5,
                    ),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    if (index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _focusNodes[index].unfocus();
                      _verifyAndConfirm();
                    }
                  } else {
                    if (index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        _isLoading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : Column(
                children: [
                  Text(
                    _canResend ? 'لم يصلك الكود؟' : 'يمكنك إعادة الإرسال خلال',
                    style: GoogleFonts.tajawal(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _canResend
                      ? TextButton.icon(
                          onPressed: _sendOTP,
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            size: 16,
                          ),
                          label: Text(
                            'إعادة إرسال الكود عبر واتساب',
                            style: GoogleFonts.tajawal(
                              color: const Color(0xFF25D366),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF25D366,
                            ).withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(_secondsRemaining / 60).floor().toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
        const SizedBox(height: 16),
      ],
    );
  }
}
