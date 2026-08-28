import '../../features/cart/data/models/cart_item.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final bool hasOffer;
  final double? offerPrice;
  final bool isByWeight;
  final double stockQuantity;
  final double rating;
  final int reviewsCount;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.hasOffer = false,
    this.offerPrice,
    this.isByWeight = false,
    this.stockQuantity = 0,
    this.rating = 0,
    this.reviewsCount = 0,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      category: json['category'] ?? '',
      hasOffer: json['has_offer'] == 1 || json['has_offer'] == true,
      offerPrice: json['offer_price'] != null
          ? double.tryParse(json['offer_price'].toString())
          : null,
      isByWeight: json['is_by_weight'] == 1 || json['is_by_weight'] == true,
      stockQuantity:
          double.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      updatedAt: json['updated_at']?.toString(),
    );
  }

  double get displayPrice => hasOffer ? (offerPrice ?? price) : price;

  CartItem toCartItem({double quantity = 1.0}) {
    return CartItem(
      id: id,
      title: name,
      imageUrl: imageUrl,
      price: displayPrice,
      originalPrice: hasOffer ? price : null,
      quantity: quantity,
      isByWeight: isByWeight,
      updatedAt: updatedAt,
    );
  }
}
