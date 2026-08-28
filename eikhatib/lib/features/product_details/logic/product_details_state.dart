import 'package:equatable/equatable.dart';
import '../../../../core/models/product_model.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsSuccess extends ProductDetailsState {
  final ProductModel product;
  final List<dynamic> ratings;
  final bool isRatingSubmitting;

  const ProductDetailsSuccess({
    required this.product,
    this.ratings = const [],
    this.isRatingSubmitting = false,
  });

  ProductDetailsSuccess copyWith({
    ProductModel? product,
    List<dynamic>? ratings,
    bool? isRatingSubmitting,
  }) {
    return ProductDetailsSuccess(
      product: product ?? this.product,
      ratings: ratings ?? this.ratings,
      isRatingSubmitting: isRatingSubmitting ?? this.isRatingSubmitting,
    );
  }

  @override
  List<Object?> get props => [product, ratings, isRatingSubmitting];
}

class ProductDetailsError extends ProductDetailsState {
  final String message;

  const ProductDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
