import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';

class AppBestSellerCard extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final double price;
  final bool isByWeight;
  final double stockQuantity;
  final double cartQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  final String? updatedAt;

  const AppBestSellerCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    this.isByWeight = true,
    required this.stockQuantity,
    this.cartQuantity = 0.0,
    required this.onAdd,
    required this.onRemove,
    this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان العربية دائماً
      child: GestureDetector(
        onTap: () {
          AppRouter.navigateTo(
            context,
            Routes.productDetails,
            arguments: {
              'id': id,
              'title': title,
              'image': imageUrl,
              'rating': rating,
              'reviewsCount': reviewsCount,
              'price': price,
              'stock': stockQuantity,
              'isByWeight': isByWeight,
              'updatedAt': updatedAt,
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withAlpha(100),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // صورة المنتج
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: AppCachedImage(
                      imageUrl: imageUrl,
                      updatedAt: updatedAt,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // تفاصيل المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviewsCount)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'JOD ${(price * (cartQuantity > 0 ? cartQuantity : 1)).toStringAsFixed(3)}', // السعر يتغير ديناميكياً مع عدد الكيلوهات
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isByWeight
                        ? '${cartQuantity.toStringAsFixed(2)} كغ'
                        : cartQuantity
                              .toInt()
                              .toString(), // الكمية بناءً على النوع
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
