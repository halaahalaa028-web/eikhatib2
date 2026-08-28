// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../../cart/logic/cart_cubit.dart';
import '../../cart/data/models/cart_item.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../core/api/end_point.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/routes/routes.dart';
import '../../auth/logic/user_cubit.dart';

import '../logic/product_details_cubit.dart';
import '../logic/product_details_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> productArguments;

  const ProductDetailsScreen({super.key, this.productArguments = const {}});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String id;
  late String title;
  late String image;
  late String description;
  late bool isByWeight;
  late double step;
  late double stock;
  late double price;
  late double rating;
  late int reviewsCount;
  late double currentAmount;
  bool _isAddingToCart = false;
  final TextEditingController _noteController = TextEditingController();
  String? updatedAt;

  @override
  void initState() {
    super.initState();
    final args = widget.productArguments;
    id =
        args['id']?.toString() ??
        args['productId']?.toString() ??
        'unknown_${DateTime.now().millisecondsSinceEpoch}';

    // Initial values from args (for smooth transition with Hero)
    title = args['title'] ?? '...';
    image = args['image'] ?? '';
    description = args['description'] ?? '';
    isByWeight = args['isByWeight'] ?? true;
    stock = (args['stock'] ?? 1.0).toDouble();
    price = (args['price'] ?? 0.0).toDouble();
    rating = (args['rating'] ?? 5.0).toDouble();
    reviewsCount = (args['reviewsCount'] ?? 0).toInt();
    updatedAt = args['updatedAt']?.toString();

    step = isByWeight ? 0.25 : 1.0;
    currentAmount = 1.0; // Start at 1 unit (1kg or 1 piece) to show full price
  }

  void _increment(double cartQuantity) {
    final remainingStock = stock - cartQuantity;
    if (currentAmount + step > remainingStock) {
      _showStockError(remainingStock);
      return;
    }
    setState(() {
      currentAmount += step;
    });
  }

  void _decrement() {
    if (currentAmount > step) {
      setState(() {
        currentAmount -= step;
      });
    }
  }

  void _showStockError(double remaining) {
    final unit = isByWeight ? 'كغ' : 'قطعة';
    final message = remaining <= 0
        ? 'عذراً، هذا المنتج غير متوفر في المخزون حالياً.'
        : 'عذراً، الكمية المتاحة في المخزون هي $remaining $unit فقط (بعد احتساب ما في سلتك).';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailsCubit()..fetchProduct(id),
      child: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
        listener: (context, state) {
          if (state is ProductDetailsSuccess) {
            setState(() {
              id = state.product.id;
              title = state.product.name;
              image = state.product.imageUrl;
              description = state.product.description;
              isByWeight = state.product.isByWeight;
              stock = state.product.stockQuantity;
              price = state.product.displayPrice;
              rating = state.product.rating;
              reviewsCount = state.product.reviewsCount;
              step = isByWeight ? 0.25 : 1.0;
              updatedAt = state.product.updatedAt;

              // Only reset if it's less than step
              if (currentAmount < step) currentAmount = step;
            });
          }
        },
        builder: (context, state) {
          if (state is ProductDetailsLoading && title == '...') {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (state is ProductDetailsError && title == '...') {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message, style: GoogleFonts.tajawal()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProductDetailsCubit>().fetchProduct(id),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          double total = price * currentAmount;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              child: _buildTitleAndRating(),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: _buildDescription(),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              child: _buildQuantitySelector(),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 700),
                              child: _buildAddNoteSection(),
                            ),
                            const SizedBox(height: 32),
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: _buildRatingsSection(context, state),
                            ),
                            const SizedBox(
                              height: 140,
                            ), // Spacer for bottom bar
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                _buildBottomActionStack(total),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400.0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: Colors.white.withOpacity(0.8),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: id,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppCachedImage(
                imageUrl: image,
                updatedAt: updatedAt,
                fit: BoxFit.cover,
                errorWidget: Container(color: Colors.grey.shade100),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
                  builder: (context, state) {
                    final hasOffer =
                        state is ProductDetailsSuccess &&
                        state.product.hasOffer;
                    final originalPrice = state is ProductDetailsSuccess
                        ? state.product.price
                        : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasOffer && originalPrice != null)
                          Text(
                            '${originalPrice.toStringAsFixed(3)} JOD',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '${price.toStringAsFixed(3)} JOD',
                          style: GoogleFonts.tajawal(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Text(
                  isByWeight ? 'لكل كيلوغرام' : 'لكل قطعة',
                  style: GoogleFonts.tajawal(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$reviewsCount مراجعة',
              style: GoogleFonts.tajawal(color: Colors.black, fontSize: 13),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isByWeight ? 'منتج بالوزن' : 'منتج بالقطعة',
                style: GoogleFonts.tajawal(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عن المنتج',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          description,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: Colors.black,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    final cartState = context.read<CartCubit>().state;
    final cartQuantity = cartState.items[id]?.quantity ?? 0.0;
    final remainingStock = stock - cartQuantity;
    final unit = isByWeight ? 'كغ' : 'قطعة';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isByWeight ? 'حدد الوزن المفضل' : 'حدد الكمية المطلوبة',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (cartQuantity > 0)
              Text(
                'في سلتك: ${isByWeight ? cartQuantity.toStringAsFixed(2) : cartQuantity.toInt()} $unit',
                style: GoogleFonts.tajawal(fontSize: 12, color: Colors.orange),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQtyBtn(Icons.remove, _decrement),
              Text(
                '${isByWeight ? currentAmount.toStringAsFixed(2) : currentAmount.toInt()} $unit',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              _buildQtyBtn(Icons.add, () => _increment(cartQuantity)),
            ],
          ),
        ),
        if (stock == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'هذا المنتج غير متوفر حالياً.',
              style: GoogleFonts.tajawal(color: Colors.red, fontSize: 12),
            ),
          )
        else if (remainingStock <= 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'لقد وصلت لأقصى كمية متاحة في المخزون لهذا المنتج.',
              style: GoogleFonts.tajawal(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildAddNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات خاصة',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 2,
          style: GoogleFonts.tajawal(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'مثلاً: محمص زيادة، قليل الملح...',
            hintStyle: GoogleFonts.tajawal(color: Colors.black, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionStack(double total) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(
          20,
        ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الإجمالي المتوقع',
                    style: GoogleFonts.tajawal(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(3)} JOD',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _isAddingToCart
                    ? null
                    : () async {
                        setState(() {
                          _isAddingToCart = true;
                        });

                        // Validate stock vs existing cart quantity
                        final cartState = context.read<CartCubit>().state;
                        final cartQty = cartState.items[id]?.quantity ?? 0.0;
                        final unit = isByWeight ? 'كغ' : 'قطعة';

                        if (stock == 0) {
                          setState(() => _isAddingToCart = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('هذا المنتج غير متوفر حالياً.',
                                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ));
                          return;
                        }

                        if (cartQty + currentAmount > stock) {
                          setState(() => _isAddingToCart = false);
                          final remaining = (stock - cartQty).clamp(0.0, stock);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              remaining <= 0
                                  ? 'لقد وصلت للحد الأقصى لهذا المنتج في سلتك.'
                                  : 'الكمية المتاحة من هذا المنتج هي ${isByWeight ? remaining.toStringAsFixed(2) : remaining.toInt()} $unit فقط (بعد احتساب ما في سلتك).',
                              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ));
                          return;
                        }

                        await context.read<CartCubit>().addItem(
                          CartItem(
                            id: id,
                            title: title,
                            imageUrl: image,
                            price: price,
                            quantity: currentAmount,
                            isByWeight: isByWeight,
                            itemNote: _noteController.text,
                            updatedAt: updatedAt,
                          ),
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    'تم إضافة $title إلى السلة بنجاح!',
                                    style: GoogleFonts.tajawal(),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(milliseconds: 1500),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          setState(() {
                            _isAddingToCart = false;
                          });
                          
                          // ننتظر قليلاً ليقرأ المستخدم الرسالة ثم ننتقل
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              Navigator.pushNamed(context, Routes.cart);
                            }
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'أضف إلى السلة',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.shopping_basket_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsSection(BuildContext context, ProductDetailsState state) {
    List<dynamic> ratings = [];

    if (state is ProductDetailsSuccess) {
      ratings = state.ratings;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقييمات والمراجعات',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showRatingDialog(context),
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: Text(
                'أضف تقييمك',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ratings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لا توجد تقييمات لهذا المنتج بعد.\nكن أول من يقيمه!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ratings.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final ratingItem = ratings[index];
              return _buildRatingItem(ratingItem);
            },
          ),
      ],
    );
  }

  Widget _buildRatingItem(dynamic rating) {
    final String userName = rating['user_name'] ?? 'مستخدم';
    final String? userImage = rating['user_image'];
    final double score =
        double.tryParse(rating['rating']?.toString() ?? '0') ?? 0.0;
    final String? review = rating['review'];
    final DateTime date = DateTime.parse(rating['created_at']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: userImage != null
                  ? NetworkImage('${EndPoint.imageBaseUrl}$userImage')
                  : null,
              child: userImage == null
                  ? const Icon(Icons.person, size: 18, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd').format(date),
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            RatingBarIndicator(
              rating: score,
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.orange),
              itemCount: 5,
              itemSize: 14.0,
              direction: Axis.horizontal,
            ),
          ],
        ),
        if (review != null && review.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 46),
            child: Text(
              review,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showRatingDialog(BuildContext context) {
    if (!context.read<UserCubit>().isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'تسجيل الدخول مطلوب',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'يرجى تسجيل الدخول لتتمكن من إضافة تقييمك ومشاركة رأيك مع الآخرين.',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(fontSize: 14),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, Routes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'تسجيل الدخول',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    double selectedRating = 5.0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تقييم المنتج',
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ما رأيك في $title؟',
              style: GoogleFonts.tajawal(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (rating) {
                selectedRating = rating;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب رأيك هنا (اختياري)...',
                hintStyle: GoogleFonts.tajawal(fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: GoogleFonts.tajawal(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final cubit = context.read<ProductDetailsCubit>();
              Navigator.pop(dialogContext);

              try {
                // Ensure we get the latest token from storage
                final token = await const FlutterSecureStorage().read(
                  key: 'token',
                );

                if (token == null) {
                  throw Exception('Unauthorized');
                }

                await cubit.addProductRating(
                  id,
                  selectedRating,
                  reviewController.text,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'شكراً لتقييمك! تم حفظه بنجاح.',
                        style: GoogleFonts.tajawal(),
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'عذراً، يجب تسجيل الدخول للتمكن من التقييم.',
                        style: GoogleFonts.tajawal(),
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'إرسال',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
