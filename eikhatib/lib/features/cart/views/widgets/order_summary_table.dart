// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';

class OrderSummaryTable extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double savings;
  final double promoDiscount;
  final double taxes;

  const OrderSummaryTable({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.savings,
    this.promoDiscount = 0,
    this.taxes = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // subtotal  = price already after product discount (item.price * qty)
    // savings   = the discount amount already deducted (originalPrice - price) * qty
    final double originalTotal = subtotal + savings;
    final double grandTotal =
        (subtotal + deliveryFee - promoDiscount + taxes).clamp(0, double.infinity);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            // Original price (before discount)
            _buildSummaryRow(
              'السعر الأصلي',
              'JOD ${originalTotal.toStringAsFixed(3)}',
              isBold: true,
            ),
            if (savings > 0) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(
                'خصم المنتجات',
                '- JOD ${savings.toStringAsFixed(3)}',
                color: Colors.green,
                icon: Icons.discount_outlined,
              ),
            ],
            if (promoDiscount > 0) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(
                'خصم القسيمة',
                '- JOD ${promoDiscount.toStringAsFixed(3)}',
                color: Colors.green.shade700,
                icon: Icons.local_offer_rounded,
              ),
            ],
            const SizedBox(height: 12),
            _buildSummaryRow(
              'الضرائب',
              'JOD ${taxes.toStringAsFixed(3)}',
            ),
            _buildSummaryRow(
              'رسوم التوصيل',
              'JOD ${deliveryFee.toStringAsFixed(3)}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),

            // Grand Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'JOD ${grandTotal.toStringAsFixed(3)}',
                    style: GoogleFonts.tajawal(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    Color? color,
    bool isBold = false,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color ?? Colors.black87),
              const SizedBox(width: 5),
            ],
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
