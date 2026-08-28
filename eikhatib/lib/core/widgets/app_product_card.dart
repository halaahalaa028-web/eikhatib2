// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';

class AppProductCard extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String? discountText;
  final double rating;
  final int reviewsCount;
  final bool isByWeight;
  final double stockQuantity;
  final double cartQuantity;
  final double price;
  final double? originalPrice;
  final bool isSimpleAdd;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final double? width;

  final String? updatedAt;

  const AppProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    this.isByWeight = false,
    required this.stockQuantity,
    this.cartQuantity = 0.0,
    required this.price,
    this.originalPrice,
    this.discountText,
    this.isSimpleAdd = false,
    this.onAdd,
    this.onRemove,
    this.width,
    this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
            'originalPrice': originalPrice,
            'stock': stockQuantity,
            'isByWeight': isByWeight,
            'category': category,
            'updatedAt': updatedAt,
          },
        );
      },
      child: Container(
        width: width ?? 170, // Default 170 for horizontal, otherwise fills available
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.04), // خلفية خفيفة واحترافية
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // يبدأ من اليمين بسبب הـ Directionality
          children: [
            // صورة المنتج مع باج الخصم
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AppCachedImage(
                    imageUrl: imageUrl,
                    updatedAt: updatedAt,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (discountText != null)
                  Positioned(
                    top: 8,
                    right: 8, // يمين كما هو متوقع في العربية
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        discountText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // لضمان عدم الخروج عن السطر
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // التقييم والكمية (المخزون المتوفر)
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '($reviewsCount)',
                      style: const TextStyle(
                        color: AppColors.backgroundDark,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  isByWeight ? 'الوزن المتاح:' : 'الكمية المتاحة:',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isByWeight
                      ? '${stockQuantity.toString()} كغ'
                      : stockQuantity.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (originalPrice != null)
                  Text(
                    'JOD ${(originalPrice! * (cartQuantity > 0 ? cartQuantity : 1)).toStringAsFixed(3)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  'JOD ${(price * (cartQuantity > 0 ? cartQuantity : 1)).toStringAsFixed(3)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // أزرار السلة والسعر الإجمالي أسفل البطاقة
            if (isSimpleAdd)
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(color: AppColors.primary, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'أضف للسلة',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
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
                  mainAxisSize: MainAxisSize.min,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        isByWeight
                            ? cartQuantity.toStringAsFixed(2)
                            : cartQuantity.toInt().toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
          ],
        ),
      ),
    );
  }
}
