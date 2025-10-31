import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../services/CacheManager.dart';
import '../../../../services/reels_service.dart';


class VideoPlayerWidgetV2 extends StatefulWidget {
  final ReelData videoObj;
  VideoPlayerWidgetV2({
    Key? key,
    required this.videoObj,
  }) : super(key: key);
  @override
  _VideoPlayerWidgetV2State createState() => _VideoPlayerWidgetV2State();
}

class _VideoPlayerWidgetV2State extends State<VideoPlayerWidgetV2> with SingleTickerProviderStateMixin {
  late VideoPlayerController? _controller;
  // var muted = true.obs;

  late VoidCallback listener;
  // ReelsController reelsController = Get.find();
  ReelsService reelsService = Get.find();
  @override
  void initState() {
    super.initState();
    // dashboardController.onTap.value = false;
    // dashboardController.onTap.refresh();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoObj.content!),
      // closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    listener = () {
      if (mounted) setState(() {});
      // double trackPercentage = (_controller!.value.position.inMilliseconds / _controller!.value.duration.inMilliseconds) * 100;
      // print("trackPercentage $trackPercentage ${_controller!.value.position.inMilliseconds}");
      if (_controller!.value.position.inSeconds == 5) {
        // chkVideo = 1;
        // dashboardController.incrementVideoViews(widget.videoObj);
      } else if (reelsService.currentVideoId == widget.videoObj.id! && _controller!.value.position == _controller!.value.duration) {
        _controller!.seekTo(Duration.zero);
        _controller!.removeListener(listener);
        // Future.delayed(Duration(seconds: 1));
        _controller!.addListener(listener);

        _controller!.play();

        // dashboardController.incrementVideoViews(widget.videoObj);
        return;
      }
    };
    _controller!.setLooping(true);
    _controller!.initialize();
    _controller!.addListener(listener);
  }

  @override
  void dispose() {
    print("dispose VideoController");
    if (reelsService.videoControllers.containsKey(widget.videoObj.id)) {
      reelsService.videoControllers[widget.videoObj.id]!.videoCon!.dispose();
      reelsService.videoControllers.removeWhere((key, value) => key == widget.videoObj.id);
    }
    _controller!.removeListener(listener);
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: reelsService.bottomPadding.value),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Center(
            child: widget.videoObj.aspectRatio! > 0.8
                ? VisibilityDetector(
                    key: Key("${widget.videoObj.id}"),
                    onVisibilityChanged: (info) {
                      Get.log("onVisibilityChanged1 ${info.visibleFraction} ${widget.videoObj.id}");
                      setState(() {
                        reelsService.currentVideoId = widget.videoObj.id!;
                      });

                          if (info.visibleFraction >= 0.4) {
                            print("_controller $_controller");
                        setState(() {
                          reelsService.currentVideoId = widget.videoObj.id!;
                        });
                        if (!reelsService.videoPaused.value) {
                          _controller!.play();
                        }
                        reelsService.currentVideoPlayer.value = _controller!;
                        reelsService.currentVideoPlayer.refresh();
                      } else {
                        _controller!.pause();
                      }
                      if (mounted) setState(() {});
                    },
                    child: VideoPlayer(_controller!),
                  )
                : SizedBox.expand(
                    child: FittedBox(
                      fit: _controller!.value.size.height > _controller!.value.size.width ? BoxFit.fitHeight : BoxFit.fitWidth,
                      // fit: BoxFit.fitWidth,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VisibilityDetector(
                          key: Key("${widget.videoObj.id}"),
                          onVisibilityChanged: (info) {
                            print("onVisibilityChanged2 ${info.visibleFraction} ${widget.videoObj.id} ${widget.videoObj.aspectRatio} ${reelsService.videoPaused.value}");
                            if (_controller != null) {
                              if (info.visibleFraction >= 0.4) {
                                print("_controller $_controller");
                                setState(() {
                                  reelsService.currentVideoId = widget.videoObj.id!;
                                });
                                if (!reelsService.videoPaused.value) {
                                  _controller!.play();
                                }
                                reelsService.currentVideoPlayer.value = _controller!;
                                reelsService.currentVideoPlayer.refresh();
                              } else {
                                _controller!.pause();
                              }
                              if (mounted) setState(() {});
                            }
                          },
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    ),
                  ),
          ),
          AnimatedOpacity(
            opacity: !_controller!.value.isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 3000),
            curve: Curves.easeInOut,
            child: widget.videoObj.aspectRatio! > 0.8
                ? Center(
                    child: AspectRatio(
                      aspectRatio: widget.videoObj.aspectRatio!.toDouble(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Stack(
                          children: [
                            if (_controller!.value.position.inMilliseconds < 1)
                              CachedNetworkImage(
                                imageUrl: widget.videoObj.thumbnail!,
                                cacheManager: CustomCacheManager.instance,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            if (!_controller!.value.isInitialized)
                              Center(child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: SizedBox.expand(
                      child: _controller!.value.position.inMilliseconds < 1
                          ? CachedNetworkImage(
                              imageUrl: widget.videoObj.thumbnail!,
                              cacheManager: CustomCacheManager.instance,
                              fit: widget.videoObj.aspectRatio! > 1 ? BoxFit.fitWidth : BoxFit.fitHeight,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            )
                          : Container(),
                    ),
                  ),
          ),
          _ControlsOverlay(controller: _controller!),
          Positioned(
            bottom: 0,
            child: Container(
              height: Get.height * (0.40),
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black38,
                    Colors.black26,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Positioned(
          //   bottom: Get.mediaQuery.viewPadding.bottom + 50,
          //   width: Get.width,
          //   height: 10,
          //   child: SliderTheme(
          //     data: SliderThemeData(
          //       overlayShape: SliderComponentShape.noOverlay,
          //       // activeTrackColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          //       // disabledActiveTrackColor: Get.theme.colorScheme.primary.withOpacity(0.2),
          //       // inactiveTrackColor: Get.theme.colorScheme.primary,
          //       // inactiveTickMarkColor: Get.theme.colorScheme.primary,
          //       // disabledActiveTickMarkColor: Get.theme.colorScheme.primary,
          //       // disabledInactiveTickMarkColor: Get.theme.colorScheme.primary.withOpacity(0.2),
          //       disabledInactiveTrackColor: Get.theme.colorScheme.primary,
          //       disabledThumbColor: Get.theme.colorScheme.primary,
          //       trackHeight: 0.1,
          //       thumbShape: RoundSliderThumbShape(enabledThumbRadius: 1.50),
          //     ),
          //     child: SmoothVideoProgress(
          //       controller: _controller!,
          //       builder: (context, position, duration, child) => Slider(
          //         onChangeStart: (_) => _controller!.pause(),
          //         onChangeEnd: (_) => _controller!.play(),
          //         onChanged: (value) => _controller!.seekTo(Duration(milliseconds: value.toInt())),
          //         value: position.inMilliseconds.toDouble(),
          //         min: 0,
          //         max: duration.inMilliseconds.toDouble(),
          //         // activeColor: mainService.setting.value.dashboardIconColor!,
          //         // inactiveColor: mainService.setting.value.dashboardIconColor!.withOpacity(0.2),
          //       ),
          //     ),
          //   ),
          // ),
        ],
        // ),
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> with TickerProviderStateMixin {
  // ReelsController reelsController = Get.find();
  ReelsService reelsService = Get.find();


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: !widget.controller.value.isPlaying
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: widget.controller.value.isPlaying
                              ? Colors.transparent
                              : (!reelsService.videoPaused.value)
                                  ? Colors.transparent
                                  : Colors.white,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: AnimationController(duration: const Duration(milliseconds: 300), vsync: this),
                      size: 50,
                      color: widget.controller.value.isPlaying
                          ? Colors.transparent
                          : (!reelsService.videoPaused.value)
                              ? Colors.transparent
                              : Colors.white,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        GestureDetector(
          onTap: () {
            // dashboardController.onTap.value = true;

            reelsService.videoPaused.value = !reelsService.videoPaused.value;
            reelsService.videoPaused.refresh();
            print("GestureDetector ${reelsService.videoPaused.value}");
            if (widget.controller.value.isPlaying) {
              print(2222);
              widget.controller.pause();
            } else {
              print(33333);
              widget.controller.play();
            }
            setState(() {});
          },
        ),

        /*Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),*/
      ],
    );
  }
}
