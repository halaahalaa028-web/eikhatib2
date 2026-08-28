import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/dio_consumer.dart';
import '../data/models/notification_model.dart';

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final DioConsumer _api = DioConsumer(dio: Dio());

  NotificationsCubit() : super(const NotificationsState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final res = await _api.get('notifications');
      final List<dynamic> data = res['notifications'] ?? [];
      final list = data.map((e) => NotificationModel.fromJson(e)).toList();
      emit(state.copyWith(isLoading: false, notifications: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.patch('notifications/read-all');
      final updated = state.notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              title: n.title,
              description: n.description,
              imageUrl: n.imageUrl,
              timestamp: n.timestamp,
              isRead: true,
            ),
          )
          .toList();
      emit(state.copyWith(notifications: updated));
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    // Optimistically remove from list
    final updated = state.notifications.where((n) => n.id != id).toList();
    emit(state.copyWith(notifications: updated));
    try {
      await _api.delete('notifications/$id');
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}
