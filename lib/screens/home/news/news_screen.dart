import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/news/news_article_model.dart';
import 'package:sgtourcus/models/news/news_category_model.dart';
import 'package:sgtourcus/repository/news_repository.dart';
import 'package:sgtourcus/screens/home/news/programs_content.dart';
import 'package:sgtourcus/widgets/common/refreshable_body.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _repository = NewsRepository();

  List<NewsCategoryModel> _categories = [];
  List<NewsArticleModel> _articles = [];
  int _selectedCategoryIndex = 0;
  bool _loadingCategories = true;
  bool _loadingArticles = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    final list = await _repository.getCategories();
    if (mounted) {
      setState(() {
        _categories = list;
        _loadingCategories = false;
        if (_categories.isEmpty) {
          _categories = [
            const NewsCategoryModel(id: 'latest', name: 'Mới nhất'),
            const NewsCategoryModel(id: 'popular', name: 'Xem nhiều'),
            const NewsCategoryModel(id: 'program', name: 'Chương trình'),
          ];
        }
        _selectedCategoryIndex = 0;
      });
      _loadArticles();
    }
  }

  Future<void> _loadArticles() async {
    setState(() => _loadingArticles = true);
    final categoryId = _categories.isEmpty ? null : _categories[_selectedCategoryIndex].id;
    final list = await _repository.getArticles(categoryId: categoryId);
    if (mounted) {
      setState(() {
        _articles = list;
        _loadingArticles = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadCategories();
  }

  void _onCategoryTap(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    final isProgram = index < _categories.length && _categories[index].id == 'program';
    if (!isProgram) _loadArticles();
  }

  bool get _isProgramTab =>
      _selectedCategoryIndex < _categories.length && _categories[_selectedCategoryIndex].id == 'program';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isDark),
            _buildCategoryBar(isDark, textSecondary),
            Expanded(
              child: _isProgramTab
                  ? const ProgramsContent()
                  : RefreshableBody(
                      onRefresh: _onRefresh,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _loadingArticles
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : _articles.isEmpty
                              ? _buildEmptyState()
                              : _buildArticleList(surfaceColor, textSecondary),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            'Tin tức',
            style: AppTextStyles.heading5.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(bool isDark, Color textSecondary) {
    if (_loadingCategories) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final category = _categories[index];
          final isSelected = index == _selectedCategoryIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onCategoryTap(index),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              _categoryIcon(category.id),
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            category.name,
                            style: AppTextStyles.subtitle1.copyWith(
                              color: isSelected ? AppColors.primary : textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _categoryIcon(String id) {
    switch (id) {
      case 'program':
        return Icons.calendar_today_outlined;
      case 'popular':
        return Icons.trending_up_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Chưa có tin nào',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList(Color surfaceColor, Color textSecondary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _NewsArticleCard(
          article: _articles[index],
          textSecondary: textSecondary,
          surfaceColor: surfaceColor,
          isDark: isDark,
        );
      },
    );
  }
}

class _NewsArticleCard extends StatelessWidget {
  final NewsArticleModel article;
  final Color textSecondary;
  final Color surfaceColor;
  final bool isDark;

  const _NewsArticleCard({
    required this.article,
    required this.textSecondary,
    required this.surfaceColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(Icons.article_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.categoryName.isNotEmpty ? article.categoryName : 'Tin tức',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Vừa xong',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: textSecondary, size: 22),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: AppTextStyles.heading5.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article.summary,
                  style: AppTextStyles.body2.copyWith(
                    color: textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: article.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 220,
                  color: AppColors.inputBackground,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 220,
                  color: AppColors.inputBackground,
                  child: Icon(Icons.image_not_supported_outlined, color: AppColors.textTertiary),
                ),
              ),
            )
          else
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image_outlined, size: 48, color: AppColors.textTertiary),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
            child: Row(
              children: [
                Icon(Icons.thumb_up_outlined, size: 20, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Thích',
                  style: AppTextStyles.subtitle3.copyWith(color: textSecondary),
                ),
                const SizedBox(width: 20),
                Icon(Icons.chat_bubble_outline, size: 20, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${article.commentCount}',
                  style: AppTextStyles.subtitle3.copyWith(color: textSecondary),
                ),
                const SizedBox(width: 20),
                Icon(Icons.share_outlined, size: 20, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Chia sẻ',
                  style: AppTextStyles.subtitle3.copyWith(color: textSecondary),
                ),
                const Spacer(),
                Icon(Icons.bookmark_border, size: 22, color: textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
