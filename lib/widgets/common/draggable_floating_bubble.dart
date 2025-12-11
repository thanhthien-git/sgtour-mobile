import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class DraggableFloatingBubble extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final double initialRight;
  final double initialTop;
  final double edgePadding;

  const DraggableFloatingBubble({
    super.key,
    required this.child,
    this.onTap,
    this.size = 56,
    this.initialRight = 16,
    this.initialTop = 100,
    this.edgePadding = 8,
  });

  @override
  State<DraggableFloatingBubble> createState() =>
      _DraggableFloatingBubbleState();
}

class _DraggableFloatingBubbleState extends State<DraggableFloatingBubble>
    with SingleTickerProviderStateMixin {
  double _xPosition = 0;
  double _yPosition = 0;
  bool _isDragging = false;

  late final AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize position only once
    if (_xPosition == 0 && _yPosition == 0) {
      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;
      _xPosition = size.width - widget.initialRight - widget.size;
      _yPosition = widget.initialTop + padding.top;
    }
  }

  void _snapToEdge() {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    // Snap to nearest horizontal edge
    final targetX = (_xPosition + widget.size / 2 < screenWidth / 2)
        ? widget.edgePadding
        : screenWidth - widget.size - widget.edgePadding;

    // Clamp vertical position
    final minY = media.padding.top + 70;
    final maxY = screenHeight - media.padding.bottom - widget.size - 180;
    final targetY = _yPosition.clamp(minY, maxY);

    _animation =
        Tween<Offset>(
          begin: Offset(_xPosition, _yPosition),
          end: Offset(targetX, targetY),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _xPosition = targetX;
          _yPosition = targetY;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final offset = _animationController.isAnimating
            ? _animation.value
            : Offset(_xPosition, _yPosition);

        return Positioned(left: offset.dx, top: offset.dy, child: child!);
      },
      child: GestureDetector(
        onTap: _isDragging ? null : widget.onTap,
        onPanStart: (_) {
          setState(() => _isDragging = true);
          _animationController.stop();
        },
        onPanUpdate: (details) {
          setState(() {
            _xPosition += details.delta.dx;
            _yPosition += details.delta.dy;
          });
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
          _snapToEdge();
        },
        child: AnimatedScale(
          scale: _isDragging ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: _isDragging ? 16 : 12,
                  offset: const Offset(0, 4),
                  spreadRadius: _isDragging ? 2 : 0,
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
