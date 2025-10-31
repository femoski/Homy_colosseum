import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../utils/chat_globals.dart';
import '../../../utils/audio_state.dart';
import '../widgets/flow_shader.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'audio_wave.dart';
import 'package:flutter/rendering.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({
    required this.controller,
    required this.callback,
    required this.isSending,
    required this.onRecordingStateChanged,
    this.onTextFieldTap,
    super.key,
  });

  final AnimationController controller;
  final Function(dynamic path)? callback;
  final bool isSending;
  final Function(bool isRecording) onRecordingStateChanged;
  final VoidCallback? onTextFieldTap;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> with SingleTickerProviderStateMixin {
  static const double size = 48;
  final double lockerHeight = 150;
  double timerWidth = 0;

  late AnimationController _slideController;
  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;
  late Animation<double> fadeAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = '00:00';
  AudioRecorder? record;

  bool isLocked = false;
  bool showLottie = false;
  bool isPaused = false;
  bool isRecording = false;
  double dragOffset = 0;
  double verticalDragOffset = 0;

  final double _lockThreshold = -100;
  final double _cancelThreshold = -50;
  bool _showLockHint = false;
  bool _showCancelHint = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration? _duration;
  Duration _position = Duration.zero;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration?>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  StreamController<double>? _amplitudeController;
  Timer? _amplitudeTimer;

  String? _currentRecordingPath;

  // Add new animation properties
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Enhanced animations
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    buttonScaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth = MediaQuery.of(context).size.width-30;
    timerAnimation = Tween<double>(begin: 0, end: timerWidth).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOut,
      ),
    );
    
    lockerAnimation = Tween<double>(begin: 0, end: lockerHeight).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _amplitudeController?.close();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.stop().then((_) => _audioPlayer.dispose());
    timer?.cancel();
    _slideController.dispose();
    if (record != null) {
      record!.stop().then((path) {
        if (path != null && mounted) {
          File(path).delete();
        }
      });
      record!.dispose();
      record = null;
    }
    super.dispose();
  }

  Widget _buildRecordingSlider() {
    final cancelProgress = dragOffset < 0 
        ? (dragOffset / _cancelThreshold).clamp(0.0, 1.0) 
        : 0.0;
        
    return Positioned(
      right: 0,
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return Container(
            height: size,
            width: timerAnimation.value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Color.lerp(
                context.theme.colorScheme.primaryContainer,
                context.theme.colorScheme.errorContainer,
                cancelProgress,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.theme.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Opacity(
                  opacity: fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(dragOffset, 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildPulsingDot(),
                              const SizedBox(width: 8),
                              Text(
                                recordDuration,
                                style: TextStyle(
                                  color: context.theme.colorScheme.onPrimaryContainer,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: Color.lerp(
                                  context.theme.colorScheme.onPrimaryContainer,
                                  context.theme.colorScheme.error,
                                  cancelProgress,
                                )?.withOpacity(0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: Color.lerp(
                                    context.theme.colorScheme.onPrimaryContainer,
                                    context.theme.colorScheme.error,
                                    cancelProgress,
                                  )?.withOpacity(0.7),
                                  fontSize: _showCancelHint ? 15 : 14,
                                  fontWeight: _showCancelHint 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                                child: Text(
                                  _showCancelHint ? 'release to cancel' : 'slide to cancel',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulsingDot() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _rippleAnimation.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.colorScheme.error.withOpacity(
                    (2 - _rippleAnimation.value) / 2,
                  ),
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.theme.colorScheme.error,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLockSlider() {
    final clampedDragOffset = verticalDragOffset.clamp(_lockThreshold, 0.0);
    final lockProgress = clampedDragOffset < 0 
        ? (clampedDragOffset / _lockThreshold).clamp(0.0, 1.0) 
        : 0.0;
        
    if (lockProgress >= 1.0 && !isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isLocked = true;
          _showLockHint = false;
        });
        _slideController.reverse();
      });
    }
        
    return Positioned(
      bottom: 0,
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, clampedDragOffset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isLocked ? 0 : lockerAnimation.value,
              width: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Color.lerp(
                  context.theme.colorScheme.primaryContainer.withOpacity(0.5),
                  context.theme.colorScheme.tertiaryContainer,
                  lockProgress,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Opacity(
                opacity: fadeAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Animated gradient background
                      Positioned.fill(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                context.theme.colorScheme.tertiaryContainer.withOpacity(0),
                                context.theme.colorScheme.tertiaryContainer.withOpacity(lockProgress * 0.8),
                              ],
                              stops: [0.0, lockProgress],
                            ),
                          ),
                        ),
                      ),
                      
                      // Content
                      SizedBox(
                        height: lockerAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            // Lock icon with pulse animation
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                if (lockProgress >= 0.8)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.theme.colorScheme.tertiary.withOpacity(0.2),
                                    ),
                                  ),
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: lockProgress >= 0.8 ? 1.2 : 1.0,
                                  child: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color.lerp(
                                      context.theme.colorScheme.onPrimaryContainer,
                                      context.theme.colorScheme.tertiary,
                                      lockProgress,
                                    ),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Arrow and text
                            Expanded(
                              child: FlowShader(
                                direction: Axis.vertical,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedOpacity(
                                      duration: const Duration(milliseconds: 200),
                                      opacity: 1 - lockProgress,
                                      child: Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                        color: context.theme.colorScheme.onPrimaryContainer
                                            .withOpacity(0.7),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Vertical text container
                                    Center(
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          color: Color.lerp(
                                            context.theme.colorScheme.onPrimaryContainer,
                                            context.theme.colorScheme.tertiary,
                                            lockProgress,
                                          )?.withOpacity(0.9),
                                          fontSize: lockProgress >= 0.8 ? 13 : 11,
                                          fontWeight: lockProgress >= 0.8 
                                              ? FontWeight.w600 
                                              : FontWeight.normal,
                                          letterSpacing: 0.8,
                                        ),
                                        child: Text(
                                          lockProgress >= 0.8 
                                              ? 'RELEASE TO LOCK' 
                                              : 'SLIDE TO LOCK',
                                        ),
                                      ),
                                    )),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockedControls() {
    final duration = _duration ?? Duration.zero;
    final position = _position;
    
    return Container(
      height: size,
      width: timerWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.theme.colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          // Delete Button
          IconButton(
            onPressed: () async {
              if (!mounted) return;
              await _cancelRecording();
              setState(() {
                isLocked = false;
                isRecording = false;
                _isPlaying = false;
              });
              _slideController.reverse();
              widget.onRecordingStateChanged(false);
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.theme.colorScheme.error,
              size: 22,
            ),
          ),

          Expanded(
            child: isPaused || !isRecording 
              ? _buildPlaybackControls(position, duration)
              : _buildRecordingControls(),
          ),
          
          // Send Button
          IconButton(
            onPressed: () async {
              if (!mounted) return;
              await _sendRecording();
            },
            icon: Icon(
              Icons.send_rounded,
              color: context.theme.colorScheme.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(Duration position, Duration duration) {
    return Row(
      children: [
        // Play/Pause Button
        IconButton(
          onPressed: _handlePlayback,
          icon: Icon(
            _isPlaying 
              ? Icons.pause_rounded 
              : Icons.play_arrow_rounded,
            color: context.theme.colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom Progress Bar
              Stack(
                children: [
                  // Background Track
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  // Progress Track
                  FractionallySizedBox(
                    widthFactor: duration.inMilliseconds > 0 
                      ? position.inMilliseconds / duration.inMilliseconds 
                      : 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                  // Seekable Slider
                  Positioned.fill(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: context.theme.colorScheme.primary,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                          elevation: 2,
                        ),
                        overlayColor: context.theme.colorScheme.primary.withOpacity(0.12),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: position.inMilliseconds.toDouble(),
                        max: duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              // Duration Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          recordDuration,
          style: TextStyle(
            color: context.theme.colorScheme.onPrimaryContainer,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        AudioWaveform(
          isRecording: isRecording,
          isPaused: isPaused,
          color: context.theme.colorScheme.onPrimaryContainer,
          amplitudeStream: _amplitudeController?.stream,
        ),
        const SizedBox(width: 16),
       
        IconButton(
          onPressed: () async {
            if (!mounted) return;
            await _pauseRecording();
          },
          icon: Icon(
            isPaused ? Icons.fiber_manual_record : Icons.pause_rounded,
            color: isPaused 
              ? context.theme.colorScheme.error
              : context.theme.colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (startTime != null && mounted) {
        final minDur = DateTime.now().difference(startTime!).inMinutes;
        final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
        final min = minDur < 10 ? '0$minDur' : minDur.toString();
        final sec = secDur < 10 ? '0$secDur' : secDur.toString();
        setState(() {
          recordDuration = '$min:$sec';
        });
      }
    });
  }

  Future<void> _cancelRecording() async {
    timer?.cancel();
    timer = null;
    startTime = null;
    recordDuration = '00:00';
    
    try {
      if (record != null) {
        final filePath = await record!.stop();
        if (filePath != null && await File(filePath).exists()) {
          await File(filePath).delete();
          debugPrint('Deleted $filePath');
          Get.log('Deleted $filePath');
        }
      }
    } catch (e) {
      Get.log('Error handling recording cancellation: $e');
    } finally {
      if (record != null) {
        await record!.dispose();
        record = null;
      }
      setState(() {
        isPaused = false;
        isRecording = false;
        _currentRecordingPath = null;
      });
    }
  }

  Future<void> _handleRecordingStart() async {
    if (widget.isSending || !mounted) return;
    try {
      // First check if we have permission
      final hasPermission = await AudioRecorder().hasPermission();
      if (!hasPermission) {
        Get.log('No audio recording permission');
        return;
      }

      // Initialize the recorder
      record = AudioRecorder();
      
      // Configure the recording path
      String path;
      if (kIsWeb) {
        path = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      } else {
        final tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }
      _currentRecordingPath = path;
      
      // Start recording with error handling
      try {
        await record!.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 32000,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: path,
        );
        
        if (!mounted) return;
        setState(() {
          startTime = DateTime.now();
          isRecording = true;
          isPaused = false;
        });
        
        _updateRecordingState(true);
        _startTimer();
        _startAmplitudeUpdates();
        if (mounted) {
          _slideController.forward();
        }
      } catch (startError) {
        Get.log('Error starting recording: $startError');
        debugPrint('Error starting recording: $startError');
        // Clean up if recording failed to start
        if (record != null) {
          await record!.dispose();
          record = null;
        }
        setState(() {
          isRecording = false;
          isPaused = false;
        });
        // Show error to user
        Get.snackbar(
          'Recording Error',
          'Failed to start recording. Please check permissions and try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.log('Error in recording setup: $e');
      debugPrint('Error in recording setup: $e');
      setState(() {
        isRecording = false;
        isPaused = false;
      });
      // Show error to user
      Get.snackbar(
        'Recording Error',
        'Failed to initialize recording. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _handleRecordingEnd(LongPressEndDetails details) async {
    if (widget.isSending || !mounted) return;
    
    if (isCancelled(details.localPosition, context)) {
      await _cancelRecording();
      if (mounted) {
        _slideController.reverse();
        widget.onRecordingStateChanged(false);
      }
    } else if (checkIsLocked(details.localPosition)) {
      setState(() {
        isLocked = true;
        _showLockHint = false;
      });
    } else {
      if (mounted) {
        _slideController.reverse();
      }
      await saveFile();
      if (mounted) {
        setState(() {
          isRecording = false;
          isLocked = false;
          isPaused = false;
          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = '00:00';
        });
        widget.onRecordingStateChanged(false);
      }
    }
    
    if (mounted) {
      setState(() {
        dragOffset = 0;
        verticalDragOffset = 0;
        _showLockHint = false;
        _showCancelHint = false;
      });
    }
  }

  void _handleRecordingUpdate(LongPressMoveUpdateDetails details) {
    // Get.log('handleRecordingUpdate');
    if (widget.isSending || !mounted) return;
    
    setState(() {
      dragOffset = details.localPosition.dx;
      verticalDragOffset = details.localPosition.dy.clamp(_lockThreshold, 0.0);
      
      _showLockHint = verticalDragOffset < -20;
      _showCancelHint = dragOffset < -20;
      
      if (isRecording && _slideController.status == AnimationStatus.dismissed) {
        _slideController.forward();
      }
    });
  }

  Future<void> saveFile() async {
    timer?.cancel();
    timer = null;
    startTime = null;
    recordDuration = '00:00';

    if (record != null) {
      final filePath = await record!.stop();
      if (filePath != null) {
        AudioState.files.add(filePath);
        if (ChatGlobals.audioListKey.currentState != null) {
          ChatGlobals.audioListKey.currentState!
              .insertItem(AudioState.files.length - 1);
        }
        debugPrint(filePath);
        widget.callback?.call(filePath);
      }
    }
  }

  bool checkIsLocked(Offset offset) {
    return offset.dy <= _lockThreshold;
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return offset.dx <= _cancelThreshold;
  }

  Future<void> _pauseRecording() async {
    if (record != null) {
      try {
        if (isPaused) {
          // If we're resuming from pause
          record = AudioRecorder();
          if (kIsWeb) {
            // For web, use the existing path
            if (_currentRecordingPath != null) {
              await record!.start(
                const RecordConfig(
                  encoder: AudioEncoder.aacLc,
                  bitRate: 32000,
                  sampleRate: 16000,
                  numChannels: 1,
                ),
                path: _currentRecordingPath!,
              );
            }
          } else {
            // For native platforms, create a new temporary file
            final tempDir = await getTemporaryDirectory();
            final newPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
            await record!.start(
              const RecordConfig(
                encoder: AudioEncoder.aacLc,
                bitRate: 32000,
                sampleRate: 16000,
                numChannels: 1,
              ),
              path: newPath,
            );
            _currentRecordingPath = newPath;
          }
          _startTimer();
          _startAmplitudeUpdates();
          if (startTime == null) {
            startTime = DateTime.now().subtract(
              Duration(
                seconds: int.parse(recordDuration.split(':')[0]) * 60 +
                        int.parse(recordDuration.split(':')[1]),
              ),
            );
          }
        } else {
          // If we're pausing
          final tempPath = await record!.stop();
          if (tempPath != null) {
            _currentRecordingPath = tempPath;
            debugPrint('Paused recording saved at: $tempPath');
          }
          timer?.cancel();
          _amplitudeTimer?.cancel();
        }
        setState(() {
          isPaused = !isPaused;
        });
      } catch (e) {
        debugPrint('Error toggling recording pause state: $e');
        setState(() {
          isPaused = false;
          isRecording = true;
        });
      }
    }
  }

  Future<void> _sendRecording() async {
    if (!mounted) return;
    Get.log(record.toString());

    try {
      String? filePath;
      
      // If we're in playback mode (recording is paused), use the current recording path
      if (isPaused && _currentRecordingPath != null) {
        filePath = _currentRecordingPath;
        // Stop playback if it's playing
        if (_isPlaying) {
          await _audioPlayer.stop();
          setState(() => _isPlaying = false);
        }
      } 
      // If we're still recording, stop and get the file path
      else if (record != null) {
        filePath = await record!.stop();
      }

      if (filePath != null && mounted) {
        // Add to audio state
        AudioState.files.add(filePath);
        if (ChatGlobals.audioListKey.currentState != null) {
          ChatGlobals.audioListKey.currentState!
              .insertItem(AudioState.files.length - 1);
        }
        debugPrint('Sending recording: $filePath');
        
        // Send the recording
        widget.callback?.call(filePath);
      }
    } catch (e) {
      Get.log('Error sending recording: $e');
      debugPrint('Error sending recording: $e');
    }

    if (mounted) {
      // Clean up audio player
      await _audioPlayer.stop();
      
      setState(() {
        isLocked = false;
        isRecording = false;
        isPaused = false;
        _isPlaying = false;
        timer?.cancel();
        timer = null;
        startTime = null;
        recordDuration = '00:00';
        _currentRecordingPath = null;
      });
      
      widget.onRecordingStateChanged(false);
      _slideController.reverse();
    }
  }

  void _initAudioPlayer() {
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      setState(() => _position = position);
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _handlePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        if (_currentRecordingPath != null) {
          if (kIsWeb) {
            // Web platform handling
            Get.log('Playing audio from web: $_currentRecordingPath');
            await _audioPlayer.stop();
            await _audioPlayer.setUrl(_currentRecordingPath!);
            await _audioPlayer.play();
            setState(() => _isPlaying = true);
          } else {
            // Native platform handling
            final file = File(_currentRecordingPath!);
            if (await file.exists()) {
              Get.log('Playing audio from native: $_currentRecordingPath');
              await _audioPlayer.stop();
              await _audioPlayer.setFilePath(_currentRecordingPath!);
              await _audioPlayer.play();
              setState(() => _isPlaying = true);
            } else {
              Get.log('Audio file does not exist: $_currentRecordingPath');
            }
          }
        } else {
          Get.log('No recording path available');
        }
      } catch (e) {
        debugPrint('Error playing audio: $e');
        Get.log('Error playing audio: $e');
        setState(() => _isPlaying = false);
      }
    }
  }

  void _updateRecordingState(bool isRecording) {
    if (mounted) {
      setState(() {
        this.isRecording = isRecording;
        if (!isRecording) {
          isPaused = false;
          timer?.cancel();
          timer = null;
        }
      });
      widget.onRecordingStateChanged(isRecording);
    }
  }

  void _startAmplitudeUpdates() {
    _amplitudeController?.close();
    _amplitudeController = StreamController<double>();
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (record != null && isRecording && !isPaused && 
          _amplitudeController != null && !_amplitudeController!.isClosed && mounted) {
        try {
          final amplitude = await record!.getAmplitude();
          final normalized = (amplitude.current + 120) / 120;
          _amplitudeController?.add(normalized);
        } catch (e) {
          debugPrint('Error getting amplitude: $e');
        }
      }
    });
  }

  Future<void> _resumeRecording() async {
    if (!mounted) return;
    await _cancelRecording();
    await _handleRecordingStart();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        if (isRecording && !isLocked) _buildRecordingSlider(),
        if (isRecording && !isLocked) _buildLockSlider(),
        if (isLocked) _buildLockedControls(),
        GestureDetector(
          onTapDown: (_) => HapticFeedback.lightImpact(),
          onLongPressStart: (_) {
            HapticFeedback.mediumImpact();
            _handleRecordingStart();
          },
          onLongPressEnd: _handleRecordingEnd,
          onLongPressMoveUpdate: _handleRecordingUpdate,
          onTap: () {
            if (isLocked) {
              _sendRecording();
            } else {
              widget.onTextFieldTap?.call();
            }
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording 
                      ? (isLocked 
                          ? context.theme.colorScheme.primary 
                          : context.theme.colorScheme.error)
                      : context.theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (isRecording 
                          ? context.theme.colorScheme.error 
                          : context.theme.colorScheme.primary).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isLocked 
                        ? Icons.send 
                        : (isRecording 
                            ? Icons.mic 
                            : Icons.mic_none),
                      key: ValueKey(isRecording),
                      color: context.theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
