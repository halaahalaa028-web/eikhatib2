// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';
import '../data/models/notification_model.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            // Premium Header with Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (notification.imageUrl != null)
                      AppCachedImage(
                        imageUrl: notification.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          size: 80,
                          color: AppColors.primary2,
                        ),
                      ),
                    // Gradient overlay for better readability if needed
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time Row
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today_rounded,
                          DateFormat(
                            'yyyy/MM/dd',
                            'ar',
                          ).format(notification.timestamp),
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.access_time_rounded,
                          DateFormat(
                            'hh:mm a',
                            'ar',
                          ).format(notification.timestamp),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      notification.title,
                      style: GoogleFonts.tajawal(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      notification.description,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 100), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
