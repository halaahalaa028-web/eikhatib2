// ignore_for_file: deprecated_member_use

import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/orders/data/models/order_model.dart';
import 'package:eikhatib/features/orders/data/models/order_status.dart';
import 'package:eikhatib/features/orders/views/widgets/order_rating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Smart address summary
    String addressSummary = 'لا يوجد عنوان';
    if (order.address != null) {
      final addr = order.address!;
      if (addr.title == 'الموقع الحالي') {
        addressSummary = addr.street.isNotEmpty ? addr.street : 'الموقع الحالي';
      } else {
        final parts = [
          if (addr.storeName != null && addr.storeName!.isNotEmpty) addr.storeName!,
          if (addr.city.isNotEmpty) addr.city,
          if (addr.street.isNotEmpty) addr.street,
        ];
        addressSummary = parts.join('، ');
      }
    }

    final String timeFormatted = DateFormat('hh:mm a').format(order.date);

    return GestureDetector(
      onTap: () {
        AppRouter.navigateTo(
          context,
          Routes.orderTracking,
          arguments: {'orderId': order.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Top Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Box Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.carts,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Order Numbers
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id}',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '#${order.transactionId}',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        timeFormatted,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: OrderStatus.color(order.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.status,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(width: 8),
                    // Container(
                    //   width: 32,
                    //   height: 32,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     shape: BoxShape.circle,
                    //     border: Border.all(color: Colors.grey.shade300),
                    //   ),
                    //   child: const Icon(
                    //     Icons.keyboard_arrow_down_rounded,
                    //     color: Colors.grey,
                    //     size: 20,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Inner Grey Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 0.8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Row: Rating | Products | Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInnerStatColumn(
                        'التقييم',
                        Row(
                          children: List.generate(5, (index) {
                            return const Icon(
                              Icons.star_border_rounded,
                              size: 16,
                              color: Colors.grey,
                            );
                          }),
                        ),
                      ),
                      _buildInnerStatColumn(
                        'المنتجات',
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.items.length.toString(),
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildInnerStatColumn(
                        'الإجمالي',
                        Text(
                          'JOD ${order.total.toStringAsFixed(3)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.black12, height: 1),
                  ),
                  // Row: Tax | Delivery | Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInnerStatColumn(
                        'الضرائب',
                        Text(
                          'JOD ${order.taxes.toStringAsFixed(3)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      _buildInnerStatColumn(
                        'التوصيل',
                        Text(
                          'JOD ${order.deliveryFee.toStringAsFixed(3)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      _buildInnerStatColumn(
                        'المجموع الفرعي',
                        Text(
                          'JOD ${order.subtotal.toStringAsFixed(3)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.black12, height: 1),
                  ),
                  // Note/Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          addressSummary,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (order.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.notes,
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (order.status == OrderStatus.delivered) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 12),
                    _buildRatingRow(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context) {
    if (order.rating != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تقييمك:',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < order.rating!.floor()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          OrderRatingDialog.show(context, order);
        },
        icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
        label: Text(
          'أضف تقييمك للطلب',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.amber.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildInnerStatColumn(String title, Widget valueWidget) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        valueWidget,
      ],
    );
  }
}
