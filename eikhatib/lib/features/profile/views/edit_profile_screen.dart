import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../auth/logic/user_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _storeNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserCubit>().state.user;
    _storeNameController = TextEditingController(text: user?.name ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    
    String cleanPhone = user?.phoneNumber ?? '';
    if (cleanPhone.startsWith('+962')) {
      cleanPhone = cleanPhone.substring(4);
    }
    _phoneController = TextEditingController(text: cleanPhone);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
          'تعديل الحساب',
          style: GoogleFonts.tajawal(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const SizedBox();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Image with verification seal
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        image: user.fullProfileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user.fullProfileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user.fullProfileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    if (user.isPhoneVerified ?? false)
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildTextField(
                  label: 'اسم المحل',
                  controller: _storeNameController,
                  icon: Icons.storefront_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'الاسم الأول',
                  controller: _firstNameController,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'اسم العائلة',
                  controller: _lastNameController,
                  icon: Icons.people_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'رقم الهاتف',
                  controller: _phoneController,
                  icon: Icons.phone_iphone_rounded,
                  enabled: true,
                  prefixWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.phone_iphone_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        '+962',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('🇯🇴', style: TextStyle(fontSize: 18)),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 1,
                        height: 20,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final phoneText = _phoneController.text.trim();
                            final isPhoneValid = (phoneText.startsWith('0') && phoneText.length == 10) ||
                                                 (!phoneText.startsWith('0') && phoneText.length == 9);
                            if (!isPhoneValid) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('الرجاء إدخال رقم هاتف صحيح (9 أو 10 أرقام)'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            await context.read<UserCubit>().updateProfile(
                              storeName: _storeNameController.text,
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              phoneNumber: phoneText,
                            );

                            if (context.mounted) {
                              final error = context.read<UserCubit>().state.error;
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تحديث البيانات بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'حفظ التعديلات',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required IconData icon,
    bool enabled = true,
    Widget? suffixIcon,
    Widget? prefixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            enabled: enabled,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.black : Colors.grey.shade600,
            ),
            decoration: InputDecoration(
              prefixIcon: prefixWidget ?? Icon(icon, color: AppColors.primary, size: 22),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
