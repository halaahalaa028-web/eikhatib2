import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double quantity;
  final bool isByWeight;
  final String? itemNote;
  final String? updatedAt;

  const CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.quantity,
    required this.isByWeight,
    this.itemNote,
    this.updatedAt,
  });

  CartItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? price,
    double? originalPrice,
    double? quantity,
    bool? isByWeight,
    String? itemNote,
    String? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      isByWeight: isByWeight ?? this.isByWeight,
      itemNote: itemNote ?? this.itemNote,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['product_id'] ?? json['id'] ?? json['productId'])?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      price: (json['has_offer'] == 1)
          ? (double.tryParse(json['offer_price']?.toString() ?? '0') ?? 0.0)
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      originalPrice: (json['has_offer'] == 1)
          ? (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0)
          : null,
      quantity: double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      isByWeight: json['is_by_weight'] == 1 || json['is_by_weight'] == true || json['isByWeight'] == true,
      itemNote: json['item_note'] ?? json['itemNote'],
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': id,
      'quantity': quantity,
      'itemNote': itemNote,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        imageUrl,
        price,
        originalPrice,
        quantity,
        isByWeight,
        itemNote,
        updatedAt,
      ];
}
