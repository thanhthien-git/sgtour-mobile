import 'package:flutter/material.dart';
import 'package:sgtour_mobile/widgets/ai_assistant_sheet/ai_assistant_sheet.dart';
import 'package:sgtour_mobile/widgets/ai_assistant_sheet/chat_text_input.dart';
import 'package:sgtour_mobile/widgets/ai_assistant_sheet/voice_input_widget.dart';

class AiInputArea extends StatefulWidget {
  final Function(String) onSend;
  final bool isDark;
  final bool isTyping;
  final AiAssistantMode mode;

  const AiInputArea({
    super.key,
    required this.onSend,
    required this.isDark,
    required this.isTyping,
    required this.mode,
  });

  @override
  State<AiInputArea> createState() => _AiInputAreaState();
}

class _AiInputAreaState extends State<AiInputArea> {
  bool? _isVoiceMode;

  @override
  void initState() {
    super.initState();
    _updateModeDefault();
  }

  @override
  void didUpdateWidget(AiInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode) {
      _updateModeDefault();
    }
  }

  void _updateModeDefault() {
    _isVoiceMode = widget.mode == AiAssistantMode.video;
  }

  @override
  Widget build(BuildContext context) {
    final bool showVoice = _isVoiceMode ?? false;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0,
          child: child,
        ),
      ),
      child: showVoice
          ? VoiceInputWidget(
              key: const ValueKey('voice'),
              onSend: widget.onSend,
              isDark: widget.isDark,
              isTyping: widget.isTyping,
              onSwitchToKeyboard: () => setState(() => _isVoiceMode = false),
            )
          : ChatTextInput(
              key: const ValueKey('text'),
              onSend: widget.onSend,
              isDark: widget.isDark,
              isTyping: widget.isTyping,
              onSwitchToVoice: () => setState(() => _isVoiceMode = true),
            ),
    );
  }
}
