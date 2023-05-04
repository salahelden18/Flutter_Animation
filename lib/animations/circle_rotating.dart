// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';

enum CircleSide {
  left,
  right,
}

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();

    late Offset offset;

    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }
    path.arcToPoint(offset,
        radius: Radius.elliptical(size.width / 2, size.height / 2),
        clockwise: clockwise);
    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  final CircleSide side;

  const HalfCircleClipper({
    required this.side,
  });

  @override
  Path getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CircleRotating extends StatefulWidget {
  const CircleRotating({super.key});

  @override
  State<CircleRotating> createState() => _CircleRotatingState();
}

class _CircleRotatingState extends State<CircleRotating>
    with TickerProviderStateMixin {
  late AnimationController _counterClickwiseRotationController;
  late Animation _counterClockwiseRotationAnimation;

  late AnimationController _flipController;
  late Animation _flipAnimation;

  @override
  void initState() {
    super.initState();

    _counterClickwiseRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _counterClockwiseRotationAnimation = Tween<double>(
      begin: 0.0,
      end: -(pi / 2),
    ).animate(
      CurvedAnimation(
        parent: _counterClickwiseRotationController,
        curve: Curves.bounceOut,
      ),
    );

    _counterClickwiseRotationController.forward();

    // flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.bounceOut,
      ),
    );

    _counterClickwiseRotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation = Tween<double>(
          begin: _flipAnimation.value,
          end: _flipAnimation.value + pi,
        ).animate(
          CurvedAnimation(
            parent: _flipController,
            curve: Curves.bounceOut,
          ),
        );
        // reset the flip controller and start the animation
        _flipController
          ..reset()
          ..forward();
      }
    });

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _counterClockwiseRotationAnimation = Tween<double>(
          begin: _counterClickwiseRotationController.value,
          end: _counterClickwiseRotationController.value + -(pi / 2.0),
        ).animate(
          CurvedAnimation(
            parent: _counterClickwiseRotationController,
            curve: Curves.bounceOut,
          ),
        );
        _counterClickwiseRotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _counterClickwiseRotationController.dispose();
    _flipController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _counterClickwiseRotationController,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _flipController,
                builder: (context, child) => Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()..rotateY(_flipAnimation.value),
                  child: ClipPath(
                    clipper: const HalfCircleClipper(side: CircleSide.left),
                    child: Container(
                      color: const Color(0xff0057b7),
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _flipController,
                builder: (context, child) => Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()..rotateY(_flipAnimation.value),
                  child: ClipPath(
                    clipper: const HalfCircleClipper(side: CircleSide.right),
                    child: Container(
                      color: const Color(0xffffd700),
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
            ],
          ),
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(_counterClockwiseRotationAnimation.value),
            child: child,
          ),
        ),
      ),
    );
  }
}
