import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sgtour_mobile/models/agent/heygen_session.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sgtour_mobile/services/agent_service.dart';

class AvatarController extends ChangeNotifier {
  static final AvatarController _instance = AvatarController._internal();
  factory AvatarController() => _instance;
  AvatarController._internal();

  WebViewController? _webViewController;
  static final AgentService service = AgentService();

  HeyGenSession? _savedSessionData;

  Timer? _closeSessionTimer;
  bool _isLoading = false;
  bool _pendingStart = false;

  bool get isSessionActive => _savedSessionData != null;
  bool get isLoading => _isLoading;
  String? get currentSessionId => _savedSessionData?.sessionId;

  void setController(WebViewController controller) {
    _webViewController = controller;

    if (_pendingStart) {
      _pendingStart = false;
      startSession();
    }
  }

  Future<void> startSession() async {
    if (_closeSessionTimer != null && _closeSessionTimer!.isActive) {
      debugPrint("🛑 User quay lại! Hủy lệnh gọi API EndSession.");
      _closeSessionTimer?.cancel();
      _closeSessionTimer = null;
    }

    if (_webViewController == null) {
      _pendingStart = true;
      _setLoading(true);
      return;
    }

    if (_savedSessionData != null) {
      debugPrint("✅ Session cũ vẫn sống. KHÔNG gọi API Create mới.");

      _restoreVisuals();

      _setLoading(false);
      return;
    }
    _setLoading(true);
    try {
      debugPrint("🚀 Chưa có session nào. Gọi API CreateHeyGenSession...");
      final session = await service.createHeyGenSession();

      if (session != null) {
        _savedSessionData = session;
        await _webViewController!.runJavaScript(
          'window.connectAvatar("${session.url}", "${session.livekitAgentToken}");',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error creating session: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> stopSession() async {
    if (_savedSessionData != null) {
      debugPrint("⏳ User rời đi. Đếm ngược 10s để gọi API hủy...");

      _closeSessionTimer?.cancel();

      final sessionIdToClose = _savedSessionData!.sessionId;

      _closeSessionTimer = Timer(const Duration(seconds: 10), () async {
        debugPrint(
          "💣 Hết 10s! User không quay lại -> GỌI API END SESSION ($sessionIdToClose)",
        );

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
