// ignore_for_file: deprecated_member_use

import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/features/home/logic/coupons_cubit.dart';
import 'package:eikhatib/features/home/data/models/coupon_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoCode {
  final String code;
  final String description;
  final double discount; // fixed amount in JOD or percentage
  final int maxUses;
  final int usedCount;
  final DateTime expiryDate;
  final bool isPercentage; // false = fixed, true = percentage

  PromoCode({
    required this.code,
    required this.description,
    required this.discount,
    required this.maxUses,
    required this.usedCount,
    required this.expiryDate,
    this.isPercentage = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExhausted => usedCount >= maxUses;
  bool get isValid => !isExpired && !isExhausted;

  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;
  int get usesRemaining => maxUses - usedCount;

  String get displayDiscount => isPercentage
      ? '${discount.toInt()}%'
      : 'JOD ${discount.toStringAsFixed(3)}';
}

// ─── Mapper Helper ───────────────────────────────────────────────────────────

PromoCode _mapCouponToPromo(CouponModel coupon) {
  return PromoCode(
    code: coupon.code,
    description: coupon.description,
    discount: coupon.discount,
    maxUses: 1,
    usedCount: coupon.isUsed ? 1 : 0,
    expiryDate: coupon.expiryDate,
    isPercentage: coupon.isPercentage,
  );
}

// ─── Available Promo Codes (hardcoded demo data) ─────────────────────────────

final List<PromoCode> _demoCodes = [
  PromoCode(
    code: 'SAVE10',
    description: 'خصم 10 دينار على طلبك',
    discount: 10.0,
    maxUses: 5,
    usedCount: 2,
    expiryDate: DateTime.now().add(const Duration(days: 15)),
  ),
  PromoCode(
    code: 'WELCOME1',
    description: 'خصم دينار واحد للعملاء الجدد',
    discount: 1.0,
    maxUses: 1,
    usedCount: 0,
    expiryDate: DateTime.now().add(const Duration(days: 30)),
  ),
  PromoCode(
    code: 'OFF20',
    description: 'خصم 20% على إجمالي الطلب',
    discount: 20.0,
    maxUses: 3,
    usedCount: 3, // exhausted
    expiryDate: DateTime.now().add(const Duration(days: 10)),
    isPercentage: true,
  ),
];

// ─── Widget ───────────────────────────────────────────────────────────────────

class PromoCodeSection extends StatefulWidget {
  final void Function(PromoCode? promo)? onCodeApplied;

  const PromoCodeSection({super.key, this.onCodeApplied});

  @override
  State<PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends State<PromoCodeSection>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  PromoCode? _appliedCode;
  String? _errorMsg;
  bool _showInput = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _applyCode(List<PromoCode> allAvailable) {
    final input = _codeController.text.trim().toUpperCase();
    if (input.isEmpty) return;

    final found = allAvailable.where((c) => c.code == input).toList();

    if (found.isEmpty) {
      setState(() => _errorMsg = 'رمز القسيمة غير صحيح');
      return;
    }

    final promo = found.first;

    if (promo.isExpired) {
      setState(() => _errorMsg = 'هذه القسيمة منتهية الصلاحية');
      return;
    }
    if (promo.isExhausted) {
      setState(() => _errorMsg = 'تم استنفاد عدد مرات استخدام هذه القسيمة');
      return;
    }

    setState(() {
      _appliedCode = promo;
      _errorMsg = null;
      _showInput = false;
    });
    widget.onCodeApplied?.call(promo);
    FocusScope.of(context).unfocus();
  }

  void _removeCode() {
    setState(() {
      _appliedCode = null;
      _codeController.clear();
      _errorMsg = null;
    });
    widget.onCodeApplied?.call(null);
  }

  void _showAvailableCodes(List<PromoCode> allAvailable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PromoCodesSheet(
        codes: allAvailable,
        onSelect: (code) {
          _codeController.text = code.code;
          setState(() => _showInput = true);
          _applyCode(allAvailable);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CouponsCubit, CouponsState>(
      builder: (context, state) {
        // Combine demo codes with redeemed coupons
        final List<PromoCode> allAvailable = [
          ..._demoCodes,
          ...state.coupons.map(_mapCouponToPromo),
        ];

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppAssets.offers,
                        height: 24,
                        width: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'كود الخصم',
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Browse coupons
                    GestureDetector(
                      onTap: () => _showAvailableCodes(allAvailable),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer_outlined,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'عرض القسائم',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Applied code banner ──
                if (_appliedCode != null) ...[
                  _AppliedCodeBanner(
                    code: _appliedCode!,
                    onRemove: _removeCode,
                  ),
                ] else ...[
                  // ── Input field ──
                  if (_showInput) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _errorMsg != null
                                    ? Colors.red.shade300
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextField(
                                controller: _codeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: GoogleFonts.tajawal(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'أدخل كود الخصم',
                                  hintStyle: GoogleFonts.tajawal(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                onSubmitted: (_) => _applyCode(allAvailable),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _applyCode(allAvailable),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'تطبيق',
                                style: GoogleFonts.tajawal(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _errorMsg!,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else ...[
                    // ── Add code button ──
                    GestureDetector(
                      onTap: () => setState(() => _showInput = true),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'أضف كود خصم',
                              style: GoogleFonts.tajawal(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Applied Code Banner ──────────────────────────────────────────────────────

class _AppliedCodeBanner extends StatelessWidget {
  final PromoCode code;
  final VoidCallback onRemove;

  const _AppliedCodeBanner({required this.code, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.06),
            const Color(0xFF4A5AE8).withOpacity(0.03),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Tag icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Code badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code.code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'تم التطبيق ✓',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  code.description,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Discount + remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '- ${code.displayDiscount}',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onRemove,
                child: Text(
                  'إزالة',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: Colors.red.shade400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Available Promo Codes Sheet ──────────────────────────────────────────────

class _PromoCodesSheet extends StatelessWidget {
  final List<PromoCode> codes;
  final void Function(PromoCode) onSelect;

  const _PromoCodesSheet({required this.codes, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'القسائم المتاحة',
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 8),

            // List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: codes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _PromoCodeCard(
                  code: codes[i],
                  onTap: codes[i].isValid
                      ? () {
                          Navigator.pop(context);
                          onSelect(codes[i]);
                        }
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Promo Code Card ─────────────────────────────────────────────────────────

class _PromoCodeCard extends StatelessWidget {
  final PromoCode code;
  final VoidCallback? onTap;

  const _PromoCodeCard({required this.code, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = code.isValid;
    final color = isActive ? AppColors.primary : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.03)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey.shade200,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left ticket notch ──
                _TicketSide(color: color, isActive: isActive),

                // ── Content ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Code badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                code.code,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Status badge
                            if (code.isExpired)
                              _StatusBadge('منتهية', Colors.red)
                            else if (code.isExhausted)
                              _StatusBadge('مستنفدة', Colors.orange)
                            else
                              _StatusBadge('متاحة', Colors.green),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          code.description,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Stats row
                        Row(
                          children: [
                            if (!code.isExpired) ...[
                              _StatChip(
                                icon: Icons.timer_outlined,
                                label: '${code.daysRemaining} يوم متبقي',
                                color: color,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (!code.isExhausted && !code.isExpired)
                              _StatChip(
                                icon: Icons.repeat_rounded,
                                label: '${code.usesRemaining} استخدام متبقي',
                                color: color,
                              ),
                            if (code.isExpired)
                              _StatChip(
                                icon: Icons.event_busy_rounded,
                                label: 'انتهت الصلاحية',
                                color: Colors.red,
                              ),
                            if (code.isExhausted && !code.isExpired)
                              _StatChip(
                                icon: Icons.block_rounded,
                                label: 'تم استخدامها بالكامل',
                                color: Colors.orange,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Discount amount ──
                Container(
                  width: 72,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.07),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(13),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        code.isPercentage
                            ? '${code.discount.toInt()}%'
                            : '${code.discount.toStringAsFixed(0)}',
                        style: GoogleFonts.tajawal(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: color,
                          height: 1,
                        ),
                      ),
                      Text(
                        code.isPercentage ? 'خصم' : 'JOD',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ticket Side Notch ────────────────────────────────────────────────────────

class _TicketSide extends StatelessWidget {
  final Color color;
  final bool isActive;

  const _TicketSide({required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 5,
          decoration: BoxDecoration(
            color: color.withOpacity(isActive ? 0.7 : 0.3),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withOpacity(0.7)),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
