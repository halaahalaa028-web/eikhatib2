// ignore_for_file: empty_catches

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/product_model.dart';
import '../../../core/api/end_point.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial(history: []));

  final Dio _dio = Dio();
  static const String _historyKey = 'search_history';

  // Load history from SharedPreferences
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      emit(SearchInitial(history: history));
    } catch (e) {
      emit(const SearchInitial(history: []));
    }
  }

  // Add query to history
  Future<void> _addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_historyKey) ?? [];

      // Remove if exists and add to front
      history.remove(query);
      history.insert(0, query);

      // Limit to 10
      if (history.length > 10) {
        history = history.sublist(0, 10);
      }

      await prefs.setStringList(_historyKey, history);

      // Update state with new history but keep results if successful
      if (state is SearchSuccess) {
        final s = state as SearchSuccess;
        emit(
          SearchSuccess(
            products: s.products,
            offers: s.offers,
            categories: s.categories,
            history: history,
          ),
        );
      } else if (state is SearchInitial) {
        emit(SearchInitial(history: history));
      }
    } catch (e) {
      // Ignore history errors
    }
  }

  Future<void> removeFromHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_historyKey) ?? [];
      history.remove(query);
      await prefs.setStringList(_historyKey, history);

      if (state is SearchInitial) {
        emit(SearchInitial(history: history));
      } else if (state is SearchSuccess) {
        final s = state as SearchSuccess;
        emit(
          SearchSuccess(
            products: s.products,
            offers: s.offers,
            categories: s.categories,
            history: history,
          ),
        );
      }
    } catch (e) {}
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);

      if (state is SearchInitial) {
        emit(const SearchInitial(history: []));
      } else if (state is SearchSuccess) {
        final s = state as SearchSuccess;
        emit(
          SearchSuccess(
            products: s.products,
            offers: s.offers,
            categories: s.categories,
            history: const [],
          ),
        );
      }
    } catch (e) {}
  }

  void search(String query) async {
    if (query.isEmpty) {
      final history = state.history;
      emit(SearchInitial(history: history));
      return;
    }

    final currentHistory = state.history;
    emit(SearchLoading(history: currentHistory));

    try {
      final response = await _dio.get(
        '${EndPoint.baseUrl}${EndPoint.products}',
        queryParameters: {'search': query},
      );

      final List data = response.data['products'] ?? [];
      final allProducts = data
          .map((json) => ProductModel.fromJson(json))
          .toList();

      // Separate offers and regular products
      final offers = allProducts.where((p) => p.hasOffer).toList();
      final products = allProducts.where((p) => !p.hasOffer).toList();

      // For categories, we'll extract unique categories from products found
      final categories = allProducts.map((p) => p.category).toSet().toList();

      emit(
        SearchSuccess(
          products: products,
          offers: offers,
          categories: categories,
          history: currentHistory,
        ),
      );

      // Save to history only if results were found (optional business choice)
      if (allProducts.isNotEmpty) {
        _addToHistory(query);
      }
    } catch (e) {
      emit(
        SearchError(
          'حدث خطأ أثناء البحث. تأكد من اتصالك بالإنترنت.',
          history: currentHistory,
        ),
      );
    }
  }

  void clearSearch() {
    emit(SearchInitial(history: state.history));
  }
}
