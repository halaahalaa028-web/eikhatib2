// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/profile/logic/security_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BiometricGate extends StatefulWidget {
  final Widget child;
  const BiometricGate({super.key, required this.child});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate>
    with WidgetsBindingObserver {
  bool _isAuthorized = false;
  bool _isLockEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app goes to background, we reset authorization if biometrics are enabled
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isLockEnabled) {
        setState(() => _isAuthorized = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isLockEnabled && !_isAuthorized) {
        _authenticate();
      }
    }
  }

  void _checkInitialState() {
    final securityCubit = context.read<SecurityCubit>();
    _isLockEnabled = securityCubit.state.isBiometricsEnabled;
    if (_isLockEnabled) {
      _authenticate();
    } else {
      setState(() => _isAuthorized = true);
    }
  }

  Future<void> _authenticate() async {
    final securityCubit = context.read<SecurityCubit>();
    final success = await securityCubit.authenticate();
    if (success) {
      setState(() => _isAuthorized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SecurityCubit, SecurityState>(
      listenWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.isBiometricsEnabled != curr.isBiometricsEnabled,
      listener: (context, state) {
        if (!state.isLoading) {
          _isLockEnabled = state.isBiometricsEnabled;
          // If just finished loading and biometrics are enabled, trigger auth
          if (_isLockEnabled && !_isAuthorized) {
            _authenticate();
          }
        }
      },
      builder: (context, state) {
        // While loading initial settings, show a clean splash-like state
        if (state.isLoading && !_isAuthorized) {
          return _buildSplashState();
        }

        return _isAuthorized ? widget.child : _buildLockScreen();
      },
    );
  }

  Widget _buildSplashState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildLockScreen() {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E),
                  AppColors.primary.withOpacity(0.8),
                  const Color(0xFF16213E),
                ],
              ),
            ),
          ),

          // Abstract shapes for premium feel
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(seconds: 1),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: const FaIcon(
                            FontAwesomeIcons.fingerprint,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'خزنة الخطيب الآمنة',
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      'يرجى تأكيد هويتك للوصول لبياناتك',
                      style: GoogleFonts.tajawal(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  ZoomIn(
                    delay: const Duration(milliseconds: 800),
                    child: GestureDetector(
                      onTap: _authenticate,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeIn(
                    delay: const Duration(seconds: 2),
                    child: TextButton(
                      onPressed: _authenticate,
                      child: Text(
                        'اضغط لاستخدام البصمة',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
