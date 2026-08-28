import 'package:flutter/material.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/routes/routes.dart';
import '../../../core/widgets/app_cached_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/data/models/home_models.dart';
import '../logic/categories_cubit.dart';
import '../logic/categories_state.dart';

class AllCategoriesScreen extends StatefulWidget {
  final CategoryModel? parentCategory;
  const AllCategoriesScreen({super.key, this.parentCategory});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start with all categories
    context.read<CategoriesCubit>().searchCategories('');
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    context.read<CategoriesCubit>().searchCategories(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.parentCategory?.name ?? 'الأقسام',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن أي قسم...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),

          // Categories Grid
          Expanded(
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading || state is CategoriesInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoriesError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  );
                } else if (state is CategoriesLoaded) {
                  final cubit = context.read<CategoriesCubit>();
                  final allCategories = state.categories;

                  // Filter based on parentCategory
                  List<CategoryModel> displayCategories;
                  if (_searchController.text.isNotEmpty) {
                    displayCategories = allCategories;
                  } else if (widget.parentCategory != null) {
                    displayCategories = cubit.getSubCategories(
                      widget.parentCategory!.id,
                    );
                  } else {
                    displayCategories = cubit.getRootCategories();
                  }

                  if (displayCategories.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا يوجد أقسام لعرضها',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: displayCategories.length,
                    itemBuilder: (context, index) {
                      final category = displayCategories[index];
                      return GestureDetector(
                        onTap: () {
                          final hasSub = context
                              .read<CategoriesCubit>()
                              .hasSubCategories(category.id);
                          if (hasSub) {
                            AppRouter.navigateTo(
                              context,
                              Routes.allCategories,
                              arguments: {'parentCategory': category},
                            );
                          } else {
                            AppRouter.navigateTo(
                              context,
                              Routes.categoryProducts,
                              arguments: {'categoryName': category.name},
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: AppCachedImage(
                                  imageUrl: category.imageUrl,
                                  updatedAt: category.updatedAt,
                                  fit: BoxFit.cover,
                                  width: 85,
                                  height: 85,
                                  errorWidget: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
