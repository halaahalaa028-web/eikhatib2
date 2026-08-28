import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import 'package:eikhatib/core/widgets/app_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';

import '../../../cart/logic/cart_cubit.dart';
import '../../data/models/home_models.dart';

class FeaturedProductsSection extends StatefulWidget {
  final List<ProductModel> featuredProducts;
  const FeaturedProductsSection({super.key, required this.featuredProducts});

  @override
  State<FeaturedProductsSection> createState() =>
      _FeaturedProductsSectionState();
}

class _FeaturedProductsSectionState extends State<FeaturedProductsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'منتجات مميزة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              InkWell(
                onTap: () => AppRouter.navigateTo(context, Routes.categories),
                child: const Text(
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
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 310,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.featuredProducts.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final product = widget.featuredProducts[index];
                  final cartItem = state.items[product.id];
                  final currentQty = cartItem?.quantity ?? 0.0;

                  final step = product.isByWeight ? 0.25 : 1.0;

                  return AppProductCard(
                    id: product.id,
                    title: product.name,
                    category: product.category,
                    imageUrl: product.imageUrl,
                    discountText: product.discountText,
                    rating: product.rating,
                    reviewsCount: product.reviewsCount,
                    stockQuantity: product.stockQuantity,
                    price: product.currentPrice,
                    originalPrice: product.hasOffer ? product.price : null,
                    isByWeight: product.isByWeight,
                    cartQuantity: currentQty,
                    onAdd: () {
                      if (currentQty + step <= product.stockQuantity) {
                        context.read<CartCubit>().addItem(
                          product.toCartItem(quantity: step),
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
        ),
      ],
    );
  }

  void _showStockError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'عذراً، لقد تجاوزت الكمية المتوفرة في المخزون!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
