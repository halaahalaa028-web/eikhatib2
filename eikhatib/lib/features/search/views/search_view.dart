import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/app_router.dart';

import '../logic/search_cubit.dart';
import '../../cart/logic/cart_cubit.dart';
import '../../../core/widgets/app_product_card.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query, BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.read<SearchCubit>().search(query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit()..loadHistory(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading && state.history.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is SearchSuccess) {
                      if (state.products.isEmpty &&
                          state.offers.isEmpty &&
                          state.categories.isEmpty) {
                        return _buildEmptyResults();
                      }
                      return _buildResultsView(state);
                    } else if (state is SearchError) {
                      return _buildErrorView(state.message);
                    }

                    // Default / Initial view showing history
                    return _buildInitialView(state.history);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => AppRouter.goBack(context),
              ),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) => _onSearchChanged(value, context),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منتج، قسم، أو عرض...',
                      hintStyle: GoogleFonts.tajawal(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchCubit>().clearSearch();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitialView(List<String> history) {
    if (history.isEmpty) {
      return FadeIn(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, size: 80, color: Colors.grey.shade200),
              const SizedBox(height: 16),
              Text(
                'ابدأ البحث عن منتجاتك المفضلة',
                style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'عمليات البحث الأخيرة',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () => context.read<SearchCubit>().clearHistory(),
                    child: Text(
                      'مسح الكل',
                      style: GoogleFonts.tajawal(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: history.map((h) => _buildSearchChip(h)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IntrinsicWidth(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _searchController.text = label;
                    context.read<SearchCubit>().search(label);
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                    child: Text(
                      label,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<SearchCubit>().removeFromHistory(label),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return FadeIn(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج تطابق بحثك',
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(SearchSuccess state) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        // Categories Section
        if (state.categories.isNotEmpty) ...[
          _buildSectionHeader('الأقسام المطابقة'),
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryResult(state.categories[index]);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Offers Section
        if (state.offers.isNotEmpty) ...[
          _buildSectionHeader('العروض'),
          const SizedBox(height: 10),
          SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.offers.length,
              itemBuilder: (context, index) {
                final product = state.offers[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      final cartItem = cartState.items[product.id];
                      return AppProductCard(
                        id: product.id,
                        title: product.name,
                        category: product.category,
                        imageUrl: product.imageUrl,
                        rating: product.rating,
                        reviewsCount: product.reviewsCount,
                        price: product.displayPrice,
                        originalPrice: product.hasOffer ? product.price : null,
                        stockQuantity: product.stockQuantity,
                        cartQuantity: cartItem?.quantity ?? 0,
                        isSimpleAdd: true,
                        isByWeight: product.isByWeight,
                        onAdd: () {
                          context.read<CartCubit>().addItem(
                            product.toCartItem(
                              quantity: product.isByWeight ? 0.25 : 1.0,
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Other Products Section
        if (state.products.isNotEmpty) ...[
          _buildSectionHeader('المنتجات'),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    final cartItem = cartState.items[product.id];
                      return AppProductCard(
                        id: product.id,
                        title: product.name,
                        category: product.category,
                        imageUrl: product.imageUrl,
                        rating: product.rating,
                        reviewsCount: product.reviewsCount,
                        price: product.displayPrice,
                        originalPrice: product.hasOffer ? product.price : null,
                        isByWeight: product.isByWeight,
                        stockQuantity: product.stockQuantity,
                        cartQuantity: cartItem?.quantity ?? 0,
                        isSimpleAdd: true,
                        width: double.infinity,
                        onAdd: () {
                        context.read<CartCubit>().addItem(
                          product.toCartItem(
                            quantity: product.isByWeight ? 0.25 : 1.0,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCategoryResult(String category) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        category,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
