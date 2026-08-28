// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';
import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/features/cart/logic/cart_cubit.dart';
import 'package:eikhatib/features/cart/logic/address_cubit.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:eikhatib/features/cart/views/widgets/addresses_bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/home_models.dart';

class TopHeader extends StatelessWidget {
  final List<BannerModel> banners;
  const TopHeader({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 410,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Red Header Background with curve
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  const Color.fromARGB(255, 0, 12, 175).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          // Subtle Dark Pattern right overlay
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary2,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(150),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      // Branded Title block
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AppAssets.appLogo2,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "محلات الخطيب",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Dropdown location
                      BlocBuilder<AddressCubit, AddressState>(
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    const AddressesBottomSheet(),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  state.selectedAddress?.title ?? 'إضافة عنوان',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Icons
                      Row(
                        children: [
                          _buildCircleBtn(
                            AppAssets.notification,
                            onTap: () => AppRouter.navigateTo(
                              context,
                              Routes.notifications,
                            ),
                          ),
                          const SizedBox(width: 12),
                          BlocBuilder<CartCubit, CartState>(
                            builder: (context, state) {
                              int itemCount = 0;
                              if (state is CartUpdated) {
                                // Since users care about quantity of total items normally, but some clients prefer unique items
                                // Let's use state.items.length for unique items, or we can use totalQuantity.
                                // We'll use the number of unique items (length).
                                itemCount = state.items.length;
                              }
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildCircleBtn(
                                    AppAssets.cart,
                                    onTap: () {
                                      AppRouter.navigateTo(
                                        context,
                                        Routes.cart,
                                      );
                                    },
                                  ),
                                  if (itemCount > 0)
                                    Positioned(
                                      top: -5,
                                      right: -5,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$itemCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 37),
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      final name = state.user?.name ?? 'ضيفنا الكريم';
                      return Text(
                        'مرحباً بك $name! 😍',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),

                  // Search field
                  GestureDetector(
                    onTap: () {
                      AppRouter.navigateTo(context, Routes.search);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 16),
                          Icon(Icons.search, color: Colors.white70, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'إبحث هنا...',

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  // Offers Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'عروض خاصة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            AppRouter.navigateTo(context, Routes.offers),
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: 10,
            child: _PromoBannerCarousel(
              banners: banners
                  .where((b) => b.linkTarget != 'offers_ad')
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCircleBtn(String icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.30),
          shape: BoxShape.circle,
        ),
        child: Center(child: SvgPicture.asset(icon, width: 24, height: 24)),
      ),
    );
  }
}

class _PromoBannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  const _PromoBannerCarousel({required this.banners});

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && widget.banners.isNotEmpty) {
        int nextPage = _currentPage + 1;
        if (nextPage >= widget.banners.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      if (banner.linkType == 'category') {
                        // AppRouter.navigateTo(context, Routes.categoryProducts, arguments: {'categoryName': banner.linkTarget});
                      } else if (banner.linkType == 'product') {
                        // AppRouter.navigateTo(context, Routes.productDetails, arguments: {'productId': banner.linkTarget});
                      }
                    },
                    child: AppCachedImage(
                      imageUrl: banner.imageUrl,
                      updatedAt: banner.updatedAt,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.black.withOpacity(0.2),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.banners.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
