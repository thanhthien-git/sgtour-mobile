import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/models/community/community_team_up_model.dart';
import 'package:sgtourcus/repository/community_repository.dart';
import 'package:sgtourcus/widgets/notification_popup.dart';
import '../../../utils/extensions/localization_extension.dart';

class CommunityTeamUpScreen extends StatefulWidget {
  const CommunityTeamUpScreen({super.key});

  @override
  State<CommunityTeamUpScreen> createState() => _CommunityTeamUpScreenState();
}

class _CommunityTeamUpScreenState extends State<CommunityTeamUpScreen> {
  final _repository = CommunityRepository();
  List<CommunityTeamUpModel> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repository.getTeamUpList();
    if (mounted) setState(() {
      _list = list;
      _loading = false;
    });
  }

  Future<void> _join(CommunityTeamUpModel item) async {
    final ok = await _repository.joinTeamUp(item.id);
    if (!mounted) return;
    if (ok) {
      NotificationPopup.show(context, context.l10n.common_success, isSuccess: true);
      _load();
    } else {
      NotificationPopup.show(context, context.l10n.common_error);
    }
  }

  void _openCreateTeamUp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CreateTeamUpSheet(
        onCreated: () {
          Navigator.pop(ctx);
          _load();
        },
      ),
    );
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
        title: Text(l10n.community_team_up_title, style: AppTextStyles.heading5),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openCreateTeamUp,
            tooltip: l10n.community_team_up,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_add, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text('Chưa có thông báo ghép đội', style: AppTextStyles.body2.copyWith(color: textSecondary)),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _openCreateTeamUp,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.community_team_up),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final item = _list[i];
                      return _TeamUpCard(
                        item: item,
                        surfaceColor: surfaceColor,
                        textSecondary: textSecondary,
                        onJoin: () => _join(item),
                        joinLabel: 'Tham gia',
                      );
                    },
                  ),
                ),
    );
  }
}

class _TeamUpCard extends StatelessWidget {
  final CommunityTeamUpModel item;
  final Color surfaceColor;
  final Color textSecondary;
  final VoidCallback onJoin;
  final String joinLabel;

  const _TeamUpCard({
    required this.item,
    required this.surfaceColor,
    required this.textSecondary,
    required this.onJoin,
    required this.joinLabel,
  });

  @override
  Widget build(BuildContext context) {
    final canJoin = item.currentMembers < item.maxMembers;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTextStyles.heading5),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.description!, style: AppTextStyles.body2.copyWith(color: textSecondary)),
          ],
          if (item.destination != null && item.destination!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.place, size: 16, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(item.destination!, style: AppTextStyles.caption.copyWith(color: textSecondary)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${item.currentMembers}/${item.maxMembers} thành viên', style: AppTextStyles.caption.copyWith(color: textSecondary)),
              const Spacer(),
              Text(item.creatorName, style: AppTextStyles.caption.copyWith(color: textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canJoin ? onJoin : null,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(joinLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTeamUpSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateTeamUpSheet({required this.onCreated});

  @override
  State<_CreateTeamUpSheet> createState() => _CreateTeamUpSheetState();
}

class _CreateTeamUpSheetState extends State<_CreateTeamUpSheet> {
  final _repository = CommunityRepository();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _creating = true);
    final result = await _repository.createTeamUp(
      title: title,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      destination: _destinationController.text.trim().isEmpty ? null : _destinationController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _creating = false);
    if (result != null) {
      NotificationPopup.show(context, context.l10n.common_success, isSuccess: true);
      widget.onCreated();
    } else {
      NotificationPopup.show(context, context.l10n.common_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.community_team_up, style: AppTextStyles.heading5),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Mô tả (tùy chọn)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Điểm đến (tùy chọn)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _creating ? null : _create,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: _creating ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(l10n.common_save),
            ),
          ],
        ),
      ),
    );
  }
}
