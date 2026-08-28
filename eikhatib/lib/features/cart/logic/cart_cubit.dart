import 'package:dio/dio.dart';
import 'package:eikhatib/core/api/dio_consumer.dart';
import '../../../../core/api/end_point.dart';
import '../../../core/cache/cache_helper.dart';
import 'package:eikhatib/features/cart/views/widgets/promo_code_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/cart_item.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartInitial()) {
    fetchCart();
  }

  final Map<String, CartItem> _items = {};
  final DioConsumer _apiConsumer = DioConsumer(dio: Dio());

  Future<String?> _getToken() async {
    return await SecureCacheHelper().getData(key: ApiKey.token);
  }

  Future<void> fetchCart() async {
    final token = await _getToken();
    if (token == null) return;

    emit(
      CartLoading(
        items: Map.from(_items),
        totalPrice: totalPrice,
        totalQuantity: totalQuantity,
        totalSavings: totalSavings,
        appliedPromo: _appliedPromo,
        discountAmount: discountAmount,
      ),
    );

    try {
      final response = await _apiConsumer.get(EndPoint.cart);

      final List cartData = response['cart'];
      final Map<String, CartItem> newItems = {};
      for (var itemJson in cartData) {
        final item = CartItem.fromJson(itemJson);
        newItems[item.id] = item;
      }
      
      _items.clear();
      _items.addAll(newItems);
      _emitUpdatedState();
    } catch (e) {
      emit(
        CartError(
          'فشل تحديث السلة من السيرفر',
          items: Map.from(_items),
          totalPrice: totalPrice,
          totalQuantity: totalQuantity,
          totalSavings: totalSavings,
          appliedPromo: _appliedPromo,
          discountAmount: discountAmount,
        ),
      );
    }
  }

  Future<void> addItem(CartItem item) async {
    // Optimistic update
    if (_items.containsKey(item.id)) {
      _items[item.id] = _items[item.id]!.copyWith(
        quantity: _items[item.id]!.quantity + item.quantity,
      );
    } else {
      _items[item.id] = item;
    }
    _emitUpdatedState();

    try {
      await _apiConsumer.post(
        EndPoint.cart,
        data: item.toJson(),
      );
      // Optional: fetchCart() to sync with server-calculated price/stock
    } catch (e) {
      // Keep optimistic state but you might want to show an error
      // fetchCart(); // Don't call this as it might clear the optimistic update if server is out of sync
    }
  }

  Future<void> updateQuantity(String id, double newQuantity) async {
    final originalItem = _items[id];
    if (newQuantity <= 0) {
      _items.remove(id);
    } else if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: newQuantity);
    }
    _emitUpdatedState();

    try {
      await _apiConsumer.patch(
        '${EndPoint.cart}/update',
        data: {'productId': id, 'quantity': newQuantity},
      );
    } catch (e) {
      if (originalItem != null) _items[id] = originalItem;
      _emitUpdatedState();
    }
  }

  Future<void> updateNote(String id, String note) async {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(itemNote: note);
    }
    _emitUpdatedState();

    try {
      await _apiConsumer.patch(
        '${EndPoint.cart}/update',
        data: {
          'productId': id,
          'quantity': _items[id]?.quantity ?? 1.0,
          'itemNote': note,
        },
      );
    } catch (e) {
      // Re-fetch to be safe
      fetchCart();
    }
  }

  Future<void> removeItem(String id) async {
    final originalItem = _items[id];
    _items.remove(id);
    _emitUpdatedState();

    try {
      await _apiConsumer.delete(
        '${EndPoint.cart}/$id',
      );
    } catch (e) {
      if (originalItem != null) _items[id] = originalItem;
      _emitUpdatedState();
    }
  }

  Future<void> clearCart() async {
    final originalItems = Map<String, CartItem>.from(_items);
    _items.clear();
    _emitUpdatedState();

    try {
      await _apiConsumer.delete(
        '${EndPoint.cart}/clear',
      );
    } catch (e) {
      _items.addAll(originalItems);
      _emitUpdatedState();
    }
  }

  PromoCode? _appliedPromo;

  void applyPromoCode(PromoCode? promo) {
    _appliedPromo = promo;
    _emitUpdatedState();
  }

  double get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalItems => _items.values.length.toDouble();

  double get totalPrice {
    return _items.values.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double get totalSavings {
    return _items.values.fold(0, (sum, item) {
      if (item.originalPrice != null && item.originalPrice! > item.price) {
        return sum + ((item.originalPrice! - item.price) * item.quantity);
      }
      return sum;
    });
  }

  double get discountAmount {
    if (_appliedPromo == null) return 0.0;
    if (_appliedPromo!.isPercentage) {
      return (totalPrice * _appliedPromo!.discount) / 100;
    } else {
      return _appliedPromo!.discount;
    }
  }

  void _emitUpdatedState() {
    emit(
      CartUpdated(
        items: Map.from(_items),
        totalPrice: totalPrice,
        totalQuantity: totalQuantity,
        totalSavings: totalSavings,
        appliedPromo: _appliedPromo,
        discountAmount: discountAmount,
      ),
    );
  }
}
