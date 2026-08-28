import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            title: 'الرئيسية',
            icon: AppAssets.home,
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            title: 'الأقسام',
            icon: AppAssets.categories,
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            title: 'طلبات',
            icon: AppAssets.orders,
            index: 2,
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            title: 'حسابي',
            icon: AppAssets.profile,
            index: 3,
            isSelected: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    required String icon,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: isSelected
              ? Stack(
                  key: const ValueKey('selected'),
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -24,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            icon,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey('unselected'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(icon, width: 22, height: 22),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
