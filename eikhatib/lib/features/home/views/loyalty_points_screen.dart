// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';
import '../logic/loyalty_cubit.dart';
import '../logic/coupons_cubit.dart';
import '../data/models/loyalty_point_model.dart';
import '../data/models/coupon_model.dart';

class LoyaltyPointsScreen extends StatelessWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'نقاط الولاء',
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
        ),
        body: BlocBuilder<LoyaltyCubit, LoyaltyState>(
          builder: (context, state) {
            if (state.isLoading && state.history.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<LoyaltyCubit>().loadLoyaltyData(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header / Total Points Card
                  SliverToBoxAdapter(
                    child: _buildHeaderCard(context, state.totalPoints),
                  ),

                  // Redemption Progress / Info
                  SliverToBoxAdapter(
                    child: _buildRedemptionInfo(state.totalPoints),
                  ),

                  // History Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            size: 20,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'سجل النقاط',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // History List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildHistoryItem(state.history[index]);
                      }, childCount: state.history.length),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, int totalPoints) {
    bool canRedeem = totalPoints >= 3000;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withBlue(220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              if (canRedeem)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'جاهز للتحويل ✨',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'رصيد نقاطك الحالي',
            style: GoogleFonts.tajawal(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            totalPoints.toString(),
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'نقطة',
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: canRedeem ? () => _handleRedemption(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withOpacity(0.4),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                canRedeem
                    ? 'تحويل النقاط إلى قسيمة خصم'
                    : 'احصل على 3000 نقطة للتحويل',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRedemption(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'تأكيد تحويل النقاط',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'سيتم خصم 3000 نقطة من رصيدك مقابل قسيمة خصم 2 دينار.',
            style: GoogleFonts.tajawal(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform redemption
                context.read<LoyaltyCubit>().redeemPoints();

                // Add coupon to coupons cubit
                final newCoupon = CouponModel(
                  id: 'redem_${DateTime.now().millisecondsSinceEpoch}',
                  code: 'REDEM-${DateFormat('ssmm').format(DateTime.now())}',
                  title: 'قسيمة نقاط الولاء',
                  description: 'قسيمة ناتجة عن تحويل 3000 نقطة ولاء.',
                  discount: 2,
                  isPercentage: false,
                  expiryDate: DateTime.now().add(const Duration(days: 30)),
                );
                context.read<CouponsCubit>().addCoupon(newCoupon);

                Navigator.pop(dialogCtx);

                // Show Success Message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحويل النقاط بنجاح! تفقد قسم القسائم.',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'تحويل الآن',
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionInfo(int totalPoints) {
    double progress = (totalPoints / 3000).clamp(0.0, 1.0);
    int remaining = (3000 - totalPoints).clamp(0, 3000);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تقدمك نحو القسيمة القادمة',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 10,
            ),
          ),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'متبقي لك $remaining نقطة للحصول على قسيمة 2 JOD',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(LoyaltyPointModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image or Icon
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: item.isEarned
                  ? Colors.green.withOpacity(0.05)
                  : Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.imageUrl != null
                ? AppCachedImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    errorWidget: Container(
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Icon(
                    item.isEarned
                        ? Icons.add_circle_outline
                        : Icons.redeem_rounded,
                    color: item.isEarned ? Colors.green : Colors.red,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Text(
                  item.description,
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy/MM/dd | hh:mm a', 'ar').format(item.date),
                  style: GoogleFonts.tajawal(
                    fontSize: 9,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${item.isEarned ? '+' : '-'}${item.points}',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: item.isEarned ? Colors.green : Colors.red,
                ),
              ),
              Text(
                'نقطة',
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
