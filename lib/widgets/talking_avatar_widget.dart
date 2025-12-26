import 'package:flutter/material.dart';
import 'avatar_controller.dart';

class TalkingAvatarWidget extends StatefulWidget {
  final AvatarController controller;

  const TalkingAvatarWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  State<TalkingAvatarWidget> createState() => _TalkingAvatarWidgetState();
}

class _TalkingAvatarWidgetState extends State<TalkingAvatarWidget> {
  late ImageProvider _baseImage;
  late ImageProvider _mouthMid;
  late ImageProvider _mouthOpen;

  @override
  void initState() {
    super.initState();
    _baseImage = const AssetImage('assets/avatars/mouth_closed.webp');
    _mouthMid = const AssetImage('assets/avatars/mouth_smile.webp');
    _mouthOpen = const AssetImage('assets/avatars/mouth_small.webp');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_baseImage, context);
    precacheImage(_mouthMid, context);
    precacheImage(_mouthOpen, context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: _baseImage,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),

              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 50),
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: _buildMouthImage(widget.controller.mouthState),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMouthImage(MouthState state) {
    switch (state) {
      case MouthState.mid:
        return Image(
          key: const ValueKey('mid'),
          image: _mouthMid,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      case MouthState.open:
        return Image(
          key: const ValueKey('open'),
          image: _mouthOpen,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      case MouthState.closed:
      default:
        return Container(
          key: const ValueKey('closed'),
          color: Colors.transparent,
        );
    }
  }
}
