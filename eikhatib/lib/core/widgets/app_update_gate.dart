import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/colors.dart';

class AppUpdateGate extends StatefulWidget {
  final Widget child;
  const AppUpdateGate({super.key, required this.child});

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _showBlockingUI = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When the app is resumed (warm start), check if there is an update
    // or if an update was in progress and needs resumption.
    if (state == AppLifecycleState.resumed) {
      debugPrint('AppUpdateGate: App resumed, checking for update availability...');
      _checkUpdate();
    }
  }

  Future<void> _checkUpdate() async {
    if (!Platform.isAndroid) return;

    debugPrint('AppUpdateGate: [Start] Checking for updates...');
    setState(() {
      _isLoading = true;
    });

    try {
      final info = await InAppUpdate.checkForUpdate();
      debugPrint('AppUpdateGate: [Info] Update checked successfully.');
      debugPrint('AppUpdateGate: [Info] updateAvailability: ${info.updateAvailability}');
      debugPrint('AppUpdateGate: [Info] immediateUpdateAllowed: ${info.immediateUpdateAllowed}');
      debugPrint('AppUpdateGate: [Info] flexibleUpdateAllowed: ${info.flexibleUpdateAllowed}');
      debugPrint('AppUpdateGate: [Info] availableVersionCode: ${info.availableVersionCode}');
      debugPrint('AppUpdateGate: [Info] installStatus: ${info.installStatus}');

      // Handle downloaded status (if a flexible update was downloaded previously)
      if (info.installStatus == InstallStatus.downloaded) {
        debugPrint('AppUpdateGate: [Status] An update is already downloaded. Completing flexible update...');
        await InAppUpdate.completeFlexibleUpdate();
        return;
      }

      if (info.updateAvailability == UpdateAvailability.updateAvailable ||
          info.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        
        debugPrint('AppUpdateGate: [Action] Triggering performImmediateUpdate...');
        final result = await InAppUpdate.performImmediateUpdate();
        debugPrint('AppUpdateGate: [Result] Immediate update response: $result');

        if (result == AppUpdateResult.success) {
          debugPrint('AppUpdateGate: [Success] Update completed successfully.');
          if (mounted) {
            setState(() {
              _showBlockingUI = false;
              _errorMessage = null;
            });
          }
        } else if (result == AppUpdateResult.userDeniedUpdate) {
          debugPrint('AppUpdateGate: [Warning] Update cancelled by user.');
          if (mounted) {
            setState(() {
              _showBlockingUI = true;
              _errorMessage = 'التحديث إلزامي لمتابعة استخدام التطبيق. يرجى التحديث الآن.';
            });
          }
        } else {
          debugPrint('AppUpdateGate: [Error] Update failed.');
          if (mounted) {
            setState(() {
              _showBlockingUI = true;
              _errorMessage = 'فشل تثبيت التحديث. يرجى التأكد من اتصالك بالإنترنت والمحاولة مجدداً.';
            });
          }
        }
      } else {
        debugPrint('AppUpdateGate: [Status] App is up-to-date.');
        if (mounted) {
          setState(() {
            _showBlockingUI = false;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      final errorStr = e.toString();
      debugPrint('AppUpdateGate: [Exception] Error during update check: $errorStr');
      
      // Check if error is related to debug environment/no Play Store signature match (Install Error -10)
      if (errorStr.contains('code: -10') || 
          errorStr.contains('API_NOT_AVAILABLE') || 
          errorStr.contains('Install Error(-10)') ||
          errorStr.contains('package not found')) {
        debugPrint('AppUpdateGate: [Bypass] Debug environment or side-loaded APK detected. Bypassing update enforcement.');
        if (mounted) {
          setState(() {
            _showBlockingUI = false;
            _errorMessage = null;
          });
        }
      } else {
        // If it's a general network failure, do not brick the app.
        // But if the blocking UI is already active (i.e. user had cancelled a verified update before), we keep it.
        debugPrint('AppUpdateGate: [Status] Network or server error. Bypassing check to avoid bricking.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showBlockingUI) {
      return _buildBlockingUI();
    }
    return widget.child;
  }

  Widget _buildBlockingUI() {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching app aesthetics
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E),
                  AppColors.primary.withOpacity(0.85),
                  const Color(0xFF16213E),
                ],
              ),
            ),
          ),

          // Abstract decorations for a premium look
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.white.withOpacity(0.03),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity(0.02),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium animated update icon
                    ZoomIn(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.circleUp,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Title
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'يتوفر تحديث جديد للمتجر',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        _errorMessage ?? 'هناك إصدار جديد متاح على متجر Google Play. يرجى تحديث التطبيق للمتابعة بشكل آمن والاستفادة من الميزات الجديدة.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Action buttons
                    if (_isLoading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    else ...[
                      // "Update Now" button
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _checkUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              shadowColor: AppColors.primary.withOpacity(0.4),
                            ),
                            child: Text(
                              'تحديث الآن',
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // "Exit" button
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: TextButton(
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          child: Text(
                            'إغلاق التطبيق',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
