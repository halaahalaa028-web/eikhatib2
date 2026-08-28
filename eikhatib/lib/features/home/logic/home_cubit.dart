import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/end_point.dart';
import '../../../core/cache/cache_helper.dart';
import '../data/models/home_models.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final Dio _dio = Dio();

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      final token = await SecureCacheHelper().getData(key: ApiKey.token);
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.home}',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final homeData = HomeDataModel.fromJson(response.data);
      emit(HomeLoaded(homeData));
    } catch (e) {
      emit(HomeError('حدث خطأ أثناء تحميل البيانات'));
    }
  }
}
