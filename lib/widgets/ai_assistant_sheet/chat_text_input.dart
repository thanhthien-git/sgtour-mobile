import 'package:flutter/material.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';

class ChatTextInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isDark;
  final bool isTyping;
  final VoidCallback onSwitchToVoice;

  const ChatTextInput({
    super.key,
    required this.onSend,
    required this.isDark,
    required this.isTyping,
    required this.onSwitchToVoice,
  });

  @override
  State<ChatTextInput> createState() => _ChatTextInputState();
}

class _ChatTextInputState extends State<ChatTextInput> {
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty || widget.isTyping) return;
    widget.onSend(text);
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: widget.isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.onSwitchToVoice,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.mic,
              color: widget.isDark ? Colors.grey[400] : AppColors.primary,
              size: 26,
            ),
          ),

          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 60, maxHeight: 100),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textAlignVertical: TextAlignVertical.center,
                style: AppTextStyles.subtitle2.copyWith(
                  color: widget.isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.ai_input_hint,
                  hintStyle: AppTextStyles.subtitle2.copyWith(
                    color: widget.isDark ? Colors.grey[500] : Colors.grey[600],
                  ),

                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.grey[900]
                      : Colors.grey[100],

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),

                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
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
                color: widget.isTyping ? Colors.grey[400] : AppColors.primary,
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
                  : const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
