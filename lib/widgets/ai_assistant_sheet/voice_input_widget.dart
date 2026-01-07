import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';
import 'package:sgtour_mobile/providers/locale_provider.dart';

class VoiceInputWidget extends ConsumerStatefulWidget {
  final Function(String) onSend;
  final VoidCallback onSwitchToKeyboard;
  final bool isDark;
  final bool isTyping;

  const VoiceInputWidget({
    super.key,
    required this.onSend,
    required this.onSwitchToKeyboard,
    required this.isDark,
    required this.isTyping,
  });

  @override
  ConsumerState<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends ConsumerState<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _currentWords = "";
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      await _speech.initialize(onError: (_) => _resetState());
    } catch (_) {}
  }

  Future<void> _startRecording() async {
    if (widget.isTyping) return;
    final localeState = ref.read(localeProvider);

    if (!_speech.isAvailable) await _speech.initialize();

    if (_speech.isAvailable) {
      setState(() {
        _isListening = true;
        _currentWords = "";
        _pulseController.repeat(reverse: true);
      });

      _speech.listen(
        onResult: (result) =>
            setState(() => _currentWords = result.recognizedWords),
        localeId: localeState.speechLocaleId,
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 4),
        cancelOnError: true,
      );
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (!_isListening) return;
    await _speech.stop();
    final msg = _currentWords;
    _resetState();
    if (msg.trim().isNotEmpty) widget.onSend(msg);
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _pulseController.stop();
      _pulseController.reset();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _currentWords.isNotEmpty || _isListening ? 1.0 : 0.5,
            child: Text(
              _currentWords.isEmpty
                  ? (_isListening ? "..." : "")
                  : _currentWords,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.subtitle1.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecordingAndSend(),
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecordingAndSend(),
                  onTapCancel: _resetState,
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.redAccent
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isListening
                                        ? Colors.redAccent
                                        : AppColors.primary)
                                    .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: widget.isTyping
                          ? const Center(
                              child: SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: widget.onSwitchToKeyboard,
                        style: IconButton.styleFrom(
                          backgroundColor: widget.isDark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: Icon(
                          Icons.keyboard,
                          color: widget.isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(
            _isListening
                ? context.l10n.ai_listening_action
                : context.l10n.ai_hold_to_speak,
            style: TextStyle(
              color: widget.isDark ? Colors.grey[500] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
