// ignore_for_file: deprecated_member_use

import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/features/orders/views/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/logic/user_cubit.dart';
import '../../../core/routes/routes.dart';
import '../logic/orders_cubit.dart';
import '../data/models/order_model.dart';
import '../data/models/order_status.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default to active tab
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserCubit>().isLoggedIn;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 65,
          title: Text(
            'طلباتي',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          bottom: isLoggedIn
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black12, width: 1.5),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      unselectedLabelStyle: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: const [
                        Tab(text: 'قيد التحضير'),
                        Tab(text: 'مكتمل'),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        body: !isLoggedIn
            ? _buildGuestView(context)
            : BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
            if (state.isLoading && state.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: GoogleFonts.tajawal(
                          color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<OrdersCubit>().fetchOrders(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final activeOrders = state.orders
                .where((o) => OrderStatus.isActive(o.status))
                .toList();
            final completedOrders = state.orders
                .where((o) => !OrderStatus.isActive(o.status))
                .toList();

            return RefreshIndicator(
              onRefresh: () => context.read<OrdersCubit>().fetchOrders(),
              color: AppColors.primary,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(
                    orders: activeOrders,
                    emptyMessage: 'ليس لديك طلبات قيد التحضير حالياً',
                  ),
                  _buildOrdersList(
                    orders: completedOrders,
                    emptyMessage: 'لا توجد طلبات مكتملة',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList({
    required List<OrderModel> orders,
    required String emptyMessage,
  }) {
    if (orders.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.ordersno, height: 100, width: 100),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: GoogleFonts.tajawal(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10).copyWith(bottom: 100),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return OrderCard(order: orders[index]);
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 70,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'سجل الدخول لعرض وتتبع طلباتك',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'يمكنك متابعة حالة طلباتك الحالية والسابقة فور تسجيل الدخول إلى حسابك.',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.login),
              icon: const Icon(Icons.login_rounded, size: 20),
              label: Text(
                'تسجيل الدخول',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.register),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
              label: Text(
                'إنشاء حساب جديد',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
