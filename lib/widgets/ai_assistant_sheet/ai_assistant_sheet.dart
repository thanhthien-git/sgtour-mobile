import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:sgtour_mobile/models/agent/agent_response.dart';
import 'package:sgtour_mobile/models/agent/ai_chat_message.dart';
import 'package:sgtour_mobile/services/agent/agent_service.dart';
import 'package:sgtour_mobile/widgets/ai_assistant_sheet/ai_input_area.dart';
import 'package:sgtour_mobile/widgets/ai_human_avatar/avatar_controller.dart';
import 'package:sgtour_mobile/widgets/ai_human_avatar/talking_avatar_widget.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';

enum AiAssistantMode { chat, video }

class AiAssistantSheet extends StatefulWidget {
  final VoidCallback? onClose;
  final LatLng? userLocation;
  const AiAssistantSheet({super.key, this.onClose, this.userLocation});

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final AvatarController _avatarCtrl = AvatarController();
  late final AgentService _agentService;

  final List<AiChatMessage> _messages = [];
  AiAssistantMode _mode = AiAssistantMode.chat;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _agentService = AgentService();
    _avatarCtrl.cancelCloseSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _addMessage("", false, isGreeting: true);
      }
    });
  }

  @override
  void dispose() {
    if (_mode == AiAssistantMode.video || _avatarCtrl.isSessionActive) {
      _avatarCtrl.stopSession();
    }

    super.dispose();
  }

  Future<bool> _showStopSessionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              title: Text(
                context.l10n.ai_video_end_dialog_title,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              content: Text(
                context.l10n.ai_video_end_dialog_message,
                style: AppTextStyles.subtitle2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    context.l10n.ai_video_end_dialog_cancel,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    context.l10n.ai_video_end_dialog_confirm,
                    style: AppTextStyles.subtitle2.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _addMessage(String content, bool isUser, {bool isGreeting = false}) {
    if (!mounted) return;
    setState(() {
      _messages.insert(
        0,
        AiChatMessage(
          content: content,
          isUser: isUser,
          timestamp: DateTime.now(),
          isGreeting: isGreeting,
        ),
      );
    });
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;

    _addMessage(text, true);
    setState(() => _isProcessing = true);

    try {
      String? sessionId;

      if (_mode == AiAssistantMode.video) {
        sessionId = _avatarCtrl.currentSessionId;
      }

      final AgentResponse response = await _agentService.askAgent(
        text,
        sessionId ?? "",
      );
      _addMessage(response.replyText, false);
    } catch (e) {
      _addMessage(context.l10n.ai_error, false);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _changeMode(AiAssistantMode newMode) async {
    if (_mode == newMode) return;

    if (_mode == AiAssistantMode.video && newMode == AiAssistantMode.chat) {
      final shouldStop = await _showStopSessionDialog();

      if (!shouldStop) return;

      await _avatarCtrl.stopSessionImmediately();
    }

    setState(() => _mode = newMode);

    if (newMode == AiAssistantMode.video) {
      _avatarCtrl.cancelCloseSession();
      if (!_avatarCtrl.isSessionActive) {
        _avatarCtrl.startSession();
      }
    } else {
      _avatarCtrl.stopSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
        ),
        child: Column(
          children: [
            _HeaderSection(
              mode: _mode,
              onModeChanged: _changeMode,
              onClose: () {
                _avatarCtrl.stopSession();
                widget.onClose?.call();
              },
              isDark: isDark,
            ),

            Expanded(
              child: _mode == AiAssistantMode.chat
                  ? _buildChatList(isDark)
                  : _buildVideoView(isDark),
            ),

            AiInputArea(
              onSend: _handleSendMessage,
              isDark: isDark,
              isTyping: _isProcessing,
              mode: _mode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _ChatBubble(message: message, isDark: isDark);
      },
    );
  }

  Widget _buildVideoView(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          height: 250,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: TalkingAvatarWidget(controller: _avatarCtrl),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              reverse: true,
              child: Text(
                _messages.isNotEmpty ? _messages.first.content : "...",
                style: AppTextStyles.subtitle2.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final AiAssistantMode mode;
  final Function(AiAssistantMode) onModeChanged;
  final VoidCallback? onClose;
  final bool isDark;

  const _HeaderSection({
    required this.mode,
    required this.onModeChanged,
    required this.onClose,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _ModeButton(
            label: context.l10n.ai_mode_chat,
            icon: Icons.chat_bubble_outline,
            isSelected: mode == AiAssistantMode.chat,
            onTap: () => onModeChanged(AiAssistantMode.chat),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _ModeButton(
            label: context.l10n.ai_mode_video,
            icon: Icons.videocam_outlined,
            isSelected: mode == AiAssistantMode.video,
            onTap: () => onModeChanged(AiAssistantMode.video),
            isDark: isDark,
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputArea extends StatefulWidget {
  final Function(String) onSend;
  final bool isDark;
  final bool isTyping;
  final AiAssistantMode mode;

  const _InputArea({
    required this.onSend,
    required this.isDark,
    required this.isTyping,
    required this.mode,
  });

  @override
  State<_InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<_InputArea> {
  final _textController = TextEditingController();

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty || widget.isTyping) return;

    widget.onSend(text);
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.backgroundDark : Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: widget.isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: context.l10n.ai_input_hint,
                  hintStyle: AppTextStyles.subtitle2.copyWith(
                    color: widget.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _handleSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.isTyping ? null : _handleSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.isTyping ? Colors.grey : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: widget.isTyping
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.subtitle2.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiChatMessage message;
  final bool isDark;

  const _ChatBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final displayContent = (message.isGreeting == true)
        ? context.l10n.ai_greeting
        : message.content;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          displayContent,
          style: AppTextStyles.subtitle2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
