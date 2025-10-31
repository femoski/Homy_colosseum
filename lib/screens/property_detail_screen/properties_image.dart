import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/media.dart';
import 'package:homy/screens/property_detail_screen/controllers/image_controller.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


// Custom cache manager for property images
class PropertyImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'propertyImagesCache';
  
  static PropertyImageCacheManager? _instance;
  factory PropertyImageCacheManager() {
    _instance ??= PropertyImageCacheManager._();
    return _instance!;
  }
  
  PropertyImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 30), // Cache for 30 days
      maxNrOfCacheObjects: 100, // Maximum 100 cached images
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

class ImagesScreen extends StatelessWidget {
  final List<Media> image;
  final int selectImageTab;

  const ImagesScreen({super.key, required this.image, required this.selectImageTab});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImagesScreenController(selectImageTab, image ?? []));
    
    // Preload images for better performance
    _preloadImages();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              _buildTabBar(controller, context),
              _buildImagesList(controller, context),
            ],
          );
        },
      ),
    );
  }

  void _preloadImages() {
    // Preload first few images for better user experience
    final cacheManager = PropertyImageCacheManager();
    final imagesToPreload = image.take(5).where((media) => 
      media.content != null && media.mediaTypeId != 5).toList();
    
    for (final media in imagesToPreload) {
      cacheManager.getSingleFile(media.content!).catchError((_) {
        // Ignore preload errors
      });
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios, 
          color: Theme.of(context).textTheme.bodyLarge?.color
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Property Images',
        style: MyTextStyle.productBlack(
          size: 18,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildTabBar(ImagesScreenController controller, BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 16, bottom: 12, left: 16, right: 16),
      width: double.infinity,
      child: ListView.builder(
        controller: controller.rowScrollController,
        itemCount: controller.imagesTab.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _buildTab(controller, index, context);
        },
      ),
    );
  }

  Widget _buildTab(ImagesScreenController controller, int index, BuildContext context) {
    bool isSelected = controller.selectedImagesTab == index;
    return InkWell(
      onTap: () => controller.onImagesTabTap(index),
      child: TabListHorizontal(
        title: controller.imagesTab[index],
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildImagesList(ImagesScreenController controller, BuildContext context) {
    return Expanded(
      child: SafeArea(
        top: false,
        child: controller.filteredMedia.isEmpty
            ? _buildEmptyState()
            : _buildImageGrid(controller),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: CommonUI.noDataFound(
        width: 120,
        height: 120,
        title: 'No Image',
        image: MImages.emptyBox,
      ),
    );
  }

  Widget _buildImageGrid(ImagesScreenController controller) {
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.filteredMedia.length,
      itemBuilder: (context, index) {
        return _buildImageItem(controller, index, context);
      },
    );
  }

  Widget _buildImageItem(ImagesScreenController controller, int index, BuildContext context) {
    final media = controller.filteredMedia[index];
    final isVideo = media.mediaTypeId == 5; // Assuming 5 is the video type ID

    return InkWell(
      onTap: () => isVideo ? _showVideoPlayer(context, media) : controller.onImageClick(media.content ?? ''),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isVideo)
                _buildVideoThumbnail(media)
              else
                _buildFilteredImage(controller, index),
              if (isVideo) _buildPlayButton(),
              if (controller.selectedImagesTab == 5) _build360Overlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(Media media) {
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        height: 261,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Try to find a previous image from the media list
            _buildVideoThumbnailImage(media),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnailImage(Media media) {
    // Find the index of current video in the filtered media list
    final controller = Get.find<ImagesScreenController>();
    final currentIndex = controller.filteredMedia.indexOf(media);
    
    // Look for a previous image (non-video) in the media list
    Media? previousImage;
    
    // First, try to find a previous image in the filtered list
    for (int i = currentIndex - 1; i >= 0; i--) {
      final item = controller.filteredMedia[i];
      if (item.mediaTypeId != 5 && item.content != null) {
        previousImage = item;
        break;
      }
    }
    
    // If no previous image found in filtered list, try the original image list
    if (previousImage == null) {
      for (int i = image.length - 1; i >= 0; i--) {
        final item = image[i];
        if (item.mediaTypeId != 5 && item.content != null) {
          previousImage = item;
          break;
        }
      }
    }
    
    // If still no image found, try to find any image in the list
    if (previousImage == null) {
      try {
        previousImage = image.firstWhere(
          (item) => item.mediaTypeId != 5 && item.content != null,
          orElse: () => Media(),
        );
      } catch (e) {
        // If no image found, use null
        previousImage = null;
      }
    }
    
    // If we found a previous image, use it as thumbnail
    if (previousImage != null && previousImage.content != null) {
      return CachedNetworkImage(
        imageUrl: previousImage.content!,
        fit: BoxFit.cover,
        cacheManager: PropertyImageCacheManager(),
        errorWidget: (context, url, error) => _buildVideoThumbnailFallback(),
        placeholder: (context, url) => _buildVideoThumbnailPlaceholder(),
        memCacheWidth: 800,
        memCacheHeight: 600,
      );
    }
    
    // Fallback to default placeholder
    return _buildVideoThumbnailFallback();
  }

  Widget _buildVideoThumbnailFallback() {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Video',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnailPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(16),
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  void _showVideoPlayer(BuildContext context, Media media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: VideoPlayerWidget(videoUrl: media.content ?? ''),
      ),
    );
  }

  Widget _buildFilteredImage(ImagesScreenController controller, int index) {
    final media = controller.filteredMedia[index];
    return ImageFiltered(
      imageFilter: controller.selectedImagesTab == 4
          ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
      child: CachedNetworkImage(
        imageUrl: media.content ?? '',
        width: double.infinity,
        height: 261,
        fit: BoxFit.cover,
        cacheManager: PropertyImageCacheManager(),
        errorWidget: (context, url, error) => _buildErrorWidget(context, error, null),
        placeholder: (context, url) => _buildLoadingWidget(context, Container(), null),
        memCacheWidth: 800, // Optimize memory usage
        memCacheHeight: 600,
      ),
    );
  }

  Widget _build360Overlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            MImages.threeSixtyIcon,
            color: Colors.white,
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 8),
          Text(
            '360',
            style: MyTextStyle.productBlack(
              color: Colors.white,
              size: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      width: double.infinity,
      height: 261,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.error_outline, 
        size: 40,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    return Container(
      width: double.infinity,
      height: 261,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class TabListHorizontal extends StatelessWidget {
  final String title;
  final bool isSelected;

  const TabListHorizontal({
    Key? key,
    required this.title,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected 
              ? theme.colorScheme.onPrimary 
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Create controller with simple settings
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // Initialize the controller
      await _controller!.initialize();

      // Create Chewie controller with simple settings
      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: true,
        looping: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Video playback error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _retryInitialization(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load video: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _retryInitialization(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _retryInitialization() async {
    // Dispose existing controllers
    await _controller?.dispose();
    _chewieController?.dispose();
    
    // Reset state
    setState(() {
      _controller = null;
      _chewieController = null;
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Reinitialize
    await _initializePlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Video playback error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _retryInitialization(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Reset orientation when closing
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
