import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lottie/lottie.dart' show Lottie;

import '../logic/orders_cubit.dart';
import '../data/models/order_model.dart';
import '../data/models/order_status.dart';
import '../../cart/data/models/cart_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eikhatib/features/orders/views/widgets/order_rating_dialog.dart';
import '../../../core/widgets/app_cached_image.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const OrderTrackingScreen({super.key, required this.arguments});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? orderId = widget.arguments['orderId']?.toString();

    if (orderId == null) {
      return _buildErrorScreen(context, 'الطلب غير متوفر.');
    }

    final OrderModel? order = context.watch<OrdersCubit>().getOrderById(
      orderId,
    );

    if (order == null) {
      return _buildErrorScreen(context, 'لم يتم العثور على الطلب رقم $orderId');
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FA),
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 65,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
              size: 20,
              textDirection: TextDirection.ltr,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تتبع الطلب',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopStatusSection(order.status),
              const SizedBox(height: 10),
              _buildProgressStepper(order.status),
              const SizedBox(height: 10),
              if (order.address != null) _buildMapSection(order, context),
              const SizedBox(height: 10),

              // Order Progress Stepper
              const SizedBox(height: 30),

              // Title: Order Products
              Text(
                'منتجات الطلب',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Order Items List
              ...order.items.map(
                (CartItem item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOrderProductCard(item),
                ),
              ),

              const SizedBox(height: 16),

              // Order Details Card
              _buildOrderDetailsCard(order),

              if (order.status == OrderStatus.delivered) ...[
                const SizedBox(height: 20),
                _buildRatingSection(context, order),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String msg) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          msg,
          style: GoogleFonts.tajawal(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTopStatusSection(String status) {
    final animations = OrderStatus.animations(status);
    return Column(
      children: [Lottie.asset(animations, width: 160, height: 160)],
    );
  }

  // ── Order Progress Stepper ─────────────────────────────────────────────────
  Widget _buildProgressStepper(String status) {
    // Only show for non-cancelled orders
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم إلغاء هذا الطلب',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
      );
    }

    const steps = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = steps.indexOf(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final isDone = stepIndex < currentIndex;
            return Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isDone
                      ? OrderStatus.color(steps[stepIndex])
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          } else {
            // Step circle
            final stepIndex = i ~/ 2;
            final stepStatus = steps[stepIndex];
            final isDone = stepIndex < currentIndex;
            final isCurrent = stepIndex == currentIndex;
            final color = OrderStatus.color(stepStatus);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: isCurrent ? 44 : 36,
                  height: isCurrent ? 44 : 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone || isCurrent
                        ? color.withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: isDone || isCurrent ? color : Colors.grey.shade300,
                      width: isCurrent ? 2.5 : 1.5,
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : OrderStatus.icon(stepStatus),
                    size: isCurrent ? 22 : 18,
                    color: isDone || isCurrent ? color : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _stepLabel(stepStatus),
                  style: GoogleFonts.tajawal(
                    fontSize: 9,
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w500,
                    color: isCurrent ? color : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  String _stepLabel(String status) {
    switch (status) {
      case OrderStatus.pending:
        return 'بانتظار\nالموافقة';
      case OrderStatus.preparing:
        return 'قيد\nالتحضير';
      case OrderStatus.outForDelivery:
        return 'خرج\nللتوصيل';
      case OrderStatus.delivered:
        return 'تم\nالتوصيل';
      default:
        return status;
    }
  }

  Widget _buildMapSection(OrderModel order, BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: order.status == OrderStatus.outForDelivery
              ? AppColors.primary
              : Colors.grey.shade300,
          width: order.status == OrderStatus.outForDelivery ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(order.address!.latitude, order.address!.longitude),
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    order.address!.latitude,
                    order.address!.longitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProductCard(CartItem item) {
    final bool hasDiscount =
        item.originalPrice != null && item.originalPrice! > item.price;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              AppCachedImage(
                imageUrl: item.imageUrl,
                width: 70,
                height: 70,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'JOD ${item.price.toStringAsFixed(3)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            'JOD ${item.originalPrice!.toStringAsFixed(3)}',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${(((item.originalPrice! - item.price) / item.originalPrice!) * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.tajawal(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الكمية: ${item.quantity.toInt()}',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الفرعي:',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'JOD ${(item.price * item.quantity).toStringAsFixed(3)}',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('رقم الطلب', order.id, isRedValue: true),
          _buildDivider(isThin: true),
          _buildDetailRow(
            'رقم المعاملة',
            order.transactionId,
            isRedValue: true,
          ),
          _buildDivider(isThin: true),
          _buildDetailRow(
            'تاريخ الطلب',
            DateFormat('dd/MM/yyyy').format(order.date),
            isRedValue: false,
          ),
          _buildDivider(),

          Text(
            'عنوان الشحن',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (order.address != null) ...[
            if (order.address!.storeName != null &&
                order.address!.storeName!.isNotEmpty)
              _buildAddressLine('المحل', order.address!.storeName!),
            if (order.address!.firstName != null &&
                order.address!.firstName!.isNotEmpty)
              _buildAddressLine(
                'اسم العميل',
                '${order.address!.firstName!} ${order.address!.lastName ?? ''}'
                    .trim(),
              ),
            if (order.address!.phoneNumber != null &&
                order.address!.phoneNumber!.isNotEmpty)
              _buildAddressLine('رقم الهاتف', order.address!.phoneNumber!),
            if (order.address!.city.isNotEmpty)
              _buildAddressLine('المدينة', order.address!.city),
            if (order.address!.street.isNotEmpty)
              _buildAddressLine('الشارع', order.address!.street),
            if (order.address!.country.isNotEmpty)
              _buildAddressLine('البلد', order.address!.country),
          ] else ...[
            Text(
              'لا يوجد عنوان',
              style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 13),
            ),
          ],
          _buildDivider(),

          Text(
            'تفاصيل الطلب',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'المجموع',
            'JOD ${order.subtotal.toStringAsFixed(3)}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'رسوم التوصيل',
            'JOD ${order.deliveryFee.toStringAsFixed(3)}',
          ),

          const SizedBox(height: 8),
          _buildDetailRow('الضرائب', 'JOD ${order.taxes.toStringAsFixed(3)}'),

          _buildDivider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طريقة الدفع',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.money_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.paymentMethod,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildDivider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبلغ الإجمالي',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Text(
                'JOD ${order.total.toStringAsFixed(3)}',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String title,
    String value, {
    bool isRedValue = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 15,
            fontWeight: (isRedValue || isGreen)
                ? FontWeight.w900
                : FontWeight.w600,
            color: isRedValue
                ? AppColors.primary
                : (isGreen ? Colors.green : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressLine(String key, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$key:',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider({bool isThin = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
        thickness: isThin ? 1 : 1.2,
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context, OrderModel order) {
    if (order.rating != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              'تقييمك للطلب',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < order.rating!.floor()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 28,
                );
              }),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          OrderRatingDialog.show(context, order);
        },
        icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
        label: Text(
          'قيّم تجربتك معنا',
          style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade50,
          foregroundColor: Colors.amber.shade900,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.amber.shade200),
          ),
        ),
      ),
    );
  }
}
