import 'dart:math' as math;
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';

class HeartLoader extends StatefulWidget {
  const HeartLoader({super.key});

  @override
  State<HeartLoader> createState() => _HeartLoaderState();
}

class _HeartLoaderState extends State<HeartLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Match CSS 0.6s
    )..repeat(); // Infinite loop

    // CSS Keyframes for Scale:
    // 0% -> 1.07
    // 80% -> 1.0
    // 100% -> 0.8
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.07, end: 1.0),
        weight: 80, // 0% to 80%
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 20, // 80% to 100%
      ),
    ]).animate(_controller);

    // CSS Keyframes for Blur:
    // 0% -> 0px
    // 80% -> 1px
    // 100% -> 2px
    _blurAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 2.0),
        weight: 20,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double size = 70.0;
    const Color heartColor = Color(0xFFf20044);

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: -math.pi / 4, // Rotate -45 degrees
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: ImageFiltered(
                // Apply the blur effect
                imageFilter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // The Main Square (Body of the heart)
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: heartColor,
                        // The CSS Glow Shadow
                        boxShadow: [
                          BoxShadow(
                            color: heartColor,
                            offset: const Offset(-10, -10),
                            blurRadius: 90,
                          ),
                        ],
                      ),
                    ),
                    // Top Circle (CSS ::before)
                    Positioned(
                      top: -size / 2, // -35px
                      left: 0,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          color: heartColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Right Circle (CSS ::after)
                    Positioned(
                      top: 0,
                      right: -size / 2, // -35px
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          color: heartColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}