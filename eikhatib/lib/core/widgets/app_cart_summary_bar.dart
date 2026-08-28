// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/colors.dart';
import '../../features/cart/logic/cart_cubit.dart';
import '../routes/app_router.dart';
import '../routes/routes.dart';

class AppCartSummaryBar extends StatefulWidget {
  const AppCartSummaryBar({super.key});

  @override
  State<AppCartSummaryBar> createState() => _AppCartSummaryBarState();
}

class _AppCartSummaryBarState extends State<AppCartSummaryBar> {
  bool _isMinimized = false;
  bool _isRightSide = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        if (cartState.totalPrice <= 0) return const SizedBox.shrink();

        return ValueListenableBuilder<String?>(
          valueListenable: AppRouter.currentRouteName,
          builder: (context, currentRoute, child) {
            final hiddenRoutes = [
              Routes.splash,
              Routes.profile,
              Routes.securitySettings,
              Routes.login,
              Routes.register,
              Routes.onboarding,
              Routes.driverHome,
              Routes.adminSimulation,
              Routes.waitingApproval,
              Routes.productDetails,
              Routes.cart,
            ];

            final isVisible = currentRoute != null && !hiddenRoutes.contains(currentRoute);

            if (!isVisible) return const SizedBox.shrink();

            return FadeInUp(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutBack,
                alignment: _isMinimized
                    ? (_isRightSide
                          ? Alignment.centerRight
                          : Alignment.centerLeft)
                    : Alignment.bottomCenter,
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 500) {
                      // Swipe Right
                      setState(() {
                        _isMinimized = true;
                        _isRightSide = true;
                      });
                    } else if (details.primaryVelocity! < -500) {
                      // Swipe Left
                      setState(() {
                        _isMinimized = true;
                        _isRightSide = false;
                      });
                    }
                  },
                  onTap: _isMinimized
                      ? () {
                          setState(() {
                            _isMinimized = false;
                          });
                        }
                      : null,
                  child: Material(
                    type: MaterialType.transparency,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutBack,
                      width: _isMinimized
                          ? 70
                          : MediaQuery.of(context).size.width - 20,
                      height: _isMinimized ? 70 : 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: _isMinimized
                            ? BorderRadius.only(
                                topLeft: Radius.circular(
                                  _isRightSide ? 50 : 15,
                                ),
                                bottomLeft: Radius.circular(
                                  _isRightSide ? 50 : 15,
                                ),
                                topRight: Radius.circular(
                                  _isRightSide ? 15 : 50,
                                ),
                                bottomRight: Radius.circular(
                                  _isRightSide ? 15 : 50,
                                ),
                              )
                            : BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: _isMinimized
                            ? BorderRadius.only(
                                topLeft: Radius.circular(
                                  _isRightSide ? 50 : 15,
                                ),
                                bottomLeft: Radius.circular(
                                  _isRightSide ? 50 : 15,
                                ),
                                topRight: Radius.circular(
                                  _isRightSide ? 15 : 50,
                                ),
                                bottomRight: Radius.circular(
                                  _isRightSide ? 15 : 50,
                                ),
                              )
                            : BorderRadius.circular(15),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _isMinimized ? 0 : 10,
                            ),
                            child: _isMinimized
                                ? _buildMinimizedContent(cartState)
                                : _buildFullContent(context, cartState),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMinimizedContent(CartState state) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.primary,
            size: 28,
          ),
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                state.totalQuantity.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, CartState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth - 40; // 20 outer padding, 20 inner padding

    return OverflowBox(
      minWidth: contentWidth > 0 ? contentWidth : 0,
      maxWidth: contentWidth > 0 ? contentWidth : 0,
      alignment: Alignment.center,
      child: Row(
        children: [
          // Cart Icon with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    state.totalQuantity.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Text Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'عدد المنتجات في السلة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'JOD ${state.totalPrice.toStringAsFixed(3)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // View Cart Button
          ElevatedButton(
            onPressed: () {
              AppRouter.navigateTo(context, Routes.cart);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'عرض السلة',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
