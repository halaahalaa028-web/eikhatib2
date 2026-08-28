import 'package:eikhatib/features/cart/logic/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/widgets/app_product_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../logic/category_products_cubit.dart';
import '../logic/category_products_state.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const CategoryProductsScreen({super.key, this.arguments = const {}});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late String categoryName;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'الاحدث';
  double _minPrice = 0;
  double _maxPrice = 100;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    categoryName = widget.arguments['categoryName'] ?? 'جميع المنتجات';
    context.read<CategoryProductsCubit>().fetchProducts(
      categoryName: categoryName,
      sort: _selectedSort,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CategoryProductsCubit>().fetchProducts(
        categoryName: categoryName,
        search: query,
        sort: _selectedSort,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
    });
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ترتيب وفلترة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedSort = 'الاكثر شيوعا';
                            _minPrice = 0;
                            _maxPrice = 100;
                          });
                        },
                        child: const Text(
                          'مسح الكل',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ترتيب حسب',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildSortOption(
                    setModalState,
                    'الاحدث',
                    Icons.new_releases_rounded,
                  ),
                  _buildSortOption(
                    setModalState,
                    'الاكثر شيوعا',
                    Icons.local_fire_department_rounded,
                  ),

                  _buildSortOption(
                    setModalState,
                    'الاقدم',
                    Icons.history_rounded,
                  ),
                  _buildSortOption(
                    setModalState,
                    'السعر: من الأعلى للأدنى',
                    Icons.trending_up_rounded,
                  ),
                  _buildSortOption(
                    setModalState,
                    'السعر: من الأدنى للأعلى',
                    Icons.trending_down_rounded,
                  ),
                  _buildSortOption(
                    setModalState,
                    'التقييم الأعلى',
                    Icons.star_rounded,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'نطاق السعر',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    labels: RangeLabels(
                      _minPrice.round().toString(),
                      _maxPrice.round().toString(),
                    ),
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (val) {
                      setModalState(() {
                        _minPrice = val.start;
                        _maxPrice = val.end;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<CategoryProductsCubit>().fetchProducts(
                          categoryName: categoryName,
                          search: _searchController.text,
                          sort: _selectedSort,
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'تطبيق الفلترة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(
    StateSetter setModalState,
    String title,
    IconData icon,
  ) {
    bool isSelected = _selectedSort == title;
    return InkWell(
      onTap: () {
        setModalState(() => _selectedSort = title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearchActive
                  ? Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _onSearchChanged,
                        onSubmitted: (value) => _onSearchChanged(value),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن المنتج...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearchActive = !_isSearchActive;
                    if (!_isSearchActive) {
                      _searchController.clear();
                      context.read<CategoryProductsCubit>().fetchProducts(
                        categoryName: categoryName,
                        search: '',
                        sort: _selectedSort,
                        minPrice: _minPrice,
                        maxPrice: _maxPrice,
                      );
                    }
                  });
                },
                icon: Icon(
                  _isSearchActive ? Icons.close : Icons.search_rounded,
                ),
              ),
              IconButton(
                onPressed: _openFilterBottomSheet,
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),

          // Products Grid
          BlocBuilder<CategoryProductsCubit, CategoryProductsState>(
            builder: (context, productsState) {
              if (productsState is CategoryProductsLoading ||
                  productsState is CategoryProductsInitial) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (productsState is CategoryProductsError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      productsState.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                );
              } else if (productsState is CategoryProductsLoaded) {
                final products = productsState.products;

                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'لا يوجد منتجات متاحة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                return BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(5),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 10,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = products[index];
                          final cartItem = cartState.items[product.id];
                          final currentQty = cartItem?.quantity ?? 0.0;
                          final step = product.isByWeight ? 0.25 : 1.0;

                          return AppProductCard(
                            id: product.id,
                            title: product.name,
                            category: product.category,
                            price: product.currentPrice,
                            originalPrice: product.hasOffer
                                ? product.price
                                : null,
                            discountText: product.discountText,
                            isByWeight: product.isByWeight,
                            stockQuantity: product.stockQuantity,
                            rating: product.rating,
                            reviewsCount: product.reviewsCount,
                            cartQuantity: currentQty,
                            imageUrl: product.imageUrl,
                            width: double.infinity,
                            onAdd: () {
                              if (currentQty + step <= product.stockQuantity) {
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
                          );
                        }, childCount: products.length),
                      ),
                    );
                  },
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}
