part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  final Map<String, CartItem> items;
  final double totalPrice; // Subtotal
  final double totalQuantity;
  final double totalSavings; // Savings from product offers
  final PromoCode? appliedPromo;
  final double discountAmount; // Discount from promo code

  const CartState({
    this.items = const {},
    this.totalPrice = 0.0,
    this.totalQuantity = 0.0,
    this.totalSavings = 0.0,
    this.appliedPromo,
    this.discountAmount = 0.0,
  });

  @override
  List<Object?> get props => [
    items,
    totalPrice,
    totalQuantity,
    totalSavings,
    appliedPromo,
    discountAmount,
  ];
}

class CartInitial extends CartState {
  const CartInitial() : super();
}

class CartUpdated extends CartState {
  const CartUpdated({
    required super.items,
    required super.totalPrice,
    required super.totalQuantity,
    required super.totalSavings,
    super.appliedPromo,
    super.discountAmount = 0.0,
  });
}

class CartLoading extends CartState {
  const CartLoading({super.items, super.totalPrice, super.totalQuantity, super.totalSavings, super.appliedPromo, super.discountAmount});
}

class CartError extends CartState {
  final String message;
  const CartError(this.message, {super.items, super.totalPrice, super.totalQuantity, super.totalSavings, super.appliedPromo, super.discountAmount});

  @override
  List<Object?> get props => [...super.props, message];
}
