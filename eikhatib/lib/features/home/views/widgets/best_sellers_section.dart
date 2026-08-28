import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/widgets/app_best_seller_card.dart';

import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/logic/cart_cubit.dart';
import '../../data/models/home_models.dart';

class BestSellersSection extends StatefulWidget {
  final List<ProductModel> bestSellers;
  const BestSellersSection({super.key, required this.bestSellers});

  @override
  State<BestSellersSection> createState() => _BestSellersSectionState();
}

class _BestSellersSectionState extends State<BestSellersSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'الأكثر مبيعاً',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => AppRouter.navigateTo(context, Routes.categories),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.bestSellers.length,
                itemBuilder: (context, index) {
                  final product = widget.bestSellers[index];
                  final cartItem = state.items[product.id];
                  final currentQty = cartItem?.quantity ?? 0.0;

                  final step = product.isByWeight ? 0.25 : 1.0;

                  return AppBestSellerCard(
                    id: product.id,
                    title: product.name,
                    imageUrl: product.imageUrl,
                    rating: product.rating,
                    reviewsCount: product.reviewsCount,
                    price: product.currentPrice,
                    stockQuantity: product.stockQuantity,
                    cartQuantity: currentQty,
                    isByWeight: product.isByWeight,
                    onAdd: () {
                      if (currentQty + step <= product.stockQuantity) {
                        context.read<CartCubit>().addItem(
                          product.toCartItem(quantity: step)
                        );
                      } else {
                        _showStockError(context);
                      }
                    },
                    onRemove: () {
                      if (currentQty >= step) {
                        context.read<CartCubit>().updateQuantity(
                          product.id,
                          currentQty - step,
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showStockError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'عذراً، لقد تجاوزت الكمية المتوفرة في المخزن!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
