// ignore_for_file: deprecated_member_use

import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item.dart';
import '../../logic/cart_cubit.dart';
import '../../../../core/theme/colors.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                AppCachedImage(
                  imageUrl: item.imageUrl,
                  updatedAt: item.updatedAt,
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (item.originalPrice != null &&
                          item.originalPrice! > item.price)
                        Row(
                          children: [
                            Text(
                              'JOD ${item.originalPrice!.toStringAsFixed(3)}',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 20,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 8), // Dynamic Discount Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'خصم ${(((item.originalPrice! - item.price) / item.originalPrice!) * 100).round()}%',
                                style: GoogleFonts.tajawal(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // Price Bubble
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '💵 JOD ${item.price.toStringAsFixed(3)} ',
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    'x${item.quantity.toInt()}',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 15),

            // // Note Field
            // Container(
            //   height: 40,
            //   padding: const EdgeInsets.symmetric(horizontal: 10),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(color: Colors.grey.shade300),
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(
            //         Icons.sticky_note_2_outlined,
            //         size: 22,

            //         color: Colors.black,
            //       ),

            //       Expanded(
            //         child: TextField(
            //           controller: TextEditingController(text: item.itemNote),
            //           onChanged: (val) {
            //             context.read<CartCubit>().updateNote(item.id, val);
            //           },
            //           decoration: InputDecoration(
            //             hintText: 'أضف ملاحظات',
            //             hintStyle: GoogleFonts.tajawal(
            //               color: Colors.black,
            //               fontStyle: FontStyle.italic,
            //               fontSize: 12,
            //             ),
            //             border: InputBorder.none,
            //             enabledBorder: InputBorder.none,
            //             focusedBorder: InputBorder.none,
            //             isDense: true,
            //             contentPadding: EdgeInsets.zero,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 15),

            // Controls
            Row(
              children: [
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          context.read<CartCubit>().updateQuantity(
                            item.id,
                            item.quantity - 1,
                          );
                        },
                      ),
                      Text(
                        item.quantity.toInt().toString(),
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          context.read<CartCubit>().updateQuantity(
                            item.id,
                            item.quantity + 1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Delete Button
                InkWell(
                  onTap: () {
                    context.read<CartCubit>().removeItem(item.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.delete,
                      height: 28,
                      width: 28,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
