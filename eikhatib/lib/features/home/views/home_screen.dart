import 'package:eikhatib/features/home/views/widgets/active_orders_banner.dart';
import 'package:eikhatib/features/orders/logic/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/routes/routes.dart';
import 'widgets/top_header.dart';
import 'widgets/categories_section.dart';
import 'widgets/offers_orders_section.dart';
import 'widgets/best_sellers_section.dart';
import 'widgets/offers_and_rewards_section.dart';
import 'widgets/featured_products_section.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../categories/views/categories_view.dart';
import '../../orders/views/orders_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';
import '../data/models/home_models.dart';
import '../../../core/widgets/app_cached_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _shownAdIds = [];

  @override
  void initState() {
    super.initState();
    // Sync initial state
    _updateRoute(0);
  }

  void _showActiveAdsDialogs(BuildContext context, List<PopupAdModel> ads) {
    if (ads.isEmpty) return;
    
    // Filter ads that haven't been shown in this session
    final pendingAds = ads.where((ad) => !_shownAdIds.contains(ad.id)).toList();
    if (pendingAds.isEmpty) return;

    // Show them one by one recursively
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAdDialog(context, pendingAds, 0);
    });
  }

  void _showAdDialog(BuildContext context, List<PopupAdModel> ads, int index) {
    if (index >= ads.length) return;
    if (!mounted) return;
    
    final ad = ads[index];
    _shownAdIds.add(ad.id);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Ad Card
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ad Image
                      Flexible(
                        child: AppCachedImage(
                          imageUrl: ad.imageUrl,
                          updatedAt: ad.updatedAt,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      // Ad Title (If present, show it)
                      if (ad.title != null && ad.title!.trim().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ad.title!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (ad.description != null && ad.description!.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  ad.description!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Close button on top right
              Positioned(
                top: -15,
                right: -15,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    // Show next ad
                    _showAdDialog(context, ads, index + 1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
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

  void _updateRoute(int index) {
    final routes = [
      Routes.home,
      Routes.categories,
      Routes.orders,
      Routes.profile,
    ];
    if (index < routes.length) {
      AppRouter.updateCurrentRoute(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeLoaded) {
          _showActiveAdsDialogs(context, state.data.ads);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentView(),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _updateRoute(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0:
        return BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<HomeCubit>().fetchHomeData(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (state is HomeLoaded) {
              final data = state.data;
              return RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<HomeCubit>().fetchHomeData(),
                    context.read<OrdersCubit>().fetchOrders(),
                  ]);
                },
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  key: const ValueKey('HomeView'),
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TopHeader(banners: data.banners),
                      const ActiveOrdersBanner(),
                      CategoriesSection(categories: data.categories),
                      RecentProductsSection(products: data.offers),
                      BestSellersSection(bestSellers: data.bestSellers),
                      const OffersAndRewardsSection(),
                      FeaturedProductsSection(featuredProducts: data.featured),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      case 1:
        return const CategoriesView(key: ValueKey('CategoriesView'));
      case 2:
        return const OrdersScreen(key: ValueKey('OrdersView'));
      case 3:
        return const ProfileScreen(key: ValueKey('ProfileView'));
      default:
        return const SizedBox.shrink();
    }
  }
}
