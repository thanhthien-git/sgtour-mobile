import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'avatar_controller.dart';

class TalkingAvatarWidget extends StatefulWidget {
  final AvatarController controller;

  const TalkingAvatarWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  State<TalkingAvatarWidget> createState() => _TalkingAvatarWidgetState();
}

class _TalkingAvatarWidgetState extends State<TalkingAvatarWidget> {
  late final WebViewController _webController;
  bool _isWebViewReady = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          final msg = message.message;
          debugPrint("WebView Log: $msg");

          if (msg == "video_ready") {
            widget.controller.onVideoReady();
          } else if (msg.startsWith("error:")) {
            widget.controller.onConnectionError(msg);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            widget.controller.setController(controller);
            setState(() => _isWebViewReady = true);
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    _webController = controller;
    _webController.loadFlutterAsset('assets/avatars/avatar.html');
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          WebViewWidget(controller: _webController),
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              if (widget.controller.isLoading || !_isWebViewReady) {
                return Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
