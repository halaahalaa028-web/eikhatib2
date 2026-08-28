// ignore_for_file: deprecated_member_use

import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/orders/logic/orders_cubit.dart';
import 'package:eikhatib/features/orders/data/models/order_model.dart';
import 'package:eikhatib/features/orders/data/models/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class AdminSimulationScreen extends StatefulWidget {
  const AdminSimulationScreen({super.key});

  @override
  State<AdminSimulationScreen> createState() => _AdminSimulationScreenState();
}

class _AdminSimulationScreenState extends State<AdminSimulationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().fetchOrdersAdmin();
  }

  void _showDriverPicker(OrderModel order) async {
    final drivers = await context.read<OrdersCubit>().getAllDrivers();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر سائقاً لتوصيل الطلب',
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (drivers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'لا يوجد سائقين متاحين حالياً',
                      style: GoogleFonts.tajawal(color: Colors.grey),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: drivers.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          driver.name,
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          driver.phoneNumber ?? '',
                          style: GoogleFonts.tajawal(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<OrdersCubit>().assignDriver(
                            order.id.toString(),
                            driver.id,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openNavigation(OrderModel order) async {
    // For simulation, if no driver coords, use a default start point
    final startLat = order.driverLatitude ?? 24.7136;
    final startLng = order.driverLongitude ?? 46.6753;
    final destLat = order.address?.latitude ?? 24.7209;
    final destLng = order.address?.longitude ?? 46.6691;

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$destLat,$destLng&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  String _calculateDistance(OrderModel order) {
    if (order.address?.latitude == null) return '-- كم';

    // Driver or default startup point
    final startLat = order.driverLatitude ?? 24.7136;
    final startLng = order.driverLongitude ?? 46.6753;

    final distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      order.address!.latitude,
      order.address!.longitude,
    );

    return '${(distanceInMeters / 1000).toStringAsFixed(1)} كم';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'لوحة الإدارة (محاكاة)',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final pendingOrders = state.orders
              .where((o) => o.status == OrderStatus.pending)
              .toList();
          final activeOrders = state.orders
              .where((o) => o.status == OrderStatus.outForDelivery)
              .toList();

          return RefreshIndicator(
            onRefresh: () => context.read<OrdersCubit>().fetchOrdersAdmin(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(state.orders.length, pendingOrders.length),
                const SizedBox(height: 24),

                if (pendingOrders.isNotEmpty) ...[
                  _buildSectionTitle(
                    'الطلبات بانتظار التعيين',
                    pendingOrders.length,
                  ),
                  const SizedBox(height: 12),
                  ...pendingOrders.map(
                    (order) => _buildOrderCard(order, false),
                  ),
                  const SizedBox(height: 24),
                ],

                if (activeOrders.isNotEmpty) ...[
                  _buildSectionTitle(
                    'الطلبات قيد التوصيل الآن',
                    activeOrders.length,
                  ),
                  const SizedBox(height: 12),
                  ...activeOrders.map((order) => _buildOrderCard(order, true)),
                ],

                if (pendingOrders.isEmpty && activeOrders.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد طلبات للمحاكاة حالياً',
                            style: GoogleFonts.tajawal(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Text(
      '$title ($count)',
      style: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSummaryCard(int total, int pending) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFE6A310)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('إجمالي الطلبات', total.toString()),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStat('بانتظار التعيين', pending.toString()),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isActive) {
    final statusColor = OrderStatus.color(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order.id}',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address?.street ?? 'العنوان غير محدد',
                    style: GoogleFonts.tajawal(color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.directions_bike_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'المسافة المقدرة: ',
                  style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  _calculateDistance(order),
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!isActive)
              ElevatedButton.icon(
                onPressed: () => _showDriverPicker(order),
                icon: const Icon(Icons.delivery_dining_rounded),
                label: Text(
                  'تعيين سائق وتوصيل',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _openNavigation(order),
                icon: const Icon(Icons.map_rounded),
                label: Text(
                  'فتح مسار الملاحة (Google Maps)',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
