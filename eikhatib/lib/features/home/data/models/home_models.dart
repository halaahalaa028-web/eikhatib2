import '../../../cart/data/models/cart_item.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String? linkType;
  final String? linkTarget;
  final String? updatedAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.linkType,
    this.linkTarget,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'].toString(),
      imageUrl: json['image_url'] ?? '',
      linkType: json['link_type'],
      linkTarget: json['link_target'],
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? parentId;
  final List<ProductModel>? products;
  final String? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.parentId,
    this.products,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      parentId: (json['parent_id'] ?? json['parentId'])?.toString(),
      products: json['products'] != null
          ? (json['products'] as List)
                .map((e) => ProductModel.fromJson(e))
                .toList()
          : null,
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final bool hasOffer;
  final double? offerPrice;
  final bool isByWeight;
  final double stockQuantity;
  final double rating;
  final int reviewsCount;
  final int salesCount;
  final bool isFeatured;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.hasOffer,
    this.offerPrice,
    required this.isByWeight,
    required this.stockQuantity,
    required this.rating,
    required this.reviewsCount,
    required this.salesCount,
    required this.isFeatured,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      hasOffer: json['has_offer'] == 1 || json['has_offer'] == true,
      offerPrice: json['offer_price'] != null
          ? double.tryParse(json['offer_price'].toString())
          : null,
      isByWeight: json['is_by_weight'] == 1 || json['is_by_weight'] == true,
      stockQuantity:
          double.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      salesCount: json['sales_count'] ?? 0,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      updatedAt: json['updated_at']?.toString(),
    );
  }

  CartItem toCartItem({double quantity = 1.0}) {
    return CartItem(
      id: id,
      title: name,
      imageUrl: imageUrl,
      price: hasOffer ? (offerPrice ?? price) : price,
      originalPrice: hasOffer ? price : null,
      quantity: quantity,
      isByWeight: isByWeight,
      updatedAt: updatedAt,
    );
  }

  // Get displayed price
  double get currentPrice => hasOffer ? (offerPrice ?? price) : price;

  // Calculate discount percentage helper
  String? get discountText {
    if (hasOffer && offerPrice != null && price > 0) {
      final discount = (((price - offerPrice!) / price) * 100).toStringAsFixed(
        0,
      );
      return '$discount% خصم';
    }
    return null;
  }
}

class HomeDataModel {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> featured;
  final List<ProductModel> offers;
  final List<ProductModel> bestSellers;
  final List<PopupAdModel> ads;

  HomeDataModel({
    required this.banners,
    required this.categories,
    required this.featured,
    required this.offers,
    required this.bestSellers,
    required this.ads,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      banners:
          (json['banners'] as List?)
              ?.map((e) => BannerModel.fromJson(e))
              .toList() ??
          [],
      categories:
          (json['categories'] as List?)
              ?.map((e) => CategoryModel.fromJson(e))
              .toList() ??
          [],
      featured:
          (json['featured'] as List?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
      offers:
          (json['offers'] as List?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
      bestSellers:
          (json['best_sellers'] as List?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
      ads:
          (json['ads'] as List?)
              ?.map((e) => PopupAdModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PopupAdModel {
  final String id;
  final String? title;
  final String? description;
  final String imageUrl;
  final int durationDays;
  final int durationHours;
  final bool isActive;
  final String expiresAt;
  final String? updatedAt;

  PopupAdModel({
    required this.id,
    this.title,
    this.description,
    required this.imageUrl,
    required this.durationDays,
    required this.durationHours,
    required this.isActive,
    required this.expiresAt,
    this.updatedAt,
  });

  factory PopupAdModel.fromJson(Map<String, dynamic> json) {
    return PopupAdModel(
      id: json['id']?.toString() ?? '',
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      durationHours: json['duration_hours'] ?? 0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      expiresAt: json['expires_at'] ?? '',
      updatedAt: json['updated_at']?.toString() ?? json['created_at']?.toString(),
    );
  }
}
