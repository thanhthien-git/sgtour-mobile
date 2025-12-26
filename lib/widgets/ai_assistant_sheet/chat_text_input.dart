import 'package:flutter/material.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';

class ChatTextInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isDark;
  final bool isTyping;

  const ChatTextInput({
    super.key,
    required this.onSend,
    required this.isDark,
    required this.isTyping,
  });

  @override
  State<ChatTextInput> createState() => _ChatTextInputState();
}

class _ChatTextInputState extends State<ChatTextInput> {
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
                  border: InputBorder.none,
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
