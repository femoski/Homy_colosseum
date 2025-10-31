import 'package:flutter/material.dart';

class FlowShader extends StatefulWidget {
  final Widget child;
  final List<Color>? flowColors;
  final Duration duration;
  final Axis direction;

  const FlowShader({
    Key? key,
    required this.child,
    this.flowColors,
    this.duration = const Duration(seconds: 2),
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  State<FlowShader> createState() => _FlowShaderState();
}

class _FlowShaderState extends State<FlowShader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: widget.flowColors ?? [Colors.white, Colors.grey],
        stops: const [0.0, 0.5],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        transform: _SlideGradientTransform(_controller.value),
      ).createShader(bounds),
      child: widget.child,
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform(this.percent);
  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0.0, 0.0);
  }
} 