import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/coupon_model.dart';

class CouponsState {
  final List<CouponModel> coupons;
  final bool isLoading;

  const CouponsState({
    this.coupons = const [],
    this.isLoading = false,
  });

  CouponsState copyWith({
    List<CouponModel>? coupons,
    bool? isLoading,
  }) {
    return CouponsState(
      coupons: coupons ?? this.coupons,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CouponsCubit extends Cubit<CouponsState> {
  CouponsCubit() : super(const CouponsState()) {
    loadCoupons();
  }

  void loadCoupons() {
    emit(state.copyWith(isLoading: true));
    
    // Simulate API call
    Future.delayed(const Duration(milliseconds: 1200), () {
      final mockCoupons = [
        // Active
        CouponModel(
          id: 'c1',
          code: 'ELKHATIB20',
          title: 'خصم 20% على كل شيء',
          description:
              'استخدم هذا الكود عند الدفع للحصول على خصم 20% على إجمالي طلبك.',
          discount: 20,
          isPercentage: true,
          expiryDate: DateTime.now().add(const Duration(days: 5)),
        ),
        CouponModel(
          id: 'c2',
          code: 'WELCOME5',
          title: '5 دنانير هدية',
          description: 'خصم مباشر بقيمة 5 دنانير على طلبك القادم.',
          discount: 5,
          isPercentage: false,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        ),
        // Used
        CouponModel(
          id: 'c3',
          code: 'PAST15',
          title: 'خصم 15% (مستخدم)',
          description: 'لقد قمت باستخدام هذه القسيمة في طلبك السابق.',
          discount: 15,
          isPercentage: true,
          expiryDate: DateTime.now().add(const Duration(days: 20)),
          isUsed: true,
        ),
        // Expired
        CouponModel(
          id: 'c4',
          code: 'OLD_OFFER',
          title: 'عرض منتهي',
          description: 'هذه القسيمة لم تعد صالحة للاستخدام.',
          discount: 10,
          isPercentage: true,
          expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      emit(state.copyWith(isLoading: false, coupons: mockCoupons));
    });
  }

  void addCoupon(CouponModel coupon) {
    final updated = List<CouponModel>.from(state.coupons)..insert(0, coupon);
    emit(state.copyWith(coupons: updated));
  }
}
