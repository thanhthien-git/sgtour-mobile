import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum MouthState { closed, mid, open }

class AvatarController extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _lipSyncTimer;
  final Random _random = Random();

  MouthState _mouthState = MouthState.closed;
  bool _isSpeaking = false;

  MouthState get mouthState => _mouthState;
  bool get isSpeaking => _isSpeaking;

  AvatarController() {
    _initSystem();
  }

  void _initSystem() {
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
    ]);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _startLipSyncEngine();
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _stopAnimation();
    });
    _flutterTts.setCancelHandler(() {
      _stopAnimation();
    });
    _flutterTts.setErrorHandler((msg) {
      _stopAnimation();
    });
  }

  Future<void> speakFromBackend(String text, String langCode) async {
    if (text.isEmpty) return;

    if (_isSpeaking) await stop();

    try {
      await _flutterTts.setLanguage(langCode);
    } catch (e) {
      print("Lỗi set language '$langCode': $e. Fallback về tiếng Anh.");
      await _flutterTts.setLanguage("en-US");
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _stopAnimation();
  }

  void _startLipSyncEngine() {
    _lipSyncTimer?.cancel();
    _lipSyncTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!_isSpeaking) return;

      int roll = _random.nextInt(100);
      MouthState newState = _mouthState;

      if (_mouthState == MouthState.closed) {
        newState = (roll < 70) ? MouthState.mid : MouthState.open;
      } else if (_mouthState == MouthState.mid) {
        newState = (roll < 40) ? MouthState.closed : MouthState.open;
      } else {
        newState = (roll < 60) ? MouthState.mid : MouthState.closed;
      }

      if (newState != _mouthState) {
        _mouthState = newState;
        notifyListeners();
      }
    });
  }

  void _stopAnimation() {
    _lipSyncTimer?.cancel();
    _isSpeaking = false;
    _mouthState = MouthState.closed;
    notifyListeners();
  }

  @override
  void dispose() {
    _lipSyncTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
