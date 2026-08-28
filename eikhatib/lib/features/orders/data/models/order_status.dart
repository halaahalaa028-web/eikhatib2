import 'package:eikhatib/core/theme/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';

/// Centralised status definitions — single source of truth for all 5 states.
class OrderStatus {
  static const String pending = 'بانتظار الموافقة';
  static const String preparing = 'قيد التحضير';
  static const String outForDelivery = 'خرج للتوصيل';
  static const String delivered = 'تم التوصيل';
  static const String cancelled = 'ملغي';

  static Color color(String status) {
    switch (status) {
      case pending:
        return const Color(0xFFF59E0B); // Amber
      case preparing:
        return AppColors.primary;
      case outForDelivery:
        return const Color(0xFF3B82F6); // Blue
      case delivered:
        return const Color(0xFF10B981); // Emerald green
      case cancelled:
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case pending:
        return Icons.hourglass_empty_rounded;
      case preparing:
        return Icons.soup_kitchen_rounded;
      case outForDelivery:
        return Icons.delivery_dining_rounded;
      case delivered:
        return Icons.check_circle_rounded;
      case cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  static String animations(String status) {
    switch (status) {
      case pending:
        return AppAssets.wating;
      case preparing:
        return AppAssets.preparing;
      case outForDelivery:
        return AppAssets.driver;
      case delivered:
        return AppAssets.packageHandoff;
      case cancelled:
        return AppAssets.cancelled;
      default:
        return AppAssets.orderRejected;
    }
  }

  /// Whether this status belongs to the "active" tab
  static bool isActive(String status) =>
      status == pending || status == preparing || status == outForDelivery;
}
