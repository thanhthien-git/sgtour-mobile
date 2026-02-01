import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/community/community_post_model.dart';
import 'package:sgtourcus/models/community/top_rated_place_model.dart';
import 'package:sgtourcus/repository/community_repository.dart';
import 'package:sgtourcus/screens/home/community/community_create_post_screen.dart';
import 'package:sgtourcus/screens/home/community/community_my_posts_screen.dart';
import 'package:sgtourcus/screens/home/community/community_post_detail_screen.dart';
import 'package:sgtourcus/screens/home/community/community_team_up_screen.dart';
import 'package:sgtourcus/widgets/common/refreshable_body.dart';
import '../../../utils/extensions/localization_extension.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _repository = CommunityRepository();
  List<CommunityPostModel> _posts = [];
  List<TopRatedPlaceModel> _topPlaces = [];
  bool _loadingPosts = true;
  bool _loadingPlaces = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loadingPosts = true;
      _loadingPlaces = true;
    });
    final posts = await _repository.getApprovedPosts();
    final places = await _repository.getTopRatedPlaces();
    if (mounted) {
      setState(() {
        _posts = posts;
        _topPlaces = places;
        _loadingPosts = false;
        _loadingPlaces = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _load();
  }

  void _openCreatePost() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CommunityCreatePostScreen()),
    );
    if (created == true && mounted) _load();
  }

  void _openMyPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityMyPostsScreen()),
    ).then((_) => _load());
  }

  void _openTeamUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityTeamUpScreen()),
    );
  }

  void _openPostDetail(CommunityPostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: post),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(l10n.community_title, style: AppTextStyles.heading5),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined),
            onPressed: _openMyPosts,
            tooltip: 'Bài đăng của tôi',
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _openTeamUp,
            tooltip: l10n.community_team_up_title,
          ),
        ],
      ),
      body: RefreshableBody(
        onRefresh: _onRefresh,
        padding: const EdgeInsets.only(bottom: 24),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildComposerBar(l10n, isDark),
              _buildTopPlacesSection(l10n, isDark, textSecondary),
              _buildFeedSection(l10n, isDark, textSecondary),
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -20),
        child: FloatingActionButton(
          onPressed: _openCreatePost,
          backgroundColor: AppColors.primary,
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 5,
          child: const Icon(Icons.post_add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildComposerBar(dynamic l10n, bool isDark) {
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: InkWell(
        onTap: _openCreatePost,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputBackgroundDark : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(Icons.person, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bạn đang nghĩ gì?',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
                ),
              ),
              Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Icon(Icons.videocam_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Icon(Icons.emoji_emotions_outlined, color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPlacesSection(dynamic l10n, bool isDark, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(l10n.community_top_places, style: AppTextStyles.heading5),
        ),
        if (_loadingPlaces)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
          )
        else if (_topPlaces.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 124,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _topPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final place = _topPlaces[index];
                return _TopPlaceCard(place: place, isDark: isDark, textSecondary: textSecondary);
              },
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFeedSection(dynamic l10n, bool isDark, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(l10n.community_feed, style: AppTextStyles.heading5),
        ),
        if (_loadingPosts)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          )
        else if (_posts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.article_outlined, size: 56, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(l10n.community_no_posts, style: AppTextStyles.body2.copyWith(color: textSecondary), textAlign: TextAlign.center),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = _posts[index];
              return _PostCard(
                post: post,
                isDark: isDark,
                textSecondary: textSecondary,
                onTap: () => _openPostDetail(post),
                commentCountText: l10n.community_comment_count(post.commentCount),
              );
            },
          ),
      ],
    );
  }
}

class _TopPlaceCard extends StatelessWidget {
  final TopRatedPlaceModel place;
  final bool isDark;
  final Color textSecondary;

  const _TopPlaceCard({required this.place, required this.isDark, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: (place.imageUrl != null && place.imageUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: place.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.inputBackground, child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
                    errorWidget: (_, __, ___) => Container(color: AppColors.inputBackground, child: Icon(Icons.place, color: AppColors.textTertiary)),
                  )
                : Container(color: AppColors.inputBackground, child: Icon(Icons.place, size: 36, color: AppColors.textTertiary)),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(place.name, style: AppTextStyles.subtitle2.copyWith(color: textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (place.rating > 0) Text('★ ${place.rating.toStringAsFixed(1)}', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPostModel post;
  final bool isDark;
  final Color textSecondary;
  final VoidCallback onTap;
  final String commentCountText;

  const _PostCard({
    required this.post,
    required this.isDark,
    required this.textSecondary,
    required this.onTap,
    required this.commentCountText,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    backgroundImage: post.authorAvatarUrl != null && post.authorAvatarUrl!.isNotEmpty ? CachedNetworkImageProvider(post.authorAvatarUrl!) : null,
                    child: post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty ? Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?', style: AppTextStyles.heading5.copyWith(color: AppColors.primary)) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName, style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600, color: textSecondary)),
                        if (post.createdAt.isNotEmpty) Text(post.createdAt, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (post.emotion != null && post.emotion!.isNotEmpty) Text(post.emotion!, style: const TextStyle(fontSize: 26)),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.content, style: AppTextStyles.body2.copyWith(height: 1.45), maxLines: 4, overflow: TextOverflow.ellipsis),
              if (post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrls[i],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.inputBackground, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (_, __, ___) => Container(color: AppColors.inputBackground, child: Icon(Icons.image, color: AppColors.textTertiary)),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (post.videoUrl != null && post.videoUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.inputBackground,
                    child: const Center(child: Icon(Icons.videocam, size: 48, color: AppColors.primary)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20, color: textSecondary),
                  const SizedBox(width: 6),
                  Text(commentCountText, style: AppTextStyles.subtitle2.copyWith(color: textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
