import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/loyalty_point_model.dart';

class LoyaltyState {
  final List<LoyaltyPointModel> history;
  final int totalPoints;
  final bool isLoading;

  const LoyaltyState({
    this.history = const [],
    this.totalPoints = 0,
    this.isLoading = false,
  });

  LoyaltyState copyWith({
    List<LoyaltyPointModel>? history,
    int? totalPoints,
    bool? isLoading,
  }) {
    return LoyaltyState(
      history: history ?? this.history,
      totalPoints: totalPoints ?? this.totalPoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LoyaltyCubit extends Cubit<LoyaltyState> {
  LoyaltyCubit() : super(const LoyaltyState()) {
    loadLoyaltyData();
  }

  void loadLoyaltyData() {
    emit(state.copyWith(isLoading: true));
    // Simulated delay for premium feel
    Future.delayed(const Duration(milliseconds: 1000), () {
      final mockHistory = [
        LoyaltyPointModel(
          id: '1',
          title: 'كيكة شوكولاتة نوتيلا',
          description: 'حصلت على نقاط مقابل شراء حلويات',
          points: 100,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          imageUrl:
              'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=200&q=80',
        ),
        LoyaltyPointModel(
          id: '2',
          title: 'كرواسون زبدة فرنسي',
          description: 'نقاط إضافية من قسم المخبوزات',
          points: 100,
          date: DateTime.now().subtract(const Duration(days: 1)),
          imageUrl:
              'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=200&q=80',
        ),
        LoyaltyPointModel(
          id: '3',
          title: 'مكافأة التسجيل',
          description: 'شكراً لانضمامك إلينا، إليك هدية ترحيبية',
          points: 1000,
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
        LoyaltyPointModel(
          id: '4',
          title: 'سلة فواكه طازجة',
          description: 'من عملية شراء رقم #2215',
          points: 1800,
          date: DateTime.now().subtract(const Duration(days: 10)),
          imageUrl:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=200&q=80',
        ),
      ];

      int total = 0;
      for (var item in mockHistory) {
        if (item.isEarned) {
          total += item.points;
        } else {
          total -= item.points;
        }
      }

      emit(state.copyWith(
        isLoading: false,
        history: mockHistory,
        totalPoints: total,
      ));
    });
  }

  void redeemPoints() {
    if (state.totalPoints >= 3000) {
      final redemption = LoyaltyPointModel(
        id: 'redeem_${DateTime.now().millisecondsSinceEpoch}',
        title: 'تبديل نقاط بقسيمة',
        description: 'تم استخدام 3000 نقطة مقابل قسيمة خصم 2 دينار',
        points: 3000,
        date: DateTime.now(),
        isEarned: false,
      );

      final updatedHistory = List<LoyaltyPointModel>.from(state.history)
        ..insert(0, redemption);

      emit(state.copyWith(
        totalPoints: state.totalPoints - 3000,
        history: updatedHistory,
      ));
    }
  }
}
