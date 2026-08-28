import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/end_point.dart';
import '../../../core/cache/cache_helper.dart';
import '../../home/data/models/home_models.dart';
import 'category_products_state.dart';

class CategoryProductsCubit extends Cubit<CategoryProductsState> {
  CategoryProductsCubit() : super(CategoryProductsInitial());

  final Dio _dio = Dio();

  Future<void> fetchProducts({
    required String categoryName,
    String search = '',
    String sort = 'الاحدث',
    double? minPrice,
    double? maxPrice,
  }) async {
    emit(CategoryProductsLoading());
    try {
      final token = await SecureCacheHelper().getData(key: ApiKey.token);
      
      final queryParams = {
        if (categoryName != 'جميع المنتجات') 'category': categoryName,
        if (search.isNotEmpty) 'search': search,
        'sort': sort,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
      };

      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.products}',
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final productsList = (response.data['products'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
          
      emit(CategoryProductsLoaded(productsList));
    } catch (e) {
      emit(CategoryProductsError('حدث خطأ أثناء تحميل المنتجات'));
    }
  }
}
