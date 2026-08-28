import 'package:eikhatib/features/home/logic/home_cubit.dart';
import 'package:eikhatib/features/home/logic/home_state.dart';
import 'package:eikhatib/features/home/data/models/home_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_product_card.dart';
import '../../cart/logic/cart_cubit.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  List<ProductModel> filteredOffers = [];
  List<ProductModel> allOffers = [];

  @override
  void initState() {
    super.initState();
    filteredOffers = List.from(allOffers);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      filteredOffers = allOffers
          .where(
            (product) => product.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    });
    _loadOffers();
  }

  void _loadOffers() {
    final state = context.read<HomeCubit>().state;
    if (state is HomeLoaded) {
      allOffers = state.data.offers;
      filteredOffers = List.from(allOffers);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          } else if (state is HomeLoaded) {
            // Update lists if empty (first time)
            if (allOffers.isEmpty && state.data.offers.isNotEmpty) {
              allOffers = state.data.offers;
              filteredOffers = List.from(allOffers);
            }
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildProductGrid(),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 70.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: AppColors.primary,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            });
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          bottom: _isSearching
              ? 55
              : 30, // Adjust title based on search visibility
          left: 0,
          right: 0,
        ),
        centerTitle: true,
        title: _isSearching
            ? null
            : Text(
                'العروض ',
                style: GoogleFonts.tajawal(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
      bottom: _isSearching
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث في العروض...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProductGrid() {
    if (filteredOffers.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'لا توجد عروض تطابق بحثك',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 0,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = filteredOffers[index];
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
                isByWeight: product.isByWeight,
                price: product.currentPrice,
                originalPrice: product.hasOffer ? product.price : null,
                cartQuantity: currentQty,
                onAdd: () {
                  if (currentQty + step <= product.stockQuantity) {
                    context.read<CartCubit>().addItem(
                      product.toCartItem(quantity: step),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('عذراً، لقد تجاوزت الكمية المتوفرة!'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
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
            }, childCount: filteredOffers.length),
          ),
        );
      },
    );
  }
}
