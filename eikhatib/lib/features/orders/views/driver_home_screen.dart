import 'dart:async';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/auth/logic/user_cubit.dart';
import 'package:eikhatib/features/orders/logic/orders_cubit.dart';
import 'package:eikhatib/features/orders/data/models/order_model.dart';
import 'package:eikhatib/features/orders/views/driver_live_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Auto-refresh available orders every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isOnline) _refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final cubit = context.read<OrdersCubit>();
    await cubit.fetchDriverOrders();
    await cubit.fetchAvailableOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'لوحة تحكم السائق',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? 'متصل' : 'غير متصل',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isOnline ? Colors.green : Colors.grey,
                ),
              ),
              Switch(
                value: _isOnline,
                activeColor: Colors.green,
                onChanged: (v) => setState(() => _isOnline = v),
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.read<UserCubit>().logout(),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.isLoading && state.driverOrders.isEmpty && state.availableOrders.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (state.error != null && state.driverOrders.isEmpty && state.availableOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: GoogleFonts.tajawal(color: Colors.redAccent),
                    ),
                    TextButton(
                      onPressed: _refresh,
                      child: Text('إعادة المحاولة', style: GoogleFonts.tajawal()),
                    ),
                  ],
                ),
              );
            }

            final myOrders = state.driverOrders;
            final availableOrders = state.availableOrders;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('طلباتك قيد التحضير', Icons.directions_car_filled_rounded),
                  const SizedBox(height: 12),
                  if (myOrders.isEmpty)
                    _buildEmptyState('لا توجد لديك طلبات نشطة حالياً.')
                  else
                    ...myOrders.map((o) => _buildOrderCard(o, true)),
                  
                  const SizedBox(height: 30),
                  _buildSectionHeader('طلبات جديدة متاحة', Icons.add_shopping_cart_rounded),
                  const SizedBox(height: 12),
                  if (availableOrders.isEmpty)
                    _buildEmptyState('لا توجد طلبات جديدة في منطقتك.')
                  else
                    ...availableOrders.map((o) => _buildOrderCard(o, false)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 40, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel o, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طلب رقم #${o.id.split('-').first}',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    'المجموع: ${o.total} دينار',
                    style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(o.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  o.status,
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(o.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  o.address?.street ?? 'العنوان مفقود',
                  style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleAction(o, isActive),
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? Colors.green : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                isActive ? 'تحديث الحالة / إنهاء' : 'قبول هذا الطلب',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverLiveTrackingScreen(order: o),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 18),
                label: Text(
                  'التتبع الحي (Uber Style)',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'بانتظار الموافقة') return Colors.orange;
    if (status == 'قيد التحضير') return Colors.blue;
    if (status == 'تم التوصيل') return Colors.green;
    return AppColors.primary;
  }

  void _handleAction(OrderModel o, bool isActive) {
    final cubit = context.read<OrdersCubit>();
    if (!isActive) {
      cubit.acceptOrder(o.id).then((_) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('تم قبول الطلب. هو الآن في قائمتك النشطة.'))
         );
      });
    } else {
      // Show Status Picker
      _showStatusPicker(o);
    }
  }

  void _showStatusPicker(OrderModel o) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تحديث حالة الطلب', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildStatusItem('قيد التجهيز', Icons.restaurant, o.id),
            _buildStatusItem('خارج للتوصيل', Icons.delivery_dining, o.id),
            _buildStatusItem('تم التوصيل', Icons.check_circle, o.id),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, IconData icon, String orderId) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: GoogleFonts.tajawal()),
      onTap: () {
        Navigator.pop(context);
        context.read<OrdersCubit>().updateStatus(orderId, label);
      },
    );
  }
}
