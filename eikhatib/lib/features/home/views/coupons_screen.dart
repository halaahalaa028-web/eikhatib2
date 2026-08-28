import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:eikhatib/core/theme/colors.dart';
import '../logic/coupons_cubit.dart';
import '../data/models/coupon_model.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'القسائم الشرائية',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.tajawal(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'صالح'),
                Tab(text: 'مستخدم'),
                Tab(text: 'منتهي'),
              ],
            ),
          ),
          body: BlocBuilder<CouponsCubit, CouponsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<CouponsCubit>().loadCoupons(),
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: TabBarView(
                  children: [
                    _buildTabContent(
                      state.coupons.where((c) => c.isValid).toList(),
                    ),
                    _buildTabContent(
                      state.coupons.where((c) => c.isUsed).toList(),
                    ),
                    _buildTabContent(
                      state.coupons
                          .where((c) => c.isExpired && !c.isUsed)
                          .toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(List<CouponModel> coupons) {
    if (coupons.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _CouponTicket(coupon: coupons[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 400, // Sufficient height to allow scrolling
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد قسائم في هذا القسم',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponTicket extends StatelessWidget {
  final CouponModel coupon;

  const _CouponTicket({required this.coupon});

  @override
  Widget build(BuildContext context) {
    bool isInactive = !coupon.isValid;
    Color themeColor = isInactive ? Colors.grey : AppColors.primary;

    return Stack(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Right Side (Discount Info) ──
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coupon.isPercentage
                          ? '${coupon.discount.toInt()}%'
                          : '${coupon.discount.toInt()}',
                      style: GoogleFonts.tajawal(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: themeColor,
                        height: 1,
                      ),
                    ),
                    Text(
                      coupon.isPercentage ? 'خصم' : 'JOD',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Middle (Divider / Ticket Hole Effect) ──
              _TicketDivider(color: themeColor, isInactive: isInactive),

              // ── Left Side (Content) ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: themeColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              coupon.code,
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (coupon.isValid) _buildCopyButton(context),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coupon.title,
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isInactive
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        coupon.description,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            coupon.isUsed
                                ? Icons.check_circle_outline
                                : Icons.access_time_rounded,
                            size: 14,
                            color: coupon.isUsed
                                ? Colors.green
                                : (coupon.isExpired
                                      ? Colors.red
                                      : Colors.orange),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            coupon.isUsed
                                ? 'تم استخدامه'
                                : (coupon.isExpired
                                      ? 'القسيمة منتهية'
                                      : 'ينتهي: ${DateFormat('yyyy/MM/dd', 'ar').format(coupon.expiryDate)}'),
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: coupon.isUsed
                                  ? Colors.green
                                  : (coupon.isExpired
                                        ? Colors.red
                                        : Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Circular Cuts (Ticket effect)
        Positioned(right: 90, top: -10, child: _TicketNotch()),
        Positioned(right: 90, bottom: -10, child: _TicketNotch()),
      ],
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: coupon.code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم نسخ الكود: ${coupon.code}',
              textAlign: TextAlign.center,
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
      ),
    );
  }
}

class _TicketNotch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  final Color color;
  final bool isInactive;

  const _TicketDivider({required this.color, required this.isInactive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        10,
        (index) => Container(
          width: 2,
          height: 6,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: color.withOpacity(0.2),
        ),
      ),
    );
  }
}
