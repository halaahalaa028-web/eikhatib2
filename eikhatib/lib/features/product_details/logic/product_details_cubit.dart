import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/end_point.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/cache/cache_helper.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit() : super(ProductDetailsInitial());

  final Dio _dio = Dio();

  Future<void> fetchProduct(String id) async {
    emit(ProductDetailsLoading());
    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.products}/$id',
      );

      final product = ProductModel.fromJson(response.data['product']);
      emit(ProductDetailsSuccess(product: product));
      
      // Fetch ratings after successfully loading the product
      await fetchProductRatings(id);
    } catch (e) {
      emit(const ProductDetailsError('حدث خطأ أثناء تحميل تفاصيل المنتج'));
    }
  }

  Future<void> fetchProductRatings(String id) async {
    if (state is! ProductDetailsSuccess) return;
    
    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.products}/$id/ratings',
      );

      final List<dynamic> ratings = response.data['ratings'];
      emit((state as ProductDetailsSuccess).copyWith(ratings: ratings));
    } catch (e) {
      // Don't emit error state for ratings, just log it
      print('Error fetching ratings: $e');
    }
  }

  Future<void> addProductRating(String productId, double rating, String review) async {
    if (state is! ProductDetailsSuccess) return;
    
    final currentState = state as ProductDetailsSuccess;
    emit(currentState.copyWith(isRatingSubmitting: true));

    try {
      final token = await SecureCacheHelper().getData(key: ApiKey.token);
      
      await _dio.post(
        '${EndPoint.baseUrl}${EndPoint.products}/$productId/rate',
        data: {
          'rating': rating,
          'review': review,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Refresh product details and ratings after submission
      // We don't call fetchProduct because it emits Loading state which resets the whole screen
      // Instead we fetch updated product data and ratings silently
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.products}/$productId',
      );
      final updatedProduct = ProductModel.fromJson(response.data['product']);
      
      final ratingsResponse = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.products}/$productId/ratings',
      );
      final List<dynamic> updatedRatings = ratingsResponse.data['ratings'];

      emit(ProductDetailsSuccess(
        product: updatedProduct,
        ratings: updatedRatings,
        isRatingSubmitting: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isRatingSubmitting: false));
      // Optionally emit a temporary error state or show a snackbar in UI
      throw e; // Rethrow to handle in UI
    }
  }
}
