import 'dart:async';
import 'package:dio/dio.dart';
import 'package:eikhatib/features/auth/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/api/end_point.dart';
import '../../../core/cache/cache_helper.dart';
import '../data/models/order_model.dart';
import '../data/models/order_status.dart';

// ── States ───────────────────────────────────────────────────────────────────

class OrdersState extends Equatable {
  final List<OrderModel> orders; // For customer
  final List<OrderModel> driverOrders; // For driver's own tasks
  final List<OrderModel> availableOrders; // For public driver queue
  final bool isLoading;
  final String? error;

  const OrdersState({
    this.orders = const [],
    this.driverOrders = const [],
    this.availableOrders = const [],
    this.isLoading = false,
    this.error,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? driverOrders,
    List<OrderModel>? availableOrders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      driverOrders: driverOrders ?? this.driverOrders,
      availableOrders: availableOrders ?? this.availableOrders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [orders, driverOrders, availableOrders, isLoading, error];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class OrdersCubit extends Cubit<OrdersState> {
  Timer? _pollingTimer;

  OrdersCubit() : super(const OrdersState()) {
    fetchOrders();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // Only poll if there's an active order out for delivery
      final hasActiveOrder = state.orders.any(
        (o) => o.status == OrderStatus.outForDelivery,
      );
      if (hasActiveOrder) {
        fetchOrders(silent: true);
      }
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  final Dio _dio = Dio();

  Future<Options> _getOptions() async {
    final token = await SecureCacheHelper().getData(key: ApiKey.token);
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ── Fetch all orders from backend (Customer) ─────────────────────────────
  Future<void> fetchOrders({bool silent = false}) async {
    final token = await SecureCacheHelper().getData(key: ApiKey.token);
    if (token == null) return;

    if (!silent) emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.orders}',
        options: await _getOptions(),
      );
      final List data = response.data['orders'] ?? [];
      final orders = data.map((json) => OrderModel.fromJson(json)).toList();
      emit(state.copyWith(orders: orders, isLoading: false, clearError: true));
    } catch (e) {
      if (!silent) {
        emit(state.copyWith(isLoading: false, error: 'فشل تحميل الطلبات'));
      }
    }
  }

  // ── Driver: Fetch available orders ────────────────────────────────────────
  Future<void> fetchAvailableOrders() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.driverAvailable}',
        options: await _getOptions(),
      );
      final List data = response.data['orders'] ?? [];
      final orders = data.map((json) => OrderModel.fromJson(json)).toList();
      emit(state.copyWith(availableOrders: orders, isLoading: false, clearError: true));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: 'فشل تحميل الطلبات المتاحة'),
      );
    }
  }

  // ── Driver: Fetch my active orders ────────────────────────────────────────
  Future<void> fetchDriverOrders() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.driverMyOrders}',
        options: await _getOptions(),
      );
      final List data = response.data['orders'] ?? [];
      final orders = data.map((json) => OrderModel.fromJson(json)).toList();
      emit(state.copyWith(driverOrders: orders, isLoading: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل تحميل طلباتك'));
    }
  }

  // ── Driver: Accept an order ────────────────────────────────────────────────
  Future<void> acceptOrder(String id) async {
    try {
      await _dio.patch(
        '${EndPoint.baseUrl}${EndPoint.acceptOrder(id)}',
        options: await _getOptions(),
      );
      await fetchDriverOrders(); // Refresh local list
    } catch (e) {
      emit(state.copyWith(error: 'فشل قبول الطلب'));
    }
  }

  // ── Driver: Update order status ────────────────────────────────────────────
  Future<void> updateStatus(String id, String status) async {
    try {
      await _dio.patch(
        '${EndPoint.baseUrl}${EndPoint.updateOrderStatus(id)}',
        data: {'status': status},
        options: await _getOptions(),
      );
      await fetchDriverOrders();
    } catch (e) {
      emit(state.copyWith(error: 'فشل تحديث الحالة'));
    }
  }

  // ── Driver: Update location ────────────────────────────────────────────────
  Future<void> updateOrderLocation(String id, double lat, double lng) async {
    try {
      await _dio.patch(
        '${EndPoint.baseUrl}${EndPoint.updateLocation(id)}',
        data: {'latitude': lat, 'longitude': lng},
        options: await _getOptions(),
      );
    } catch (_) {}
  }

  // ── Add / place a new order ───────────────────────────────────────────────
  Future<bool> addOrder(OrderModel order) async {
    // Optimistic: insert locally first
    final updatedOrders = List<OrderModel>.from(state.orders)..insert(0, order);
    emit(state.copyWith(orders: updatedOrders));

    try {
      // Build payload matching the backend controller
      final payload = {
        'id': order.id,
        'transactionId': order.transactionId,
        'items': order.items
            .map(
              (item) => {
                'id': item.id,
                'productId': item.id,
                'title': item.title,
                'imageUrl': item.imageUrl,
                'isByWeight': item.isByWeight,
                'quantity': item.quantity,
                'price': item.price,
                'itemNote': item.itemNote,
              },
            )
            .toList(),
        'subtotal': order.subtotal,
        'deliveryFee': order.deliveryFee,
        'taxes': order.taxes,
        'total': order.total,
        'address': order.address?.toJson(),
        'paymentMethod': order.paymentMethod,
        'notes': order.notes,
      };

      await _dio.post(
        '${EndPoint.baseUrl}${EndPoint.orders}',
        data: payload,
        options: await _getOptions(),
      );
      return true;
    } catch (e) {
      // Rollback: remove the order we optimistically added
      final rolledBack = state.orders.where((o) => o.id != order.id).toList();
      String errorMsg = 'فشل إرسال الطلب';
      if (e is DioException && e.response?.data != null && e.response?.data['message'] != null) {
        errorMsg = e.response!.data['message'].toString();
      }
      emit(state.copyWith(orders: rolledBack, error: errorMsg));
      // Debug logging
      if (e is DioException) {
        debugPrint('===== ORDER ERROR =====');
        debugPrint('Status: ${e.response?.statusCode}');
        debugPrint('Response: ${e.response?.data}');
        debugPrint('Message: ${e.message}');
        debugPrint('Type: ${e.type}');
        debugPrint('=======================');
      } else {
        debugPrint('===== ORDER ERROR (non-Dio): $e =====');
      }
      return false;
    }
  }

  // ── Get a single order by ID (from local state) ───────────────────────────
  OrderModel? getOrderById(String id) {
    try {
      return state.orders.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Rate an order ─────────────────────────────────────────────────────────
  Future<void> rateOrder(String id, double rating) async {
    // Optimistic local update
    final updatedOrders = state.orders.map((order) {
      if (order.id == id) return order.copyWith(rating: rating);
      return order;
    }).toList();
    emit(state.copyWith(orders: updatedOrders));

    try {
      await _dio.patch(
        '${EndPoint.baseUrl}${EndPoint.orders}/$id/rate',
        data: {'rating': rating},
        options: await _getOptions(),
      );
    } catch (_) {
      // Ignore — the local update is already done
    }
  }

  // ── Rate a product ────────────────────────────────────────────────────────
  Future<void> rateProduct(String productId, double rating, {String? review}) async {
    try {
      await _dio.post(
        '${EndPoint.baseUrl}${EndPoint.products}/$productId/rate',
        data: {
          'rating': rating,
          'review': review,
        },
        options: await _getOptions(),
      );
    } catch (_) {
      // Ignore
    }
  }

  // ── Mark rating prompt as seen ────────────────────────────────────────────
  Future<void> markRatingPromptAsSeen(String id) async {
    final updatedOrders = state.orders.map((order) {
      if (order.id == id) return order.copyWith(hasSeenRatingPrompt: true);
      return order;
    }).toList();
    emit(state.copyWith(orders: updatedOrders));

    try {
      await _dio.patch(
        '${EndPoint.baseUrl}${EndPoint.orders}/$id/dismiss-rating',
        options: await _getOptions(),
      );
    } catch (_) {}
  }

  // ── Admin Simulation Methods ─────────────────────────────────────────────
  Future<void> fetchOrdersAdmin() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await _dio.get('${EndPoint.baseUrl}orders/all');
      final List data = response.data['orders'] ?? [];
      final orders = data.map((json) => OrderModel.fromJson(json)).toList();
      emit(state.copyWith(orders: orders, isLoading: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل تحميل كافة الطلبات'));
    }
  }

  Future<List<UserModel>> getAllDrivers() async {
    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.getAllDrivers}',
      );
      final List<dynamic> driversJson = response.data['drivers'];
      return driversJson.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> assignDriver(String orderId, String driverId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _dio.patch(
        '${EndPoint.baseUrl}${EndPoint.orders}/$orderId/assign',
        data: {'driver_id': driverId},
        options: await _getOptions(),
      );
      // Refresh orders
      await fetchOrders();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل تعيين السائق'));
    }
  }
}
