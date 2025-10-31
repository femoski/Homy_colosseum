import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioWaveform extends StatelessWidget {
  final bool isPlaying;
  final double? progress;
  final Color color;
  final Function(double)? onSeek;
  final Function()? onSeekStart;
  final AnimationController waveformAnimation;

  const AudioWaveform({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.color,
    this.onSeek,
    this.onSeekStart,
    required this.waveformAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => onSeekStart?.call(),
      onHorizontalDragUpdate: (details) {
        if (onSeek != null) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final double width = box.size.width;
          final double position = details.localPosition.dx;
          final double progress = position.clamp(0.0, width) / width;
          onSeek!(progress);
        }
      },
      onTapDown: (details) {
        if (onSeek != null) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final double width = box.size.width;
          final double position = details.localPosition.dx;
          final double progress = position.clamp(0.0, width) / width;
          onSeek!(progress);
        }
      },
      child: CustomPaint(
        size: const Size(double.infinity, 30),
        painter: WaveformPainter(
          progress: progress ?? 0.0,
          color: color,
          isPlaying: isPlaying,
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isPlaying;
  static final List<double> _barHeights = List.generate(
    20,
    (_) => 0.3 + math.Random().nextDouble() * 0.7,
  );

  WaveformPainter({
    required this.progress,
    required this.color,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (_barHeights.length * 1.2);
    
    for (var i = 0; i < _barHeights.length; i++) {
      final isActive = (i / _barHeights.length) <= progress;
      paint.color = isActive ? color : color.withOpacity(0.3);
      
      final barHeight = size.height * _barHeights[i];
      final x = i * (barWidth);
      canvas.drawLine(
        Offset(x, size.height / 2 + barHeight / 2),
        Offset(x, size.height / 2 - barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => 
      progress != oldDelegate.progress || color != oldDelegate.color;
} 