import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DecorativeCircleBackground extends StatelessWidget {
  const DecorativeCircleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SvgPicture.asset('assets/svgs/item_background.svg'),
    );
  }
}
