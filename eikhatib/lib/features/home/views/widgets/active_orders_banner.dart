// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import '../../../orders/logic/orders_cubit.dart';
import '../../../orders/data/models/order_status.dart';

class ActiveOrdersBanner extends StatelessWidget {
  const ActiveOrdersBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final activeOrders = state.orders
            .where((o) => OrderStatus.isActive(o.status))
            .take(2)
            .toList();

        if (activeOrders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: activeOrders.map((order) {
              return GestureDetector(
                onTap: () {
                  AppRouter.navigateTo(
                    context,
                    Routes.orderTracking,
                    arguments: {'orderId': order.id},
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: OrderStatus.color(
                            order.status,
                          ).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Transform.scale(
                          scale: 1.5,
                          child: Lottie.asset(
                            OrderStatus.animations(order.status),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب رقم ${order.id}',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'منتج: ',
                                        style: GoogleFonts.tajawal(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${order.items.length}',
                                        style: GoogleFonts.tajawal(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        ' السعر: ',
                                        style: GoogleFonts.tajawal(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${order.total.toStringAsFixed(3)} JOD',
                                        style: GoogleFonts.tajawal(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: OrderStatus.color(
                                order.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.status,
                              style: GoogleFonts.tajawal(
                                color: OrderStatus.color(order.status),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
