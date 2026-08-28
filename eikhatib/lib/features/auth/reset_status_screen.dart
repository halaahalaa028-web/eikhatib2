import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/routes.dart';

class ResetStatusScreen extends StatefulWidget {
  const ResetStatusScreen({super.key});

  @override
  State<ResetStatusScreen> createState() => _ResetStatusScreenState();
}

class _ResetStatusScreenState extends State<ResetStatusScreen> {
  String _phone = '';
  bool _checking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phone = args['phone'] ?? '';
    }
  }

  Future<void> _checkStatus() async {
    if (_phone.isEmpty) return;
    setState(() => _checking = true);
    
    final status = await context.read<UserCubit>().checkResetStatus(_phone);
    
    setState(() => _checking = false);
    
    if (!mounted) return;

    if (status == 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت الموافقة على طلبك بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        Routes.newPassword,
        arguments: {
          'phone': _phone,
          'otp': 'APPROVED',
        },
      );
    } else if (status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('طلبك ما زال بانتظار موافقة الإدارة.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد طلب نشط لاستعادة كلمة المرور لهذا الرقم.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.vpn_key_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'طلبك بانتظار الموافقة',
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تم تسجيل طلب استعادة كلمة المرور لـ $_phone بنجاح.\nيرجى التواصل مع الإدارة للموافقة على طلبك، ثم اضغط على زر التحقق بالأسفل للاستمرار.',
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checking ? null : _checkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _checking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'تحديث حالة الطلب',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'رجوع لتسجيل الدخول',
                    style: GoogleFonts.tajawal(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
