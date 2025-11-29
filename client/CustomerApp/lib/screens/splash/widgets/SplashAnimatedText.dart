import 'package:flutter/material.dart';

class SplashAnimatedText extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> fade;
  final Animation<Offset> slide;
  final String text;

  const SplashAnimatedText({
    super.key,
    required this.controller,
    required this.fade,
    required this.slide,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Opacity(
        opacity: fade.value,
        child: SlideTransition(
          position: slide,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
