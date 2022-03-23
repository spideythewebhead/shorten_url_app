import 'dart:math' show pi;

import 'package:flutter/material.dart';

const _circleRads = 2.0 * pi;

class GradientBorderData {
  const GradientBorderData({
    required this.colors,
    this.radius = 0.0,
    this.width = 1.0,
  }) : assert(width >= 1.0, 'width should not be negative');

  final List<Color> colors;
  final double radius;
  final double width;
}

class GradientBorder extends StatelessWidget {
  const GradientBorder({
    Key? key,
    required this.child,
    required this.border,
  }) : super(key: key);

  /// Child widget
  final Widget child;

  final GradientBorderData border;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BorderPainter(data: border),
      child: child,
    );
  }
}

class AnimatedGradientBorder extends StatefulWidget {
  const AnimatedGradientBorder({
    Key? key,
    required this.child,
    required this.border,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
  }) : super(key: key);

  /// Child widget
  final Widget child;

  final GradientBorderData border;

  /// Duration of the animation
  final Duration duration;

  /// Curve of the animation
  final Curve curve;

  @override
  _AnimatedGradientBorderState createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _createAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.curve != widget.curve ||
        oldWidget.duration != widget.duration) {
      _disposeAnimation();
      _createAnimation();
    }
  }

  @override
  void dispose() {
    _disposeAnimation();
    super.dispose();
  }

  void _createAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: widget.duration)
          ..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: _circleRads).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );
  }

  void _disposeAnimation() {
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          isComplex: true,
          painter: _BorderPainter(
            data: widget.border,
            gradientAngle: _animation.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _BorderPainter extends CustomPainter {
  _BorderPainter({
    required this.data,
    double gradientAngle = 0,
  }) : _gradient = LinearGradient(
          colors: data.colors,
          transform: GradientRotation(gradientAngle),
        );

  final GradientBorderData data;

  final Gradient _gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    return canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(data.radius)),
      Paint()
        ..strokeWidth = data.width
        ..style = PaintingStyle.stroke
        ..shader = _gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
