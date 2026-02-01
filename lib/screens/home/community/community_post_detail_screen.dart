import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/community/community_comment_model.dart';
import 'package:sgtourcus/models/community/community_post_model.dart';
import 'package:sgtourcus/repository/community_repository.dart';
import 'package:sgtourcus/widgets/notification_popup.dart';
import '../../../utils/extensions/localization_extension.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPostModel post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final _repository = CommunityRepository();
  final _commentController = TextEditingController();
  List<CommunityCommentModel> _comments = [];
  bool _loadingComments = true;
  bool _sendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    final list = await _repository.getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = list;
        _loadingComments = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _sendingComment = true);
    final ok = await _repository.addComment(widget.post.id, content);
    if (mounted) {
      setState(() {
        _sendingComment = false;
        if (ok) {
          _commentController.clear();
          NotificationPopup.show(context, context.l10n.common_success, isSuccess: true);
          _loadComments();
        } else {
          NotificationPopup.show(context, context.l10n.common_error);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final post = widget.post;
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
        title: Text(l10n.community_post_detail, style: AppTextStyles.heading5),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostContent(post, isDark, textSecondary),
                  const SizedBox(height: 24),
                  Text(l10n.community_comment, style: AppTextStyles.heading5),
                  const SizedBox(height: 12),
                  if (_loadingComments)
                    const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.primary)))
                  else if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(l10n.community_add_comment, style: AppTextStyles.body2.copyWith(color: textSecondary))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final c = _comments[i];
                        return _CommentTile(comment: c, surfaceColor: surfaceColor, textSecondary: textSecondary);
                      },
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8 + MediaQuery.of(context).padding.bottom),
            color: surfaceColor,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: l10n.community_add_comment,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendingComment ? null : _sendComment,
                    icon: _sendingComment ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(CommunityPostModel post, bool isDark, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: post.authorAvatarUrl != null && post.authorAvatarUrl!.isNotEmpty ? CachedNetworkImageProvider(post.authorAvatarUrl!) : null,
              child: post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty ? Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?', style: AppTextStyles.heading5.copyWith(color: AppColors.primary)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName, style: AppTextStyles.subtitle1.copyWith(color: textSecondary)),
                  if (post.createdAt.isNotEmpty) Text(post.createdAt, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            if (post.emotion != null && post.emotion!.isNotEmpty) Text(post.emotion!, style: const TextStyle(fontSize: 28)),
          ],
        ),
        const SizedBox(height: 12),
        Text(post.content, style: AppTextStyles.body1),
        if (post.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...post.imageUrls.map((url) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 200, color: AppColors.inputBackground, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (_, __, ___) => Container(height: 200, color: AppColors.inputBackground, child: Icon(Icons.image, color: AppColors.textTertiary)),
                  ),
                ),
              )),
        ],
        if (post.videoUrl != null && post.videoUrl!.isNotEmpty) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.inputBackground,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 48, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text('Video', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommunityCommentModel comment;
  final Color surfaceColor;
  final Color textSecondary;

  const _CommentTile({required this.comment, required this.surfaceColor, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: 8),
              Text(comment.authorName, style: AppTextStyles.subtitle2.copyWith(color: textSecondary)),
              const Spacer(),
              Text(comment.createdAt, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: AppTextStyles.body2),
        ],
      ),
    );
  }
}
