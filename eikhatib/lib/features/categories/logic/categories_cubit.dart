import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/end_point.dart';
import '../../../core/cache/cache_helper.dart';
import '../../home/data/models/home_models.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesInitial());

  final Dio _dio = Dio();
  List<CategoryModel> _allCategories = [];

  Future<void> fetchCategories() async {
    emit(CategoriesLoading());
    try {
      final token = await SecureCacheHelper().getData(key: ApiKey.token);
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.categories}?includeProducts=true',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      _allCategories = (response.data['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
          
      emit(CategoriesLoaded(_allCategories));
    } catch (e) {
      emit(CategoriesError('حدث خطأ أثناء تحميل الأقسام'));
    }
  }

  void searchCategories(String query) {
    if (_allCategories.isEmpty) return;
    
    if (query.isEmpty) {
      emit(CategoriesLoaded(_allCategories));
    } else {
      final filtered = _allCategories
          .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(CategoriesLoaded(filtered)); 
    }
  }

  List<CategoryModel> getRootCategories() {
    return _allCategories.where((c) {
      return c.parentId == null || c.parentId!.isEmpty || c.parentId == 'null';
    }).toList();
  }

  List<CategoryModel> getSubCategories(String parentId) {
    return _allCategories.where((c) => c.parentId == parentId).toList();
  }

  bool hasSubCategories(String categoryId) {
    return _allCategories.any((c) => 
      c.parentId != null && c.parentId != 'null' && c.parentId == categoryId
    );
  }
}
