part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  final List<String> history;
  const SearchState({this.history = const []});

  @override
  List<Object?> get props => [history];
}

class SearchInitial extends SearchState {
  const SearchInitial({super.history});
}

class SearchLoading extends SearchState {
  const SearchLoading({super.history});
}

class SearchSuccess extends SearchState {
  final List<ProductModel> products;
  final List<ProductModel> offers;
  final List<String> categories;

  const SearchSuccess({
    required this.products,
    required this.offers,
    required this.categories,
    super.history,
  });

  @override
  List<Object?> get props => [products, offers, categories, history];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message, {super.history});

  @override
  List<Object?> get props => [message, history];
}
