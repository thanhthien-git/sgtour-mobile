// dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // SVG Background
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset('assets/svgs/item_background.svg'),
          ),
          // Main Content
          Center(
            child: Text(
              'Home Page',
              style: TextStyle(color: AppColors.text, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
