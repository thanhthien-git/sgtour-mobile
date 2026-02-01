import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/community/community_post_model.dart';
import 'package:sgtourcus/repository/community_repository.dart';
import 'package:sgtourcus/screens/home/community/community_post_detail_screen.dart';
import 'package:sgtourcus/widgets/dialogs/confirmation_dialog.dart';
import 'package:sgtourcus/widgets/notification_popup.dart';
import '../../../utils/extensions/localization_extension.dart';

class CommunityMyPostsScreen extends StatefulWidget {
  const CommunityMyPostsScreen({super.key});

  @override
  State<CommunityMyPostsScreen> createState() => _CommunityMyPostsScreenState();
}

class _CommunityMyPostsScreenState extends State<CommunityMyPostsScreen> {
  final _repository = CommunityRepository();
  List<CommunityPostModel> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repository.getMyPosts();
    if (mounted) setState(() {
      _posts = list;
      _loading = false;
    });
  }

  String _visibilityLabel(String v) {
    switch (v) {
      case PostVisibility.public:
        return 'Công khai';
      case PostVisibility.link:
        return 'Người có liên kết';
      case PostVisibility.private:
        return 'Chỉ mình tôi';
      case PostVisibility.saved:
        return 'Đã lưu';
      default:
        return v;
    }
  }

  IconData _visibilityIcon(String v) {
    switch (v) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.link:
        return Icons.link;
      case PostVisibility.private:
        return Icons.lock_outline;
      case PostVisibility.saved:
        return Icons.save_outlined;
      default:
        return Icons.public;
    }
  }

  Future<void> _changeVisibility(CommunityPostModel post) async {
    final options = [PostVisibility.public, PostVisibility.link, PostVisibility.private];
    final current = post.visibility;
    if (!mounted) return;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Chọn quyền xem', style: AppTextStyles.heading5),
            ),
            ...options.map((v) => ListTile(
                  leading: Icon(_visibilityIcon(v)),
                  title: Text(_visibilityLabel(v)),
                  trailing: current == v ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () => Navigator.pop(ctx, v),
                )),
          ],
        ),
      ),
    );
    if (chosen == null || chosen == current) return;
    final ok = await _repository.updatePostVisibility(post.id, chosen);
    if (!mounted) return;
    if (ok) {
      NotificationPopup.show(context, context.l10n.common_success, isSuccess: true);
      _load();
    } else {
      NotificationPopup.show(context, context.l10n.common_error);
    }
  }

  void _deletePost(CommunityPostModel post) {
    final l10n = context.l10n;
    ConfirmationDialog.show(
      context: context,
      title: 'Xóa bài đăng',
      content: 'Bạn có chắc muốn xóa bài đăng này?',
      cancelText: l10n.common_cancel,
      confirmText: l10n.common_delete,
      isDestructive: true,
      onConfirm: () => _doDelete(post),
    );
  }

  Future<void> _doDelete(CommunityPostModel post) async {
    final l10n = context.l10n;
    final ok = await _repository.deletePost(post.id);
    if (!mounted) return;
    if (ok) {
      NotificationPopup.show(context, l10n.common_success, isSuccess: true);
      _load();
    } else {
      NotificationPopup.show(context, l10n.common_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
          tooltip: l10n.common_back,
        ),
        title: const Text('Bài đăng của tôi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('Chưa có bài đăng nào', style: AppTextStyles.body2.copyWith(color: textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final post = _posts[i];
                      return _MyPostCard(
                        post: post,
                        surfaceColor: surfaceColor,
                        textSecondary: textSecondary,
                        visibilityLabel: _visibilityLabel(post.visibility),
                        visibilityIcon: _visibilityIcon(post.visibility),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CommunityPostDetailScreen(post: post)),
                          );
                          _load();
                        },
                        onChangeVisibility: () => _changeVisibility(post),
                        onDelete: () => _deletePost(post),
                      );
                    },
                  ),
                ),
    );
  }
}

class _MyPostCard extends StatelessWidget {
  final CommunityPostModel post;
  final Color surfaceColor;
  final Color textSecondary;
  final String visibilityLabel;
  final IconData visibilityIcon;
  final VoidCallback onTap;
  final VoidCallback onChangeVisibility;
  final VoidCallback onDelete;

  const _MyPostCard({
    required this.post,
    required this.surfaceColor,
    required this.textSecondary,
    required this.visibilityLabel,
    required this.visibilityIcon,
    required this.onTap,
    required this.onChangeVisibility,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.content,
                      style: AppTextStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) {
                      if (v == 'visibility') onChangeVisibility();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'visibility', child: Row(children: [Icon(Icons.visibility_outlined), SizedBox(width: 8), Text('Đổi quyền xem')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: AppColors.error), SizedBox(width: 8), Text('Xóa bài đăng', style: TextStyle(color: AppColors.error))])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(visibilityIcon, size: 16, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(visibilityLabel, style: AppTextStyles.caption.copyWith(color: textSecondary)),
                  const SizedBox(width: 12),
                  Text(post.createdAt, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                ],
              ),
              if (post.imageUrls.isNotEmpty || post.videoUrl != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 72,
                  child: post.imageUrls.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: post.imageUrls.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrls[i],
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: AppColors.inputBackground),
                              errorWidget: (_, __, ___) => Container(color: AppColors.inputBackground, child: const Icon(Icons.image)),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.videocam, color: AppColors.primary),
                            ),
                          ],
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
