import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/community/community_post_model.dart';
import 'package:sgtourcus/repository/community_repository.dart';
import 'package:sgtourcus/services/file/cloudinary_service.dart';
import 'package:sgtourcus/widgets/notification_popup.dart';
import '../../../utils/extensions/localization_extension.dart';

class CommunityCreatePostScreen extends StatefulWidget {
  const CommunityCreatePostScreen({super.key});

  @override
  State<CommunityCreatePostScreen> createState() => _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState extends State<CommunityCreatePostScreen> {
  final _repository = CommunityRepository();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  List<File> _imageFiles = [];
  File? _videoFile;
  String? _selectedEmotion;
  String _visibility = PostVisibility.public;
  bool _posting = false;

  static const List<String> _emotions = ['😊', '👍', '❤️', '🔥', '✨', '🌟', '😍', '🎉'];

  static const List<Map<String, String>> _visibilityOptions = [
    {'value': PostVisibility.saved, 'label': 'Lưu', 'icon': 'save'},
    {'value': PostVisibility.public, 'label': 'Đăng công khai', 'icon': 'public'},
    {'value': PostVisibility.link, 'label': 'Người có liên kết', 'icon': 'link'},
    {'value': PostVisibility.private, 'label': 'Chỉ mình tôi', 'icon': 'lock'},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty || !mounted) return;
    setState(() {
      _imageFiles = [..._imageFiles, ...picked.map((x) => File(x.path))];
      if (_videoFile != null) _videoFile = null;
    });
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() {
      _videoFile = File(picked.path);
      _imageFiles = [];
    });
  }

  void _removeImage(int index) {
    setState(() => _imageFiles = _imageFiles..removeAt(index));
  }

  void _removeVideo() {
    setState(() => _videoFile = null);
  }

  IconData _visibilityIcon(String icon) {
    switch (icon) {
      case 'save':
        return Icons.save_outlined;
      case 'link':
        return Icons.link;
      case 'lock':
        return Icons.lock_outline;
      default:
        return Icons.public;
    }
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _visibility != PostVisibility.saved) {
      NotificationPopup.show(context, context.l10n.community_post_content);
      return;
    }
    setState(() => _posting = true);

    List<String> imageUrls = [];
    for (final file in _imageFiles) {
      try {
        final url = await CloudinaryService.uploadImage(file);
        if (url != null) imageUrls.add(url);
      } catch (_) {}
    }

    String? videoUrl;
    if (_videoFile != null) {
      try {
        videoUrl = await CloudinaryService.uploadVideo(_videoFile!);
      } catch (_) {}
    }

    final post = await _repository.createPost(
      content: content,
      imageUrls: imageUrls.isEmpty ? null : imageUrls,
      videoUrl: videoUrl,
      emotion: _selectedEmotion,
      visibility: _visibility,
    );

    if (!mounted) return;
    setState(() => _posting = false);
    if (post != null) {
      NotificationPopup.show(context, context.l10n.common_success, isSuccess: true);
      Navigator.pop(context, true);
    } else {
      NotificationPopup.show(context, context.l10n.common_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
          tooltip: l10n.common_back,
        ),
        title: Text(l10n.community_create_post, style: AppTextStyles.heading5),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _posting ? null : _submit,
            icon: _posting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Icon(Icons.send_rounded, color: AppColors.primary, size: 26),
            tooltip: l10n.community_post,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: l10n.community_post_content,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: surfaceColor,
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(l10n.community_select_image, style: AppTextStyles.subtitle1),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.2), foregroundColor: AppColors.primary),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.videocam_outlined),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.2), foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_imageFiles.isNotEmpty)
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFiles[i], width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(i),
                            child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (_videoFile != null) ...[
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, size: 48, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Video đã chọn', style: AppTextStyles.body2, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _removeVideo,
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Text('Quyền xem bài viết', style: AppTextStyles.subtitle1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _visibilityOptions.map((opt) {
                final selected = _visibility == opt['value'];
                return FilterChip(
                  selected: selected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_visibilityIcon(opt['icon']!), size: 18, color: selected ? Colors.white : AppColors.primary),
                      const SizedBox(width: 6),
                      Text(opt['label']!),
                    ],
                  ),
                  onSelected: (_) => setState(() => _visibility = opt['value']!),
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Biểu tượng cảm xúc', style: AppTextStyles.subtitle1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emotions.map((e) {
                final selected = _selectedEmotion == e;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmotion = selected ? null : e),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withOpacity(0.2) : surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
