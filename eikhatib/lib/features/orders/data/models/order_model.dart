import 'package:eikhatib/features/cart/data/models/address_model.dart';
import 'package:eikhatib/features/cart/data/models/cart_item.dart';
// If promo code model is needed, can use dynamic for now

class OrderModel {
  final String id;
  final String transactionId;
  final DateTime date;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double total;
  final AddressModel? address;
  final String paymentMethod;
  final String notes;
  final String status;
  final double? rating;
  final bool hasSeenRatingPrompt;
  final double? driverLatitude;
  final double? driverLongitude;

  OrderModel({
    required this.id,
    required this.transactionId,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.total,
    this.address,
    required this.paymentMethod,
    required this.notes,
    this.status = 'بانتظار الموافقة',
    this.rating,
    this.hasSeenRatingPrompt = false,
    this.driverLatitude,
    this.driverLongitude,
  });

  OrderModel copyWith({
    String? id,
    String? transactionId,
    DateTime? date,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? taxes,
    double? total,
    AddressModel? address,
    String? paymentMethod,
    String? notes,
    String? status,
    double? rating,
    bool? hasSeenRatingPrompt,
    double? driverLatitude,
    double? driverLongitude,
  }) {
    return OrderModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      date: date ?? this.date,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxes: taxes ?? this.taxes,
      total: total ?? this.total,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      hasSeenRatingPrompt: hasSeenRatingPrompt ?? this.hasSeenRatingPrompt,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      transactionId: json['transactionId'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['deliveryFee']?.toString() ?? '0') ?? 0.0,
      taxes: double.tryParse(json['taxes']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
      paymentMethod: json['paymentMethod'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'بانتظار الموافقة',
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      hasSeenRatingPrompt: json['hasSeenRatingPrompt'] == true,
      driverLatitude: json['driverLatitude'] != null ? double.tryParse(json['driverLatitude'].toString()) : null,
      driverLongitude: json['driverLongitude'] != null ? double.tryParse(json['driverLongitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'taxes': taxes,
      'total': total,
      'address': address?.toJson(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'status': status,
      'rating': rating,
      'hasSeenRatingPrompt': hasSeenRatingPrompt,
      'driverLatitude': driverLatitude,
      'driverLongitude': driverLongitude,
    };
  }
}
