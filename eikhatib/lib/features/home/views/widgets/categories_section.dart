import 'package:flutter/material.dart';
import 'package:eikhatib/core/theme/colors.dart';
import 'package:eikhatib/core/routes/app_router.dart';
import 'package:eikhatib/core/routes/routes.dart';
import 'package:eikhatib/core/widgets/app_cached_image.dart';
import '../../data/models/home_models.dart';

class CategoriesSection extends StatelessWidget {
  final List<CategoryModel> categories;
  const CategoriesSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    // Filter root categories (where parentId is null, empty, or 'null')
    final rootCategories = categories.where((c) {
      return c.parentId == null || c.parentId!.isEmpty || c.parentId == 'null';
    }).toList();

    if (rootCategories.isEmpty) return const SizedBox.shrink();

    int halfLength = (rootCategories.length / 2).ceil();
    final row1Categories = rootCategories.sublist(0, halfLength);
    final row2Categories = rootCategories.sublist(halfLength);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ابحث حسب القسم',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              InkWell(
                onTap: () =>
                    AppRouter.navigateTo(context, Routes.allCategories),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // First Row
          _HorizontalCategoryRow(
            items: row1Categories,
            allCategories: categories,
          ),
          const SizedBox(height: 16),
          // Second Row
          if (row2Categories.isNotEmpty)
            _HorizontalCategoryRow(
              items: row2Categories,
              allCategories: categories,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HorizontalCategoryRow extends StatefulWidget {
  final List<CategoryModel> items;
  final List<CategoryModel> allCategories;
  const _HorizontalCategoryRow({
    required this.items,
    required this.allCategories,
  });

  @override
  State<_HorizontalCategoryRow> createState() => _HorizontalCategoryRowState();
}

class _HorizontalCategoryRowState extends State<_HorizontalCategoryRow> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.maxScrollExtent > 0) {
      double fraction =
          _scrollController.offset / _scrollController.position.maxScrollExtent;
      fraction = fraction.clamp(0.0, 1.0);
      int newIndex = (fraction * (widget.items.length - 1)).round();
      if (_currentIndex != newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 40) / 4;

    return Column(
      children: [
        SizedBox(
          height: 105,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.items.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return GestureDetector(
                onTap: () {
                  // نبحث في القائمة الكاملة عن أي قسم يعتبر هذا القسم أباً له
                  final hasSub = widget.allCategories.any(
                    (c) =>
                        c.parentId != null &&
                        c.parentId != 'null' &&
                        c.parentId == item.id,
                  );

                  if (hasSub) {
                    // إذا وجدنا أقسام فرعية، نفتح صفحة الأقسام
                    AppRouter.navigateTo(
                      context,
                      Routes.allCategories,
                      arguments: {'parentCategory': item},
                    );
                  } else {
                    // إذا لم نجد، نفتح صفحة المنتجات
                    AppRouter.navigateTo(
                      context,
                      Routes.categoryProducts,
                      arguments: {
                        'categoryName': item.name,
                        'categoryImage': item.imageUrl,
                      },
                    );
                  }
                },
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade100,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppCachedImage(
                            imageUrl: item.imageUrl,
                            updatedAt: item.updatedAt,
                            fit: BoxFit.cover,
                            width: 70,
                            height: 70,
                            errorWidget: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.items.length > 4) const SizedBox(height: 6),
        if (widget.items.length > 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.items.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentIndex == index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
