import 'package:flutter/material.dart';
import 'package:sgtour_mobile/widgets/ai_assistant_sheet/chat_text_input.dart';
import 'package:sgtour_mobile/widgets/ai_assistant_sheet/voice_input_widget.dart';
import 'package:sgtour_mobile/widgets/map/map_widgets.dart';

class AiInputArea extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: mode == AiAssistantMode.video
          ? VoiceInputWidget(onSend: onSend, isDark: isDark, isTyping: isTyping)
          : ChatTextInput(onSend: onSend, isDark: isDark, isTyping: isTyping),
    );
  }
}
