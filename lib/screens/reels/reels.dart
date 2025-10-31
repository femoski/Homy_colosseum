import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../models/reels/reels_model.dart';
import 'controllers/reels_controller.dart';

class ReelsScreen extends GetView<ReelsController> {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading && controller.videos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videos.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            final video = controller.videos[index];
            return ReelItem(
              video: video,
              currentIndex: index,
              initializationFuture: controller.getInitializationFuture(index),
            );
          },
        );
      }),
    );
  }
}

class ReelItem extends StatefulWidget {
  final ReelData video;
  final int currentIndex;
  final Future<void>? initializationFuture;

  const ReelItem({
    Key? key,
    required this.video,
    required this.currentIndex,
    this.initializationFuture,
  }) : super(key: key);

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() => _isBuffering = true);
      await widget.initializationFuture;

      final fileInfo = await DefaultCacheManager().getFileFromCache(widget.video.content!);
      final file = fileInfo?.file ?? 
                   await DefaultCacheManager().getSingleFile(widget.video.content!);

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.addListener(_videoListener);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isBuffering = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() => _isBuffering = false);
    }
  }

  void _videoListener() {
    final isBuffering = _controller.value.isBuffering;
    if (_isBuffering != isBuffering && mounted) {
      setState(() => _isBuffering = isBuffering);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reel-${widget.currentIndex}'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.8) {
          _controller.play();
          setState(() => _isPlaying = true);
        } else {
          _controller.pause();
          setState(() => _isPlaying = false);
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isInitialized)
              GestureDetector(
                onTap: _togglePlay,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_isBuffering)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (!_isPlaying && _isInitialized && !_isBuffering)
              _buildPlayButton(),
            _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          iconSize: 50,
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          onPressed: _togglePlay,
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${widget.video.user!.fullname}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.video.description ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
