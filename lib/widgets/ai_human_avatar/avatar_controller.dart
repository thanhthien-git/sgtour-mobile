import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sgtour_mobile/models/agent/heygen_session.dart';
import 'package:sgtour_mobile/services/agent/agent_service.dart';
import 'package:sgtour_mobile/services/file/storage_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AvatarController extends ChangeNotifier {
  static final AvatarController _instance = AvatarController._internal();
  factory AvatarController() => _instance;
  AvatarController._internal();

  WebViewController? _webViewController;
  static final AgentService service = AgentService();

  HeyGenSession? _savedSessionData;

  Timer? _closeSessionTimer;
  bool _isLoading = false;
  bool _isConnecting = false;
  bool _pendingStart = false;

  bool get isSessionActive => _savedSessionData != null;
  bool get isLoading => _isLoading || _isConnecting;
  String? get currentSessionId => _savedSessionData?.sessionId;

  void setController(WebViewController controller) {
    _webViewController = controller;

    if (_pendingStart) {
      _pendingStart = false;
      startSession();
    }
  }

  void onVideoReady() {
    _isConnecting = false;
    notifyListeners();
  }

  void onConnectionError(String error) {
    _isConnecting = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startSession() async {
    if (_closeSessionTimer != null && _closeSessionTimer!.isActive) {
      _closeSessionTimer?.cancel();
      _closeSessionTimer = null;
    }

    if (_webViewController == null) {
      _pendingStart = true;
      _setLoading(true);
      return;
    }

    if (_savedSessionData != null) {
      _isConnecting = true;
      notifyListeners();
      _restoreVisuals();
      return;
    }

    _setLoading(true);
    try {
      final languageCode =
          StorageService.instance.getString(StorageKeys.locale) ?? 'vi';
      debugPrint("AvatarController: Using languageCode: $languageCode");
      final session = await service.createHeyGenSession(languageCode);

      if (session != null) {
        _savedSessionData = session;
        _isConnecting = true;
        _isLoading = false;
        notifyListeners();

        await _webViewController!.runJavaScript(
          'window.connectAvatar("${session.url}", "${session.livekitAgentToken}");',
        );
      }
    } catch (e) {
      debugPrint("Error creating session: $e");
      _setLoading(false);
    }
  }

  Future<void> stopSession() async {
    if (_savedSessionData != null) {
      _closeSessionTimer?.cancel();

      final sessionIdToClose = _savedSessionData!.sessionId;

      _closeSessionTimer = Timer(const Duration(seconds: 10), () async {
        _savedSessionData = null;
        _webViewController = null;
        notifyListeners();

        try {
          await service.endHeyGenSession(sessionIdToClose);
        } catch (e) {
          debugPrint("Error ending session: $e");
        }
      });
    }
  }

  Future<void> stopSessionImmediately() async {
    if (_savedSessionData != null) {
      _closeSessionTimer?.cancel();

      final sessionIdToClose = _savedSessionData!.sessionId;
      _savedSessionData = null;
      _webViewController = null;
      notifyListeners();

      try {
        await service.endHeyGenSession(sessionIdToClose);
      } catch (e) {
        debugPrint("Error ending session: $e");
      }
    }
  }

  void _restoreVisuals() {
    if (_webViewController != null && _savedSessionData != null) {
      _webViewController!.runJavaScript(
        'window.connectAvatar("${_savedSessionData!.url}", "${_savedSessionData!.livekitAgentToken}");',
      );
    }
  }

  void cancelCloseSession() {
    if (_closeSessionTimer != null && _closeSessionTimer!.isActive) {
      _closeSessionTimer?.cancel();
      _closeSessionTimer = null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
