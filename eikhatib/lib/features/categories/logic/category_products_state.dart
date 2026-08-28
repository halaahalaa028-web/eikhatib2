import 'package:equatable/equatable.dart';
import '../../home/data/models/home_models.dart';

abstract class CategoryProductsState extends Equatable {
  const CategoryProductsState();

  @override
  List<Object?> get props => [];
}

class CategoryProductsInitial extends CategoryProductsState {}

class CategoryProductsLoading extends CategoryProductsState {}

class CategoryProductsLoaded extends CategoryProductsState {
  final List<ProductModel> products;
  const CategoryProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class CategoryProductsError extends CategoryProductsState {
  final String message;
  const CategoryProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
