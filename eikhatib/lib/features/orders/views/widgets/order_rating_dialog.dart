import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/orders/logic/orders_cubit.dart';
import 'package:eikhatib/features/orders/data/models/order_model.dart';

import '../../../../core/api/end_point.dart';

class OrderRatingDialog extends StatefulWidget {
  final OrderModel order;

  const OrderRatingDialog({super.key, required this.order});

  static void show(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderRatingDialog(order: order),
    );
  }

  @override
  State<OrderRatingDialog> createState() => _OrderRatingDialogState();
}

class _OrderRatingDialogState extends State<OrderRatingDialog> {
  double _orderRating = 5.0;
  final Map<String, double> _productRatings = {};
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize all product ratings to 5.0
    for (var item in widget.order.items) {
      _productRatings[item.id] = 5.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              SvgPicture.asset(AppAssets.star, width: 80, height: 80),
              const SizedBox(height: 20),
              Text(
                'كيف كانت تجربتك؟',
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الطلب رقم #${widget.order.id}',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // --- Order Rating ---
              Text(
                'تقييم الخدمة والتوصيل',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              RatingBar.builder(
                initialRating: _orderRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star_rounded, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _orderRating = rating;
                  });
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // --- Product Ratings ---
              Text(
                'تقييم المنتجات',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.order.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${EndPoint.imageBaseUrl}${item.imageUrl}',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(fontSize: 14),
                            ),
                          ),
                          RatingBar.builder(
                            initialRating: _productRatings[item.id] ?? 5.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemPadding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _productRatings[item.id] = rating;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),

              const SizedBox(height: 24),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'أضف تعليقاً على تجربتك (اختياري)',
                  hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final ordersCubit = context.read<OrdersCubit>();

                    // 1. Rate the order
                    ordersCubit.rateOrder(widget.order.id, _orderRating);

                    // 2. Rate each product
                    for (var item in widget.order.items) {
                      final pRating = _productRatings[item.id] ?? 5.0;
                      // We can pass the global comment or just the rating
                      ordersCubit.rateProduct(
                        item.id,
                        pRating,
                        review: _commentController.text.isNotEmpty
                            ? _commentController.text
                            : null,
                      );
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'شكراً لتقييمك! 🎉',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'إرسال التقييم',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
