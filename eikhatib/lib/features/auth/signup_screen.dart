// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/routes/routes.dart';
import 'logic/user_cubit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _storeNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'user'; // 'user' or 'driver'

  File? _logoImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    _storeNameController.addListener(_update);
    _firstNameController.addListener(_update);
    _lastNameController.addListener(_update);
    _phoneController.addListener(_update);
    _passwordController.addListener(_update);
    _confirmPasswordController.addListener(_update);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final phoneText = _phoneController.text.trim();
    final isPhoneValid =
        (phoneText.startsWith('0') && phoneText.length == 10) ||
        (!phoneText.startsWith('0') && phoneText.length == 9);
    bool basicValid =
        (_selectedRole == 'user'
            ? _storeNameController.text.isNotEmpty
            : true) &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        isPhoneValid &&
        _passwordController.text.length >= 6 &&
        _passwordController.text == _confirmPasswordController.text &&
        _agreeToTerms;
    return basicValid;
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
          Navigator.pushReplacementNamed(context, Routes.waitingApproval);
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
                  height: MediaQuery.of(context).size.height * 0.3,

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
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Spacer(),
                          Row(
                            children: [
                              const Text(
                                'إنشاء حساب جديد',
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
                                'الرجاء تعبئة بياناتك أدناه للإنضمام إلينا.',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Container
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // // Role Selector
                      // Container(
                      //   padding: const EdgeInsets.all(4),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.shade100,
                      //     borderRadius: BorderRadius.circular(50),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: GestureDetector(
                      //           onTap: () => setState(() => _selectedRole = 'user'),
                      //           child: AnimatedContainer(
                      //             duration: const Duration(milliseconds: 200),
                      //             padding: const EdgeInsets.symmetric(vertical: 12),
                      //             decoration: BoxDecoration(
                      //               color: _selectedRole == 'user'
                      //                   ? AppColors.primary
                      //                   : Colors.transparent,
                      //               borderRadius: BorderRadius.circular(50),
                      //               boxShadow: _selectedRole == 'user'
                      //                   ? [
                      //                       BoxShadow(
                      //                         color: AppColors.primary.withOpacity(
                      //                           0.3,
                      //                         ),
                      //                         blurRadius: 10,
                      //                         offset: const Offset(0, 4),
                      //                       ),
                      //                     ]
                      //                   : [],
                      //             ),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 Icon(
                      //                   Icons.person_rounded,
                      //                   size: 18,
                      //                   color: _selectedRole == 'user'
                      //                       ? Colors.white
                      //                       : Colors.grey.shade600,
                      //                 ),
                      //                 const SizedBox(width: 8),
                      //                 Text(
                      //                   'مستخدم عادي',
                      //                   style: TextStyle(
                      //                     color: _selectedRole == 'user'
                      //                         ? Colors.white
                      //                         : Colors.grey.shade600,
                      //                     fontWeight: FontWeight.bold,
                      //                     fontSize: 14,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: GestureDetector(
                      //           onTap: () =>
                      //               setState(() => _selectedRole = 'driver'),
                      //           child: AnimatedContainer(
                      //             duration: const Duration(milliseconds: 200),
                      //             padding: const EdgeInsets.symmetric(vertical: 12),
                      //             decoration: BoxDecoration(
                      //               color: _selectedRole == 'driver'
                      //                   ? AppColors.primary
                      //                   : Colors.transparent,
                      //               borderRadius: BorderRadius.circular(50),
                      //               boxShadow: _selectedRole == 'driver'
                      //                   ? [
                      //                       BoxShadow(
                      //                         color: AppColors.primary.withOpacity(
                      //                           0.3,
                      //                         ),
                      //                         blurRadius: 10,
                      //                         offset: const Offset(0, 4),
                      //                       ),
                      //                     ]
                      //                   : [],
                      //             ),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 Icon(
                      //                   Icons.local_shipping_rounded,
                      //                   size: 18,
                      //                   color: _selectedRole == 'driver'
                      //                       ? Colors.white
                      //                       : Colors.grey.shade600,
                      //                 ),
                      //                 const SizedBox(width: 8),
                      //                 Text(
                      //                   'أنا سائق',
                      //                   style: TextStyle(
                      //                     color: _selectedRole == 'driver'
                      //                         ? Colors.white
                      //                         : Colors.grey.shade600,
                      //                     fontWeight: FontWeight.bold,
                      //                     fontSize: 14,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 24),

                      // Store Logo Picker
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  image: _logoImage != null
                                      ? DecorationImage(
                                          image: FileImage(_logoImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _logoImage == null
                                    ? Icon(
                                        _selectedRole == 'driver'
                                            ? Icons.person_outline_rounded
                                            : Icons.storefront_outlined,
                                        size: 40,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedRole == 'driver'
                            ? 'صورتك الشخصية'
                            : 'شعار المحل',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_selectedRole == 'user') ...[
                        CustomTextField(
                          controller: _storeNameController,
                          hintText: 'اسم المحل (اختياري)',
                          rightWidget: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _firstNameController,
                              hintText: 'الاسم الأول...',
                              rightWidget: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _lastNameController,
                              hintText: 'اسم العائلة...',
                              rightWidget: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                                      color: Colors.black,
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
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'كلمة المرور',
                        obscureText: _obscurePassword,
                        rightWidget: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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

                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: 'تأكيد كلمة المرور',
                        obscureText: _obscureConfirm,
                        rightWidget: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.lock_outline),
                        ),
                        leftWidget: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                      ),

                      if (_passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty &&
                          _passwordController.text !=
                              _confirmPasswordController.text)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, right: 8.0),
                          child: Text(
                            'كلمات المرور غير متطابقة',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                      const SizedBox(height: 16),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (v) =>
                                setState(() => _agreeToTerms = v ?? false),
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                Routes.termsAndPrivacy,
                              ),
                              child: RichText(
                                textDirection: TextDirection.rtl,
                                text: TextSpan(
                                  text: 'أوافق على ',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFF222222),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'الشروط والأحكام ',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' و ',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'سياسة الخصوصية',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: state.isLoading
                            ? 'جاري التحميل...'
                            : 'انشاء حساب',
                        height: 50,
                        borderRadius: 50,
                        textColor: AppColors.background,
                        onPressed: state.isLoading
                            ? () {}
                            : (_isValid
                                  ? () {
                                      final storeName =
                                          _selectedRole == 'driver'
                                          ? '${_firstNameController.text} ${_lastNameController.text}'
                                          : _storeNameController.text;
                                      context.read<UserCubit>().register(
                                        storeName: storeName,
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        phone:
                                            '+962${_phoneController.text.trim().startsWith('0') ? _phoneController.text.trim().substring(1) : _phoneController.text.trim()}',
                                        password: _passwordController.text,
                                        logoImage: _logoImage,
                                        role: _selectedRole,
                                      );
                                    }
                                  : () {}),
                        color: _isValid
                            ? AppColors.primary
                            : const Color(0xFFCCCCCC),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'هل لديك حساب؟ ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.home,
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'المتابعة وتصفح التطبيق كزائر',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
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
}
