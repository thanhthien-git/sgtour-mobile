import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AvatarController extends ChangeNotifier {
  WebViewController? _webViewController;

  late FlutterTts _flutterTts;

  bool _isSessionActive = false;
  bool _isAvatarReady = false;

  bool get isAvatarReady => _isAvatarReady;
  bool get isSessionActive => _isSessionActive;

  AvatarController() {
    _initTts();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();

    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void setController(WebViewController controller) {
    _webViewController = controller;
    _isAvatarReady = true;
    notifyListeners();
  }

  Future<void> startSession(String token) async {
    if (_webViewController == null) return;

    debugPrint("AvatarController: Starting session with token...");
    try {
      await _webViewController!.runJavaScript('window.initAvatar("$token");');
      _isSessionActive = true;
      _isAvatarReady = true;
      notifyListeners();
    } catch (e) {
      debugPrint("AvatarController Error (startSession): $e");
      _isAvatarReady = true;
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    debugPrint("AvatarController: TTS Speaking: $text");
    await _flutterTts.speak(text);

    if (_webViewController != null && _isSessionActive) {
      try {
        final safeText = text.replaceAll('"', '\\"').replaceAll('\n', ' ');
        await _webViewController!.runJavaScript('window.speak("$safeText");');
      } catch (e) {
        debugPrint("AvatarController Error (speak WebView): $e");
      }
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop(); // Dừng đọc
    await stopSession();
  }

  Future<void> stopSession() async {
    try {
      if (_webViewController != null) {
        await _webViewController!.runJavaScript('window.closeSession();');
      }
      _isSessionActive = false;
      notifyListeners();
    } catch (e) {
      debugPrint("AvatarController Error (stopSession): $e");
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    stopSession();
    super.dispose();
  }
}
