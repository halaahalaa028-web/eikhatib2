// ignore_for_file: prefer_final_fields, unused_field, unused_element_parameter, unused_element, deprecated_member_use

import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class SavedCard {
  final String number; // Last 4 digits
  final String holder;
  final String expiry;
  final String brand; // 'visa' | 'mastercard' | 'other'
  final bool isDefault;

  SavedCard({
    required this.number,
    required this.holder,
    required this.expiry,
    required this.brand,
    this.isDefault = false,
  });
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class PaymentMethodSelector extends StatefulWidget {
  final ValueChanged<int>? onMethodSelected;
  const PaymentMethodSelector({super.key, this.onMethodSelected});

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  int _selectedMethod = 0; // 0: Cash, 1: Card
  final List<SavedCard> _savedCards = [];
  int _selectedCardIndex = 0;

  // ── Sheet ──────────────────────────────────────────────────────────────────

  void _openAddCardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCardSheet(
        onSave: (card) {
          setState(() => _savedCards.add(card));
        },
      ),
    );
  }

  void _showComingSoon() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.payment,
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'قريباً',
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "نحن نعمل على دعم الدفع بالبطاقة الائتمانيةسيكون متاحاً قريباً!",
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                    AppAssets.payment,
                    height: 24,
                    width: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'طريقة الدفع',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Cash option ──
            _PaymentTile(
              label: 'الدفع عند الاستلام',
              icon: Icons.payments_outlined,
              isSelected: _selectedMethod == 0,
              onTap: () {
                setState(() => _selectedMethod = 0);
                if (widget.onMethodSelected != null) {
                  widget.onMethodSelected!(0);
                }
              },
            ),
            const SizedBox(height: 10),

            // ── Card option ──
            _PaymentTile(
              label: 'بطاقة الائتمان',
              icon: Icons.credit_card_outlined,
              isSelected: _selectedMethod == 1,
              badge: 'قريباً',
              onTap: () {
                // Show "coming soon" and revert selection
                _showComingSoon();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment Tile ─────────────────────────────────────────────────────────────

class _PaymentTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _PaymentTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.04)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Payment type icon — RIGHT in RTL (start position)
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.08)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
              ),
            ),

            // Badge (e.g. "قريباً")
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Radio circle — LEFT in RTL (end position)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Saved Card Tile ──────────────────────────────────────────────────────────

class _SavedCardTile extends StatelessWidget {
  final SavedCard card;
  final bool isSelected;
  final VoidCallback onTap;

  const _SavedCardTile({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.04)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Card mini visual
            Container(
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3291), Color(0xFF4A5AE8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Text(
                  '•••• ${card.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.holder,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'تنتهي ${card.expiry}',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            if (card.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'افتراضية',
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Card Button ──────────────────────────────────────────────────────────

class _AddCardButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _AddCardButton({
    required this.onTap,
    this.label = 'إضافة بطاقة ائتمان',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_card_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Card Bottom Sheet ────────────────────────────────────────────────────

class _AddCardSheet extends StatefulWidget {
  final void Function(SavedCard) onSave;

  const _AddCardSheet({required this.onSave});

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isDefault = true;
  bool _showCvv = false;

  String get _last4 {
    final cleaned = _numberCtrl.text.replaceAll(' ', '');
    return cleaned.length >= 4 ? cleaned.substring(cleaned.length - 4) : '••••';
  }

  String _detectBrand(String number) {
    final n = number.replaceAll(' ', '');
    if (n.startsWith('4')) return 'visa';
    if (n.startsWith('5') || n.startsWith('2')) return 'mastercard';
    return 'other';
  }

  bool get _isFormValid =>
      _numberCtrl.text.replaceAll(' ', '').length == 16 &&
      _expiryCtrl.text.length == 5 &&
      _cvvCtrl.text.length >= 3 &&
      _nameCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
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

                // Title bar
                Row(
                  children: [
                    Text(
                      'إضافة بطاقة',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
                const SizedBox(height: 16),

                // ── Card Preview ──
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: _CardPreview(
                    number: _numberCtrl.text.isEmpty
                        ? '•••• •••• •••• ••••'
                        : _numberCtrl.text,
                    holder: _nameCtrl.text.isEmpty
                        ? 'صاحب البطاقة'
                        : _nameCtrl.text,
                    expiry: _expiryCtrl.text.isEmpty
                        ? 'MM/YY'
                        : _expiryCtrl.text,
                    brand: _detectBrand(_numberCtrl.text),
                  ),
                ),
                const SizedBox(height: 6),

                // Fee notice
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'سنقوم بخصم 0.25 JOD مؤقتاً للتحقق وسيتم إرجاعها فوراً',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.primary.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Card Number ──
                _buildLabel('رقم البطاقة'),
                const SizedBox(height: 8),
                _cardField(
                  controller: _numberCtrl,
                  hint: '0000 0000 0000 0000',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                  maxLength: 19,
                ),
                const SizedBox(height: 14),

                // ── Expiry + CVV ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('الصلاحية'),
                          const SizedBox(height: 8),
                          _cardField(
                            controller: _expiryCtrl,
                            hint: 'MM/YY',
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_ExpiryFormatter()],
                            maxLength: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CVV'),
                          const SizedBox(height: 8),
                          _cardField(
                            controller: _cvvCtrl,
                            hint: '•••',
                            icon: Icons.lock_outline_rounded,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscure: !_showCvv,
                            suffix: GestureDetector(
                              onTap: () => setState(() => _showCvv = !_showCvv),
                              child: Icon(
                                _showCvv
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Card Holder ──
                _buildLabel('اسم حامل البطاقة'),
                const SizedBox(height: 8),
                _cardField(
                  controller: _nameCtrl,
                  hint: 'Card Holder Name',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 16),

                // ── Default toggle ──
                Row(
                  children: [
                    Text(
                      'تعيين كافتراضية',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Save button ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: StatefulBuilder(
                    builder: (ctx, setBtn) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isFormValid
                            ? () {
                                widget.onSave(
                                  SavedCard(
                                    number: _last4,
                                    holder: _nameCtrl.text.trim(),
                                    expiry: _expiryCtrl.text.trim(),
                                    brand: _detectBrand(_numberCtrl.text),
                                    isDefault: _isDefault,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          'حفظ البطاقة',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: GoogleFonts.tajawal(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );

  Widget _cardField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscure = false,
    Widget? suffix,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return StatefulBuilder(
      builder: (_, setF) {
        // Card fields are always LTR (international standard)
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              obscureText: obscure,
              textDirection: textDirection,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.tajawal(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
                suffixIcon: suffix != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: suffix,
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                counterText: '',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Card Preview Widget ──────────────────────────────────────────────────────

class _CardPreview extends StatelessWidget {
  final String number;
  final String holder;
  final String expiry;
  final String brand;

  const _CardPreview({
    required this.number,
    required this.holder,
    required this.expiry,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F3C), Color(0xFF2C3291)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3291).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                brand == 'visa'
                    ? 'VISA'
                    : brand == 'mastercard'
                    ? 'MasterCard'
                    : 'Card',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contactless_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            number.isEmpty ? '•••• •••• •••• ••••' : number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              fontFamily: 'monospace',
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'صاحب البطاقة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    holder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'انتهاء',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Text Formatters ──────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue newVal,
  ) {
    final digits = newVal.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue newVal,
  ) {
    final digits = newVal.text.replaceAll(RegExp(r'\D'), '');
    String formatted = digits;
    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length == 2 && old.text.length == 1) {
      formatted = '$digits/';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
