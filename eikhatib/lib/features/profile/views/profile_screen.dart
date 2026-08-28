// ignore_for_file: unused_element_parameter, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/logic/user_cubit.dart';
import '../../home/logic/loyalty_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.tajawal(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          if (userState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userState.user;
          if (user == null) {
            return _buildGuestProfile(context);
          }

          return BlocBuilder<LoyaltyCubit, LoyaltyState>(
            builder: (context, loyaltyState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // ── Profile Header ──
                    _buildProfileHeader(
                      context,
                      user,
                      loyaltyState.totalPoints,
                    ),
                    const SizedBox(height: 25),

                    // ── Sections ──
                    _buildSection(
                      context,
                      title: 'الحساب',
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'حسابي',
                          onTap: () =>
                              AppRouter.navigateTo(context, Routes.editProfile),
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'عناويني',
                          onTap: () =>
                              AppRouter.navigateTo(context, Routes.addresses),
                        ),
                        _MenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: 'طلباتي',
                          onTap: () =>
                              AppRouter.navigateTo(context, Routes.orders),
                        ),
                        // _MenuItem(
                        //   icon: Icons.confirmation_number_outlined,
                        //   title: 'العروض والقسائم',
                        //   onTap: () =>
                        //       AppRouter.navigateTo(context, Routes.coupons),
                        //   badge: '3 جديدة',
                        // ),
                        // _MenuItem(
                        //   icon: Icons.stars_rounded,
                        //   title: 'نقاطي',
                        //   onTap: () => AppRouter.navigateTo(
                        //     context,
                        //     Routes.loyaltyPoints,
                        //   ),
                        //   trailing: Text(
                        //     '${loyaltyState.totalPoints} نقطة',
                        //     style: GoogleFonts.tajawal(
                        //       fontWeight: FontWeight.bold,
                        //       color: AppColors.primary,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    _buildSection(
                      context,
                      title: 'الأمان والإعدادات',
                      items: [
                        _MenuItem(
                          icon: Icons.security_outlined,
                          title: 'إعدادات الأمان',
                          onTap: () => AppRouter.navigateTo(
                            context,
                            Routes.securitySettings,
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.person_add_alt_1_outlined,
                          title: 'دعوة صديق',
                          onTap: () => _showInviteFriendDialog(context),
                          highlight: true,
                        ),
                      ],
                    ),

                    _buildSection(
                      context,
                      title: 'الدعم',
                      items: [
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'مركز المساعدة',
                          onTap: () =>
                              AppRouter.navigateTo(context, Routes.helpCenter),
                        ),
                        _MenuItem(
                          icon: Icons.description_outlined,
                          title: 'شروط الاستخدام والخصوصية',
                          onTap: () => AppRouter.navigateTo(
                            context,
                            Routes.termsAndPrivacy,
                          ),
                        ),
                      ],
                    ),

                    // ── Logout & Delete Account ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _MenuItem(
                              icon: Icons.logout_rounded,
                              title: 'تسجيل الخروج',
                              color: Colors.orange.shade800,
                              showArrow: false,
                              onTap: () {
                                context.read<UserCubit>().logout();
                                AppRouter.navigateTo(context, Routes.login);
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade100),
                            _MenuItem(
                              icon: Icons.delete_forever_rounded,
                              title: 'حذف الحساب نهائياً',
                              color: Colors.red.shade600,
                              showArrow: false,
                              onTap: () => _showDeleteAccountDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── App Version ──
                    Text(
                      'الإصدار 1.0.0',
                      style: GoogleFonts.tajawal(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user, int points) {
    // Loyalty Tier Logic
    String tierName = 'عضو بريميوم';
    Color tierColor = AppColors.primary;
    LinearGradient tierGradient = LinearGradient(
      colors: [AppColors.primary, AppColors.primary],
    );

    if (points >= 15000) {
      tierName = 'عضو برو (Pro)';
      tierColor = const Color(0xFFFFD700);
      tierGradient = const LinearGradient(
        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      );
    } else if (points >= 5000) {
      tierName = 'عضو VIP';
      tierColor = Colors.amber;
      tierGradient = const LinearGradient(
        colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Profile Pic with Edit
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
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
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: GoogleFonts.tajawal(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.phoneNumber ?? '-',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Tier Badge Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: tierGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: tierColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  tierName,
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 12),
          child: Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 55,
                      endIndent: 20,
                      color: Colors.grey.shade100,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showInviteFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Gradient Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primary, Color(0xFF4A00E0)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'شاركنا مع أحبائك',
                      style: GoogleFonts.tajawal(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'واحصل على رصيد مكافآت إضافي',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Text(
                        'أهلاً بك! انضم إليّ في تطبيق "الخطيب" واستمتع بأفضل تجربة تسوق للمنتجات الغذائية والسلع التموينية في الأردن. جودة عالية وأسعار منافسة وتوصيل سريع لباب بيتك.\n\nحمّل التطبيق الآن:\nhttps://play.google.com/store/apps/details?id=com.elkhatib.app',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Share Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [AppColors.primary, Color(0xFF4A00E0)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ الرابط والرسالة بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            'نسخ ومشاركة الرابط',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'لاحقاً',
                        style: GoogleFonts.tajawal(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(
              'حذف الحساب نهائياً',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف حسابك؟ سيتم مسح كافة بياناتك وسجل طلباتك وعناوينك بشكل نهائي ولا يمكن التراجع عن هذا الإجراء.',
          style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري حذف الحساب...')),
              );
              final success = await context.read<UserCubit>().deleteAccount();
              if (success) {
                AppRouter.navigateTo(context, Routes.login);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('حدث خطأ أثناء حذف الحساب، يرجى المحاولة لاحقاً'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'نعم، احذف حسابي',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Guest Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'مرحباً بك يا زائر',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'سجل الدخول للاستفادة من كافة ميزات التطبيق، متابعة الطلبات وحفظ العناوين.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.login),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: Text(
                    'تسجيل الدخول / إنشاء حساب',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sections for Guest
          _buildSection(
            context,
            title: 'الحساب',
            items: [
              _MenuItem(
                icon: Icons.person_outline_rounded,
                title: 'حسابي',
                onTap: () => _promptGuestLogin(context),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: 'عناويني',
                onTap: () => _promptGuestLogin(context),
              ),
              _MenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'طلباتي',
                onTap: () => _promptGuestLogin(context),
              ),
            ],
          ),

          _buildSection(
            context,
            title: 'الدعم والمعلومات',
            items: [
              _MenuItem(
                icon: Icons.help_outline_rounded,
                title: 'مركز المساعدة',
                onTap: () => AppRouter.navigateTo(context, Routes.helpCenter),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: 'شروط الاستخدام والخصوصية',
                onTap: () =>
                    AppRouter.navigateTo(context, Routes.termsAndPrivacy),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _promptGuestLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'تسجيل الدخول مطلوب',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'يرجى تسجيل الدخول للوصول إلى هذه الصفحة.',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, Routes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تسجيل الدخول',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  final Widget? trailing;
  final Color? color;
  final bool highlight;
  final bool showArrow;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.trailing,
    this.color,
    this.highlight = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: highlight
                      ? AppColors.primary.withOpacity(0.1)
                      : (color?.withOpacity(0.1) ?? Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: highlight
                      ? AppColors.primary
                      : (color ?? Colors.black87),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.tajawal(
                      color: Colors.red.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (trailing != null) trailing!,
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
