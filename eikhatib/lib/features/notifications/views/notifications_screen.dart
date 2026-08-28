// ignore_for_file: deprecated_member_use

import 'package:eikhatib/core/routes/routes.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eikhatib/core/theme/colors.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../auth/logic/user_cubit.dart';
import '../logic/notifications_cubit.dart';
import '../data/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserCubit>().isLoggedIn;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الإشعارات',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (isLoggedIn)
              TextButton(
                onPressed: () =>
                    context.read<NotificationsCubit>().markAllAsRead(),
                child: Text(
                  'تحديد كقروء',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        body: !isLoggedIn
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 70,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'سجل الدخول لعرض الإشعارات',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'تابع أحدث العروض والطلبات والتحديثات فور تسجيل الدخول.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.login),
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: Text(
                          'تسجيل الدخول',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.bell,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد إشعارات حالياً',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<NotificationsCubit>().refreshNotifications(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: ListView.separated(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _SwipeableNotificationCard(
                    key: ValueKey(notification.id),
                    notification: notification,
                    onDismissed: () {
                      context.read<NotificationsCubit>().deleteNotification(
                        notification.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حذف الإشعار',
                            style: GoogleFonts.tajawal(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Swipeable wrapper
// ─────────────────────────────────────────────
class _SwipeableNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDismissed;

  const _SwipeableNotificationCard({
    super.key,
    required this.notification,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      // سحب من اليمين لليسار (RTL: المستخدم يسحب ناحية اليمين على الشاشة)
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'حذف',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      child: _NotificationCard(notification: notification),
    );
  }
}

// ─────────────────────────────────────────────
// Notification Card
// ─────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.notificationDetails,
          arguments: notification,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primary.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade200
                : AppColors.primary.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Icon
            if (notification.imageUrl != null)
              AppCachedImage(
                imageUrl: notification.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
                errorWidget: Center(child: _buildPlaceholderIcon()),
              )
            else
              _buildPlaceholderIcon(),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'hh:mm a',
                          'ar',
                        ).format(notification.timestamp),
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.bell,
          color: AppColors.primary,
          size: 30,
        ),
      ),
    );
  }
}
