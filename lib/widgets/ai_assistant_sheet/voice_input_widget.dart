import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';
import 'package:sgtour_mobile/providers/locale_provider.dart';

class VoiceInputWidget extends ConsumerStatefulWidget {
  final Function(String) onSend;
  final bool isDark;
  final bool isTyping;

  const VoiceInputWidget({
    super.key,
    required this.onSend,
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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initSpeech();
  }

  void _initSpeech() async {
    try {
      await _speech.initialize(
        onError: (e) => _resetState(),
        onStatus: (status) {
          if (status == 'done' && _isListening) {}
        },
      );
    } catch (e) {}
  }

  Future<void> _startRecording() async {
    if (widget.isTyping) return;

    final localeState = ref.read(localeProvider);
    final speechId = localeState.speechLocaleId;

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    if (!_speech.isAvailable) await _speech.initialize();

    if (_speech.isAvailable) {
      setState(() {
        _isListening = true;
        _currentWords = "";
        _pulseController.repeat(reverse: true);
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _currentWords = result.recognizedWords;
          });
        },
        localeId: speechId,
        pauseFor: const Duration(seconds: 60),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (!_isListening) return;

    await _speech.stop();
    _resetState();

    if (_currentWords.trim().isNotEmpty) {
      widget.onSend(_currentWords);
    }
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
    const double avatarSize = 72.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isListening || _currentWords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _currentWords.isEmpty
                    ? context.l10n.ai_listening
                    : _currentWords,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.subtitle2.copyWith(
                  color: widget.isDark ? Colors.white70 : Colors.black87,
                  fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),

          GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) => _stopRecordingAndSend(),
            onTapDown: (_) => _startRecording(),
            onTapUp: (_) => _stopRecordingAndSend(),
            onTapCancel: _resetState,

            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.redAccent : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isListening ? Colors.redAccent : AppColors.primary)
                              .withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 3,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.isTyping
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.5,
                        ),
                      )
                    : Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            widget.isTyping
                ? context.l10n.ai_mode_chat
                : (_isListening
                      ? context.l10n.ai_mode_video
                      : context.l10n.ai_input_hint),
            style: AppTextStyles.subtitle2.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
