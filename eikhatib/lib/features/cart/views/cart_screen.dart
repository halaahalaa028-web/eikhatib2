// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:eikhatib/core/api/dio_consumer.dart';
import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

import 'widgets/order_summary_table.dart';
import '../../profile/logic/security_cubit.dart';
import '../../profile/views/widgets/otp_verification_dialog.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/routes/routes.dart';
import '../logic/cart_cubit.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/location_section.dart';
// import 'widgets/promo_code_section.dart';
import '../../orders/logic/orders_cubit.dart';
import '../../orders/data/models/order_model.dart';
import '../logic/address_cubit.dart';
import '../../auth/logic/user_cubit.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _deliveryFee = 2.0;
  double _minOrderValue = 0.0;
  double _maxOrderValue = 0.0;
  bool _loadingDeliveryFee = true;
  bool _isOrdering = false;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryFee();
  }

  Future<void> _fetchDeliveryFee() async {
    try {
      final api = DioConsumer(dio: Dio());
      final res = await api.get('system/contact-links');
      final links = res['links'];
      if (links != null) {
        if (mounted) {
          setState(() {
            _deliveryFee =
                double.tryParse(links['delivery_fee']?.toString() ?? '') ?? 2.0;
            _minOrderValue =
                double.tryParse(links['min_order_value']?.toString() ?? '') ?? 0.0;
            _maxOrderValue =
                double.tryParse(links['max_order_value']?.toString() ?? '') ?? 0.0;
            _loadingDeliveryFee = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingDeliveryFee = false);
      }
    } catch (e) {
      debugPrint('Error fetching delivery fee & settings: $e');
      if (mounted) setState(() => _loadingDeliveryFee = false);
    }
  }

  // ── Countdown state ──────────────────────────────────────────────────────
  bool _isCountingDown = false;
  int _countdown = 5;
  Timer? _timer;
  String? _pendingOrderId;
  OrderModel? _pendingOrder;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _canOrder(CartState cartState, AddressState addressState) {
    return cartState.items.isNotEmpty &&
        addressState.selectedAddress != null;
  }

  void _startCountdown(BuildContext context) {
    final userCubit = context.read<UserCubit>();
    if (!userCubit.isLoggedIn) {
      _showLoginRequiredDialog(context);
      return;
    }

    final securityState = context.read<SecurityCubit>().state;

    if (securityState.is2FAEnabled) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final phoneNumber =
              context.read<UserCubit>().state.user?.phoneNumber ?? '';
          return OtpVerificationDialog(
            title: 'تأكيد الهوية لإتمام الطلب',
            initialPhoneNumber: phoneNumber,
            onVerify: (otp) {
              _proceedWithOrder(context);
            },
          );
        },
      );
    } else {
      _proceedWithOrder(context);
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              'تسجيل الدخول مطلوب',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'يرجى تسجيل الدخول أو إنشاء حساب جديد لتتمكن من إتمام الطلب ومتابعة حالته.',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, Routes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, Routes.register);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'إنشاء حساب جديد',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'متابعة التصفح',
                    style: GoogleFonts.tajawal(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _proceedWithOrder(BuildContext context) {
    final cartState = context.read<CartCubit>().state;
    final addressState = context.read<AddressCubit>().state;

    final subtotal = cartState.totalPrice;

    // Check min order limit
    if (_minOrderValue > 0 && subtotal < _minOrderValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، الحد الأدنى لقيمة الفاتورة هو ${_minOrderValue.toStringAsFixed(0)} جنيه.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check max order limit
    if (_maxOrderValue > 0 && subtotal > _maxOrderValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، قيمة الشراء تجاوزت الحد الأقصى المسموح به وهو ${_maxOrderValue.toStringAsFixed(0)} جنيه.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final discount = cartState.discountAmount;
    final deliveryFee = _deliveryFee;
    const taxes = 0.0;
    final total = subtotal + deliveryFee + taxes - discount;

    final orderId = '${DateTime.now().millisecondsSinceEpoch}';
    final transactionId = 'TXN-$orderId-${Random().nextInt(9999)}';

    _pendingOrder = OrderModel(
      id: orderId,
      transactionId: transactionId,
      date: DateTime.now(),
      items: cartState.items.values.toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      taxes: taxes,
      total: total > 0 ? total : 0,
      address: addressState.selectedAddress,
      paymentMethod: 'الدفع عند الاستلام',
      notes: '',
    );
    _pendingOrderId = orderId;

    setState(() {
      _isCountingDown = true;
      _countdown = 5;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);

      if (_countdown <= 0) {
        t.cancel();
        _confirmOrder(context);
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    setState(() {
      _isCountingDown = false;
      _countdown = 5;
      _pendingOrder = null;
      _pendingOrderId = null;
    });
  }

  Future<void> _confirmOrder(BuildContext context) async {
    if (_pendingOrder == null) return;

    setState(() {
      _isCountingDown = false;
      _countdown = 5;
      _isOrdering = true;
    });

    final order = _pendingOrder!;
    final orderId = _pendingOrderId!;
    _pendingOrder = null;
    _pendingOrderId = null;

    final success = await context.read<OrdersCubit>().addOrder(order);

    if (!mounted) return;

    setState(() {
      _isOrdering = false;
    });

    if (success) {
      context.read<CartCubit>().clearCart();
      AppRouter.navigateAndReplace(
        context,
        Routes.orderTracking,
        arguments: {'orderId': orderId},
      );
    } else {
      final errorMsg = context.read<OrdersCubit>().state.error ?? 'فشل إرسال الطلب، يرجى المحاولة مرة أخرى';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => AppRouter.goBack(context),
        ),
        title: Text(
          'السلة',
          style: GoogleFonts.tajawal(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          if (cartState.items.isEmpty && !_isCountingDown) {
            return _buildEmptyCart(context);
          }

          return BlocBuilder<AddressCubit, AddressState>(
            builder: (context, addressState) {
              final canOrder = _canOrder(cartState, addressState);

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        // Products Section
                        _buildSectionWrapper(
                          title: 'المنتجات في السلة',
                          itemsCount: cartState.items.length,
                          icon: AppAssets.carts,
                          child: Column(
                            children: cartState.items.values.map((item) {
                              return CartItemWidget(item: item);
                            }).toList(),
                          ),
                        ),

                        // Add More Products Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                AppRouter.navigateTo(context, Routes.home),
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              'أضف المزيد من المنتجات',
                              style: GoogleFonts.tajawal(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        // Location Section
                        const LocationSection(),

                        // // Promo Code Section
                        // PromoCodeSection(
                        //   onCodeApplied: (promo) {
                        //     context.read<CartCubit>().applyPromoCode(promo);
                        //   },
                        // ),

                        // Additional Notes and Payment Selector sections removed per requirements

                        // Order Summary Table
                        OrderSummaryTable(
                          subtotal: cartState.totalPrice,
                          deliveryFee: _deliveryFee,
                          savings: cartState.totalSavings,
                          promoDiscount: cartState.discountAmount,
                          taxes: 0.0,
                        ),
                      ],
                    ),
                  ),

                  // ── Sticky Bottom Order Button ──
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildOrderButton(canOrder, context),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ── Order Button (normal / countdown) ────────────────────────────────────
  Widget _buildOrderButton(bool canOrder, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _isCountingDown
          ? _buildCountdownButton(context)
          : _buildNormalButton(canOrder, context),
    );
  }

  Widget _buildNormalButton(bool canOrder, BuildContext context) {
    final bool isEnabled = canOrder && !_isOrdering;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Validation hint
        if (!canOrder && !_isOrdering) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _buildHintText(context),
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ElevatedButton(
          onPressed: isEnabled ? () => _startCountdown(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? AppColors.primary
                : Colors.grey.shade300,
            foregroundColor: isEnabled ? Colors.white : Colors.black45,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.black45,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: _isOrdering
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'اطلب الآن',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
      ],
    );
  }

  Widget _buildCountdownButton(BuildContext context) {
    return Row(
      children: [
        // ── Cancel (X) button ──
        GestureDetector(
          onTap: _cancelCountdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.red.shade200, width: 1.5),
            ),
            child: Icon(
              Icons.close_rounded,
              color: Colors.red.shade400,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ── Countdown bar ──
        Expanded(
          child: SizedBox(
            height: 55,
            child: Stack(
              children: [
                // Animated fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                // Progress overlay (shrinks)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeInOut,
                        width:
                            MediaQuery.of(context).size.width *
                            (_countdown / 5) *
                            0.6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Label
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'جاري إرسال الطلب... $_countdown',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _buildHintText(BuildContext context) {
    final addressState = context.read<AddressCubit>().state;
    final hasAddress = addressState.selectedAddress != null;

    if (!hasAddress) {
      return 'يرجى تحديد موقع التوصيل أولاً';
    }
    return '';
  }

  // ── Section Wrapper ───────────────────────────────────────────────────────
  Widget _buildSectionWrapper({
    required String title,
    int? itemsCount,
    required String icon,
    required Widget child,
  }) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: SvgPicture.asset(icon, height: 28, width: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (itemsCount != null)
                        Text(
                          '$itemsCount عنصر',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.oncart, height: 240, width: 240),
          const SizedBox(height: 20),
          Text(
            'السلة فارغة حالياً',
            style: GoogleFonts.tajawal(fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => AppRouter.goBack(context),
            child: const Text('العودة للتسوق'),
          ),
        ],
      ),
    );
  }
}
