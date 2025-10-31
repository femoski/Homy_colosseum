import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/chat_screen/widgets/audio_message_wave.dart';
import 'package:just_audio/just_audio.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/services/audio_cache_service.dart';
import 'package:homy/services/audio_manager_service.dart';
import 'package:flutter/cupertino.dart';

class AudioMessage extends StatefulWidget {
  final ChatMessages? chat;
  final bool isDeletedMsg;

  const AudioMessage({
    super.key,
    required this.chat,
    required this.isDeletedMsg,
  });

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AudioCacheService _audioCache;
  AudioPlayer? _player;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  double playbackSpeed = 1.0;
  final List<double> speedOptions = [0.5, 1.0, 1.5, 2.0];
  late final AudioManagerService _audioManager;
  late AnimationController _waveformAnimationController;
  bool _isDraggingSeek = false;
  String? _currentMediaUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _waveformAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _audioCache = AudioCacheService();
    _audioManager = Get.find<AudioManagerService>();
    _currentMediaUrl = widget.chat?.media;
    _initializeAudio();
  }

  @override
  void didUpdateWidget(AudioMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if media URL has changed
    if (widget.chat?.media != _currentMediaUrl) {
      // Only dispose if not currently playing
      if (_player != null && !isPlaying) {
        _player!.stop();
        _audioCache.dispose(_currentMediaUrl!);
        
        // Reset state
        setState(() {
          isPlaying = false;
          _currentMediaUrl = widget.chat?.media;
        });
        
        // Initialize new audio
        _initializeAudio();
      } else {
        // Just update the URL without disposing if playing
        setState(() {
          _currentMediaUrl = widget.chat?.media;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopPlaying();
    }
  }

  Future<void> _initializeAudio() async {
    if (widget.chat?.media == null) return;

    // Don't reinitialize if already playing
    if (_player != null && isPlaying) return;

    _player = await _audioCache.getAudioPlayer(widget.chat!.media!);
    _player!.setLoopMode(LoopMode.off);

    _player!.positionStream.listen((pos) {
      if (mounted) {
        setState(() => position = pos);
      }
    });

    _player!.durationStream.listen((dur) {
      if (mounted) {
        setState(() => duration = dur ?? Duration.zero);
      }
    });

    _player!.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            isPlaying = false;
            position = Duration.zero;
            _player!.stop();
            _audioManager.currentlyPlaying = null;
          }
        });
      }
    });
  }

  Future<void> _playPause() async {
    if (_player == null) return;

    if (isPlaying) {
      await _player!.pause();
    } else {
      if (position >= duration) {
        position = Duration.zero;
        await _player!.seek(Duration.zero);
      }

      await _audioManager.stopCurrentlyPlaying();
      _audioManager.setCurrentlyPlaying(_player!);
      await _player!.seek(position);
      await _player!.play();
    }
  }

  void _changePlaybackSpeed() {
    if (_player == null) return;

    int currentIndex = speedOptions.indexOf(playbackSpeed);
    int nextIndex = (currentIndex + 1) % speedOptions.length;
    playbackSpeed = speedOptions[nextIndex];
    _player!.setSpeed(playbackSpeed);
    setState(() {});
  }

  Future<void> _handleSeek(double progress) async {
    if (_player == null || duration == Duration.zero) return;

    final newPosition = duration * progress;
    position = newPosition;
    await _player!.seek(newPosition);
    setState(() {});
  }

  Future<void> _stopPlaying() async {
    if (_player != null && isPlaying) {
      await _player!.pause();
      setState(() {
        isPlaying = false;
      });
      _audioManager.currentlyPlaying = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _waveformAnimationController.dispose();
    
    // Stop playing when widget is disposed
    _stopPlaying();
    
    // Only dispose the audio cache if not being used elsewhere
    if (_currentMediaUrl != null && _audioManager.currentlyPlaying != _player) {
      _audioCache.dispose(_currentMediaUrl!);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = Get.find<AuthService>();
    bool isMe = widget.chat?.fromId == int.parse(_authService.id.toString());
    bool isDarkMode = context.theme.brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: EdgeInsets.only(
          left: isMe ? 50 : 8,
          right: isMe ? 8 : 50,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? (isDarkMode
                  ? context.theme.colorScheme.primary.withOpacity(0.2)
                  : context.theme.colorScheme.primary.withOpacity(0.1))
              : (isDarkMode
                  ? context.theme.cardColor.withOpacity(0.1)
                  : context.theme.cardColor.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlayButton(isMe),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWaveformWithDuration(isMe),
                      const SizedBox(height: 4),
                      _buildControlsRow(isMe),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(bool isMe) {
    bool isDarkMode = context.theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isMe
              ? (isDarkMode
                  ? context.theme.colorScheme.onPrimary.withOpacity(0.15)
                  : context.theme.colorScheme.primary.withOpacity(0.15))
              : (isDarkMode
                  ? context.theme.colorScheme.primary.withOpacity(0.15)
                  : context.theme.colorScheme.primary.withOpacity(0.1)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
            key: ValueKey(isPlaying),
            color: isMe
                ? (isDarkMode
                    ? context.theme.colorScheme.onPrimary.withOpacity(0.9)
                    : context.theme.colorScheme.primary)
                : context.theme.colorScheme.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildWaveformWithDuration(bool isMe) {
    bool isDarkMode = context.theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 30,
          child: AudioWaveform(
            isPlaying: isPlaying,
            progress: _isDraggingSeek
                ? null
                : (duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0),
            color: isMe
                ? (isDarkMode
                    ? context.theme.colorScheme.onPrimary.withOpacity(0.8)
                    : context.theme.colorScheme.primary.withOpacity(0.8))
                : (isDarkMode
                    ? context.theme.colorScheme.primary.withOpacity(0.8)
                    : context.theme.colorScheme.primary.withOpacity(0.7)),
            onSeek: (progress) {
              _isDraggingSeek = false;
              _handleSeek(progress);
            },
            onSeekStart: () => _isDraggingSeek = true,
            waveformAnimation: _waveformAnimationController,
          ),
        ),
      ],
    );
  }

  Widget _buildControlsRow(bool isMe) {
    final textColor = isMe
        ? context.theme.colorScheme.onPrimary.withOpacity(0.8)
        : context.theme.colorScheme.onSurface.withOpacity(0.8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (duration != Duration.zero && isPlaying) ...[
          Text(
            _formatDuration(position),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (duration != Duration.zero && !isPlaying) ...[
          Text(
            _formatDuration(duration),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        Row(
          children: [
            _buildSpeedButton(isMe),
            const SizedBox(width: 8),
            _buildTimeStamp(context, isMe, false),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedButton(bool isMe) {
    bool isDarkMode = context.theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _changePlaybackSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isMe
              ? (isDarkMode
                  ? context.theme.colorScheme.onPrimary.withOpacity(0.15)
                  : context.theme.colorScheme.primary.withOpacity(0.15))
              : (isDarkMode
                  ? context.theme.colorScheme.primary.withOpacity(0.15)
                  : context.theme.colorScheme.primary.withOpacity(0.1)),
        ),
        child: Text(
          '${playbackSpeed}x',
          style: TextStyle(
            color: isMe
                ? (isDarkMode
                    ? context.theme.colorScheme.onPrimary.withOpacity(0.9)
                    : context.theme.colorScheme.primary)
                : context.theme.colorScheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeStamp(BuildContext context, bool isMe, bool onImage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      // decoration: BoxDecoration(
      //   color: onImage
      //       ? Colors.black.withOpacity(0.5)
      //       : (isMe
      //           ? context.theme.colorScheme.primary.withOpacity(0.15)
      //           : context.theme.colorScheme.background.withOpacity(0.8)),
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(
      //     color: onImage
      //         ? Colors.transparent
      //         : (isMe
      //             ? context.theme.colorScheme.primary.withOpacity(0.15)
      //             : context.theme.dividerColor.withOpacity(0.1)),
      //     width: 0.5,
      //   ),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatMessageTime((widget.chat?.time?.toInt() ?? 0) * 1000),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: onImage
                  ? Colors.white
                  : (isMe
                      ? context.theme.colorScheme.primary.withOpacity(0.8)
                      : context.theme.hintColor.withOpacity(0.8)),
            ),
          ),
          const SizedBox(width: 4),
          _buildMessageStatus(context, isMe, onImage),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(BuildContext context, bool isMe, bool onImage) {
    if (!isMe) return const SizedBox.shrink();

    IconData? icon;
    Color? color;

    switch (widget.chat?.status?.toLowerCase()) {
      case 'sent':
        icon = Icons.check;
        color = onImage ? Colors.white : Colors.grey;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = onImage ? Colors.white : Colors.grey;
        break;
      case 'read':
        icon = Icons.done_all;
        color = onImage ? Colors.white : Colors.blue;
        break;
      case 'pending':
        icon = Icons.access_time;
        color = onImage ? Colors.white : Colors.grey;
        break;
      default:
        icon = Icons.access_time;
        color = onImage ? Colors.white : Colors.grey;
        break;
    }

    return icon != null
        ? Icon(
            icon,
            size: 16,
            color: color,
          )
        : const SizedBox.shrink();
  }

  String _formatMessageTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // if (_isSameDay(date, now)) {
    //   return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    // } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
    //   return 'Yesterday';
    // } else {
    //   return '${date.day}/${date.month}';
    // }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
