import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DecorativeCircleBackground extends StatelessWidget {
  const DecorativeCircleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/svgs/item_background_dark.svg'
        : 'assets/svgs/item_background.svg';

    return Positioned(top: 0, right: 0, child: SvgPicture.asset(assetPath));
  }
}
