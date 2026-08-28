// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../logic/home_cubit.dart';
import '../../logic/home_state.dart';

class OffersAndRewardsSection extends StatelessWidget {
  const OffersAndRewardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row(
          //   children: [
          //     Text(
          //       'عروض ومكافآت',
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),
          // Row(
          //   children: [
          //     Expanded(
          //       child: BlocBuilder<CouponsCubit, CouponsState>(
          //         builder: (context, state) {
          //           return InkWell(
          //             onTap: () =>
          //                 AppRouter.navigateTo(context, Routes.coupons),
          //             borderRadius: BorderRadius.circular(12),
          //             child: Container(
          //               height: 80,
          //               padding: const EdgeInsets.all(12),
          //               decoration: BoxDecoration(
          //                 gradient: const LinearGradient(
          //                   colors: [
          //                     AppColors.primary,
          //                     Color.fromARGB(255, 12, 27, 238),
          //                   ],
          //                   begin: Alignment.topLeft,
          //                   end: Alignment.bottomRight,
          //                 ),
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               child: Row(
          //                 children: [
          //                   Container(
          //                     padding: const EdgeInsets.all(6),
          //                     decoration: const BoxDecoration(
          //                       color: Colors.white,
          //                       shape: BoxShape.circle,
          //                     ),
          //                     child: const Icon(
          //                       Icons.local_offer,
          //                       color: AppColors.primary,
          //                       size: 16,
          //                     ),
          //                   ),
          //                   const SizedBox(width: 5),
          //                   Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       const Text(
          //                         'القسائم',
          //                         style: TextStyle(
          //                           color: Colors.white,
          //                           fontSize: 13,
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                       ),
          //                       Text(
          //                         '${state.coupons.length} متاحة',
          //                         style: const TextStyle(
          //                           color: Colors.white70,
          //                           fontSize: 11,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                   const Spacer(),
          //                   const Text(
          //                     '%',
          //                     style: TextStyle(
          //                       color: Colors.white,
          //                       fontSize: 20,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: BlocBuilder<LoyaltyCubit, LoyaltyState>(
          //         builder: (context, state) {
          //           return InkWell(
          //             onTap: () =>
          //                 AppRouter.navigateTo(context, Routes.loyaltyPoints),
          //             borderRadius: BorderRadius.circular(12),
          //             child: Container(
          //               padding: const EdgeInsets.all(12),
          //               height: 80,
          //               decoration: BoxDecoration(
          //                 gradient: const LinearGradient(
          //                   colors: [AppColors.primary2, Colors.deepOrange],
          //                   begin: Alignment.topLeft,
          //                   end: Alignment.bottomRight,
          //                 ),
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               child: Row(
          //                 children: [
          //                   Container(
          //                     padding: const EdgeInsets.all(6),
          //                     decoration: const BoxDecoration(
          //                       color: Colors.white,
          //                       shape: BoxShape.circle,
          //                     ),
          //                     child: const Icon(
          //                       Icons.star,
          //                       color: Color(0xFFFFA000),
          //                       size: 16,
          //                     ),
          //                   ),
          //                   const SizedBox(width: 5),
          //                   Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       const Text(
          //                         'النقاط',
          //                         style: TextStyle(
          //                           color: Colors.white,
          //                           fontSize: 13,
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                       ),
          //                       Text(
          //                         '${state.totalPoints} نقطة',
          //                         style: const TextStyle(
          //                           color: Colors.white70,
          //                           fontSize: 11,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                   const Spacer(),
          //                   const Icon(Icons.more_horiz, color: Colors.white),
          //                 ],
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),

          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              // نجيب أول صورة banner من السيرفر بترتيب الأولوية:
              // 1) banner بـ linkTarget == 'offers_ad'
              // 2) أي banner متاح
              String? bannerUrl;
              if (state is HomeLoaded && state.data.banners.isNotEmpty) {
                final adBanner = state.data.banners
                    .where(
                      (b) =>
                          b.linkTarget == 'offers_ad' && b.imageUrl.isNotEmpty,
                    )
                    .firstOrNull;
                bannerUrl =
                    adBanner?.imageUrl ??
                    state.data.banners
                        .firstWhere(
                          (b) => b.imageUrl.isNotEmpty,
                          orElse: () => state.data.banners.first,
                        )
                        .imageUrl;
              }

              return GestureDetector(
                onTap: () {
                  AppRouter.navigateTo(context, Routes.offers);
                },
                child: Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: bannerUrl != null && bannerUrl.isNotEmpty
                      ? AppCachedImage(
                          imageUrl: bannerUrl,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(16),
                          errorWidget: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.local_offer,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Center(
                              child: Icon(
                                Icons.local_offer,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
