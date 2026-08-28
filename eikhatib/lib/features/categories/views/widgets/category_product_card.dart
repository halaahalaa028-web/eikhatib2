// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';

class CategoryProductCard extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final bool isByWeight;
  final double stockQuantity;
  final double cartQuantity;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final VoidCallback onTap;

  final String? updatedAt;

  const CategoryProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    this.isByWeight = false,
    required this.stockQuantity,
    this.cartQuantity = 0.0,
    required this.onAdd,
    this.onRemove,
    required this.onTap,
    this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170, // Fixed width for horizontal scrolling
        margin: const EdgeInsets.only(left: 12, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Stack
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppCachedImage(
                    imageUrl: imageUrl,
                    updatedAt: updatedAt,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    errorWidget: const Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.grey,
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '($reviewsCount)',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'JOD ${(price * (cartQuantity > 0 ? cartQuantity : 1)).toStringAsFixed(3)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // Bottom Button or Selector
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ).copyWith(bottom: 12),
              child: cartQuantity == 0
                  ? GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text(
                            'أضف إلى السلة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            isByWeight
                                ? cartQuantity.toStringAsFixed(2)
                                : cartQuantity.toInt().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: onAdd,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
