import 'dart:async';
import 'package:flutter/material.dart';

class AudioWaveform extends StatefulWidget {
  const AudioWaveform({
    required this.isRecording,
    required this.isPaused,
    required this.color,
    this.amplitudeStream,
    super.key,
  });

  final bool isRecording;
  final bool isPaused;
  final Color color;
  final Stream<double>? amplitudeStream;

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> {
  List<double> amplitudes = List.filled(30, 0.0);
  StreamSubscription<double>? _amplitudeSubscription;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _subscribeToAmplitude();
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amplitudeStream != widget.amplitudeStream) {
      _amplitudeSubscription?.cancel();
      _subscribeToAmplitude();
    }
  }

  void _subscribeToAmplitude() {
    if (widget.amplitudeStream != null) {
      _amplitudeSubscription = widget.amplitudeStream!.listen(
        (amplitude) {
          if (!_disposed && mounted) {
            setState(() {
              amplitudes = [...amplitudes.sublist(1), amplitude];
            });
          }
        },
        onError: (error) {
          debugPrint('Error in amplitude stream: $error');
        },
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _amplitudeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          15,
          (index) {
            double amplitude = widget.isRecording && !widget.isPaused
                ? amplitudes[index * 2]
                : 0.5;
                
            return AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: 3,
              height: (20 * amplitude).clamp(3.0, 20.0),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(
                  widget.isRecording && !widget.isPaused ? 1 : 0.5,
                ),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          },
        ),
      ),
    );
  }
} 