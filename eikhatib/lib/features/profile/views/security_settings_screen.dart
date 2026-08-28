// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../logic/security_cubit.dart';
import '../../auth/logic/user_cubit.dart';
import '../../../core/routes/routes.dart';
import 'widgets/otp_verification_dialog.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'إعدادات الأمان',
          style: GoogleFonts.tajawal(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<SecurityCubit, SecurityState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('كلمة المرور'),
                _buildSecurityTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'تغيير كلمة المرور',
                  subtitle: 'تحديث كلمة المرور الخاصة بك بانتظام',
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.changePassword),
                ),
                const SizedBox(height: 25),
                _buildSectionTitle('المصادقة الثنائية'),
                _buildSecuritySwitchTile(
                  icon: Icons.phonelink_lock_rounded,
                  title: 'المصادقة الثنائية (2FA)',
                  subtitle: 'حماية حسابك برمز يصل لهاتفك عند الطلب',
                  value: state.is2FAEnabled,
                  onChanged: (val) {
                    final phoneNumber = context.read<UserCubit>().state.user?.phoneNumber ?? '';
                    _handle2FAToggle(context, val, phoneNumber);
                  },
                ),
                if (!state.is2FAEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: Text(
                      'تُضيف المصادقة الثنائية طبقة أمان إضافية لحسابك من خلال اشتراط رمز تحقق عند القيام بعمليات شراء جديدة.',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                const SizedBox(height: 25),
                _buildSectionTitle('الوصول السريع'),
                _buildSecuritySwitchTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'بصمة الإصبع',
                  subtitle: 'استخدم البصمة لفتح التطبيق بسرعة',
                  value: state.isBiometricsEnabled,
                  enabled: state.isDeviceSupported,
                  onChanged: (val) async {
                    final cubit = context.read<SecurityCubit>();
                    final success = await cubit.toggleBiometrics(val);
                    if (!success && val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فشل تفعيل البصمة')),
                      );
                    }
                  },
                ),
                if (!state.isDeviceSupported)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 10),
                    child: Text(
                      'جهازك لا يدعم المصادقة الحيوية.',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handle2FAToggle(BuildContext context, bool value, String currentPhone) {
    if (value) {
      // Show multi-step 2FA setup dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => OtpVerificationDialog(
          title: 'إعداد المصادقة الثنائية',
          initialPhoneNumber: currentPhone,
          onVerify: (otp) {
            context.read<SecurityCubit>().toggle2FA(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تفعيل المصادقة الثنائية بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      );
    } else {
      context.read<SecurityCubit>().toggle2FA(false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 5),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            color: const Color.fromARGB(255, 95, 95, 95),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSecuritySwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            color: const Color.fromARGB(255, 95, 95, 95),
          ),
        ),
        activeColor: AppColors.primary,
        contentPadding: EdgeInsets.zero,
        inactiveThumbColor: Colors.grey, // لون الدائرة
        inactiveTrackColor: Colors.grey.shade300, // لون الخلفية
      ),
    );
  }
}
