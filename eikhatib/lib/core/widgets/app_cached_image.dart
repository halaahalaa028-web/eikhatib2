import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/end_point.dart';

/// Widget مركزي للصور المحملة من الإنترنت مع دعم الكاشنج التلقائي.
/// يستخدم [CachedNetworkImage] لتخزين الصور محلياً وتجنب التحميل المتكرر.
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final String? updatedAt;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.updatedAt,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    String finalUrl = imageUrl;
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      // Prepend base URL if relative (assuming it starts with / or is just the path)
      finalUrl =
          '${EndPoint.imageBaseUrl.replaceAll(RegExp(r'/$'), '')}/${imageUrl.replaceAll(RegExp(r'^/'), '')}';
    }

    Widget image = CachedNetworkImage(
      imageUrl: finalUrl,
      cacheKey: updatedAt != null && updatedAt!.isNotEmpty ? '${finalUrl}_$updatedAt' : finalUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A2DE0)),
                ),
              ),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_rounded,
                color: Colors.grey,
                size: 32,
              ),
            ),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
