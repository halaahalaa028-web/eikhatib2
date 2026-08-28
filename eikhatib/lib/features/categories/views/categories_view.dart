// ignore_for_file: deprecated_member_use

import 'package:eikhatib/core/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import 'widgets/category_product_card.dart';
import '../../cart/logic/cart_cubit.dart';
import '../logic/categories_cubit.dart';
import '../logic/categories_state.dart';
import '../../home/data/models/home_models.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  // Track heights arrays to link scrolling positions
  final Map<int, double> _categoryHeights = {};
  int _currentSelectedCatIndex = 0;
  bool _isAutoScrolling = false;
  List<CategoryModel> categoriesData = [];

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _tabsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onMainScroll);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _tabsScrollController.dispose();
    super.dispose();
  }

  void _onMainScroll() {
    if (_isAutoScrolling || _categoryHeights.isEmpty) return;

    double offset = _mainScrollController.offset;
    double currentHeightPos = 0;

    int newIndex = _currentSelectedCatIndex;

    for (int i = 0; i < categoriesData.length; i++) {
      double h =
          _categoryHeights[i] ?? 350.0; // Approximation height if not measured
      if (offset >= currentHeightPos && offset < currentHeightPos + h) {
        newIndex = i;
        break;
      }
      currentHeightPos += h;
    }

    if (newIndex != _currentSelectedCatIndex) {
      setState(() {
        _currentSelectedCatIndex = newIndex;
      });
      // Scroll the top pills nicely with the state
      _scrollToTab(newIndex);
    }
  }

  void _scrollToCategory(int index) {
    if (index == _currentSelectedCatIndex) return;

    setState(() {
      _currentSelectedCatIndex = index;
      _isAutoScrolling = true;
    });

    double targetOffset = 0;
    for (int i = 0; i < index; i++) {
      targetOffset += _categoryHeights[i] ?? 350.0;
    }

    _mainScrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _isAutoScrolling = false;
        });

    _scrollToTab(index);
  }

  void _scrollToTab(int index) {
    if (_tabsScrollController.hasClients) {
      double target = (index * 110.0) - 50.0;
      if (target < 0) target = 0;
      _tabsScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading || state is CategoriesInitial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CategoriesError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        } else if (state is CategoriesLoaded) {
          categoriesData = state.categories;
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Header Top Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'الأقسام',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'استكشف اختيارنا',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Pills Horizontal Menu
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      controller: _tabsScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categoriesData.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _currentSelectedCatIndex == index;
                        return GestureDetector(
                          onTap: () => _scrollToCategory(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.08)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                width: isSelected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categoriesData[index].name,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Main Vertical Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          context.read<CategoriesCubit>().fetchCategories(),
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        controller: _mainScrollController,
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: categoriesData.length,
                        itemBuilder: (context, index) {
                          // Approximation height
                          _categoryHeights[index] = 360.0;

                          return _buildCategoryBlock(categoriesData[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryBlock(CategoryModel category) {
    final products = category.products ?? [];
    return GestureDetector(
      onTap: () {
        final cubit = context.read<CategoriesCubit>();
        final hasSub = cubit.hasSubCategories(category.id);
        if (hasSub) {
          AppRouter.navigateTo(
            context,
            Routes.allCategories,
            arguments: {'parentCategory': category},
          );
        } else {
          AppRouter.navigateTo(
            context,
            Routes.categoryProducts,
            arguments: {'categoryName': category.name},
          );
        }
      },
      child: SizedBox(
        height: 360.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppRouter.navigateTo(
                            context,
                            Routes.categoryProducts,
                            arguments: {'categoryName': category.name},
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade100,
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: AppCachedImage(
                                      imageUrl: category.imageUrl,
                                      updatedAt: category.updatedAt,
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.grid_view_rounded,
                                              size: 12,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 4),
                                        //
                                        Row(
                                          children: [
                                            const Text(
                                              'المنتجات :',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${products.length}+',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primary,

                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      AppRouter.navigateTo(
                        context,
                        Routes.categoryProducts,
                        arguments: {'categoryName': category.name},
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Left part (Text & Indicator)
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Horizontal Products List
            SizedBox(
              height: 260,
              child: products.isEmpty
                  ? const Center(child: Text('جاري إضافة المنتجات...'))
                  : BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: products.length,
                          itemBuilder: (context, idx) {
                            final product = products[idx];
                            final cartItem = state.items[product.id];
                            final currentQty = cartItem?.quantity ?? 0.0;
                            final step = product.isByWeight ? 0.25 : 1.0;

                            return CategoryProductCard(
                              id: product.id,
                              title: product.name,
                              price: product.currentPrice,
                              imageUrl: product.imageUrl,
                              rating: product.rating,
                              reviewsCount: product.reviewsCount,
                              stockQuantity: product.stockQuantity,
                              cartQuantity: currentQty,
                              isByWeight: product.isByWeight,
                              updatedAt: product.updatedAt,
                              onAdd: () {
                                if (currentQty + step <=
                                    product.stockQuantity) {
                                  context.read<CartCubit>().addItem(
                                    product.toCartItem(quantity: step),
                                  );
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
                              onTap: () {
                                AppRouter.navigateTo(
                                  context,
                                  Routes.productDetails,
                                  arguments: {
                                    'id': product.id,
                                    'title': product.name,
                                    'image': product.imageUrl,
                                    'rating': product.rating,
                                    'reviewsCount': product.reviewsCount,
                                    'price': product.currentPrice,
                                    'stock': product.stockQuantity,
                                    'isByWeight': product.isByWeight,
                                    'category': product.category,
                                    'updatedAt': product.updatedAt,
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),

            // Subtle Red divider like in UI
          ],
        ),
      ),
    );
  }
}
