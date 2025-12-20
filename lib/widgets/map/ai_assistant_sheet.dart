import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:sgtour_mobile/services/agent_service.dart';
import 'package:sgtour_mobile/widgets/avatar_controller.dart';
import 'package:sgtour_mobile/widgets/talking_avatar_widget.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';

enum AiAssistantMode { chat, video }

class AiChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const AiChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class AiAssistantSheet extends StatefulWidget {
  final VoidCallback? onClose;
  final LatLng? userLocation;
  const AiAssistantSheet({super.key, this.onClose, this.userLocation});

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  late final AvatarController _avatarCtrl;
  late final AgentService _agentService;

  final List<AiChatMessage> _messages = [];
  AiAssistantMode _mode = AiAssistantMode.chat;
  bool _isTyping = false;
  bool _hasInitializedGreeting = false;

  @override
  void initState() {
    super.initState();
    _avatarCtrl = AvatarController();
    _agentService = AgentService(ApiService());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedGreeting) {
      _messages.add(
        AiChatMessage(
          content: context.l10n.ai_greeting,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _hasInitializedGreeting = true;
    }
  }

  @override
  void dispose() {
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        AiChatMessage(content: text, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    try {
      final AgentResponse response = await _agentService.askAgent(text);

      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _messages.add(
          AiChatMessage(
            content: response.replyText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      if (_mode == AiAssistantMode.video) {
        _avatarCtrl.speakFromBackend(response.replyText, response.languageCode);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          AiChatMessage(
            content: context.l10n.ai_error,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  void _changeMode(AiAssistantMode newMode) {
    if (_mode == newMode) return;

    if (newMode == AiAssistantMode.chat) {
      _avatarCtrl.stop();
    }

    setState(() => _mode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          _HeaderSection(
            mode: _mode,
            onModeChanged: _changeMode,
            onClose: widget.onClose,
            isDark: isDark,
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _mode == AiAssistantMode.chat
                  ? _ChatViewList(
                      messages: _messages,
                      isTyping: _isTyping,
                      isDark: isDark,
                    )
                  : _VideoAvatarView(
                      controller: _avatarCtrl,
                      lastMessage: _messages.isNotEmpty ? _messages.last : null,
                      isDark: isDark,
                    ),
            ),
          ),

          _InputArea(
            onSend: _handleSendMessage,
            isDark: isDark,
            isTyping: _isTyping,
          ),
        ],
      ),
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

class _ChatViewList extends StatelessWidget {
  final List<AiChatMessage> messages;
  final bool isTyping;
  final bool isDark;

  const _ChatViewList({
    required this.messages,
    required this.isTyping,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      reverse: true,
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == 0) {
          return _TypingIndicator();
        }

        final msgIndex = isTyping ? index - 1 : index;
        final actualIndex = messages.length - 1 - msgIndex;
        final message = messages[actualIndex];

        return _ChatBubble(message: message, isDark: isDark);
      },
    );
  }
}

class _VideoAvatarView extends StatelessWidget {
  final AvatarController controller;
  final AiChatMessage? lastMessage;
  final bool isDark;

  const _VideoAvatarView({
    required this.controller,
    required this.lastMessage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 320,
          child: TalkingAvatarWidget(controller: controller),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Text(
                lastMessage?.content ?? context.l10n.ai_listening,
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputArea extends StatefulWidget {
  final Function(String) onSend;
  final bool isDark;
  final bool isTyping;

  const _InputArea({
    required this.onSend,
    required this.isDark,
    required this.isTyping,
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
                  hintStyle: AppTextStyles.body2.copyWith(
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
              style: AppTextStyles.caption.copyWith(
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
          message.content,
          style: AppTextStyles.body2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_Dot(delay: 0), _Dot(delay: 200), _Dot(delay: 400)],
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
