
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/app_icons.dart';
import 'package:homy/utils/network_to_localsvg.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';


class Ui {
  static SvgPicture getSvg(String path,
      {Color? color, BoxFit? fit, double? width, double? height}) {
    return SvgPicture.asset(
      path,
      color: color,
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
    );
  }

  static SvgPicture networkSvg(String url, {Color? color, BoxFit? fit}) {
    return SvgPicture.network(
      url,
      color: color,
      fit: fit ?? BoxFit.contain,
    );
  }



  static Widget getImage(String url,
      {double? width,
      double? height,
      BoxFit? fit,
      String? blurHash,
      bool? showFullScreenImage}) {
    
    // Validate URL
    if (url.isEmpty) {
      return _buildPlaceholder(width, height);
    }

    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: _customCacheManager,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
      memCacheWidth: _getValidCacheWidth(width),
      memCacheHeight: _getValidCacheHeight(height),
      placeholder: (context, url) => _buildPlaceholder(width, height),
      errorWidget: (context, url, error) => _buildErrorWidget(width, height),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      placeholderFadeInDuration: const Duration(milliseconds: 200),
    );
  }

  static Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Get.theme.colorScheme.tertiary.withOpacity(0.1),
      alignment: Alignment.center,
      child: FittedBox(
        child: SizedBox(
          width: 100,
          height: 70,
          child: getSvg(AppIcons.placeHolder2),
        ),
      ),
    );
  }

  static Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Get.theme.colorScheme.tertiary.withOpacity(0.1),
      alignment: Alignment.center,
      child: FittedBox(
        child: SizedBox(
          width: 70,
          height: 70,
          child: getSvg(
            AppIcons.placeHolder2,
            color: Get.theme.colorScheme.tertiary,
          ),
        ),
      ),
    );
  }

  /// Get valid cache width, handling infinity and null values
  static int? _getValidCacheWidth(double? width) {
    if (width == null || width.isInfinite || width.isNaN) {
      return null;
    }
    return width.toInt();
  }

  /// Get valid cache height, handling infinity and null values
  static int? _getValidCacheHeight(double? height) {
    if (height == null || height.isInfinite || height.isNaN) {
      return null;
    }
    return height.toInt();
  }


 static Widget imageType(
    String url, {
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    final ext = url.split('.').last.toLowerCase();
    if (ext == 'svg') {
      return NetworkToLocalSvg().svg(
        url,
        color: color,
        width: 20,
        height: 20,
      );
    } else {
      return getImage(
        url,
        fit: fit,
        height: height,
        width: width,
      );
    }
  }

  // static void showFullScreenImage(
  //   BuildContext context, {
  //   required ImageProvider provider,
  //   VoidCallback? then,
  //   bool? downloadOption,
  //   VoidCallback? onTapDownload,
  // }) {
  //   Navigator.of(context)
  //       .push(
  //     BlurredRouter(
  //       sigmaX: 10,
  //       sigmaY: 10,
  //       barrierDismiss: true,
  //       builder: (BuildContext context) => FullScreenImageView(
  //         provider: provider,
  //         showDownloadButton: downloadOption,
  //         onTapDownload: onTapDownload,
  //       ),
  //     ),
  //   )
  //       .then((value) {
  //     then?.call();
  //   });
  // }


  static Widget imageTypen(String url,
      {double? width, double? height, BoxFit? fit, Color? color}) {

        return getImage(
        url,
        fit: fit,
        height: height,
        width: width,
      );
    // String? ext = mime(url);
    // if (ext == "image/svg+xml") {
    //   return NetworkToLocalSvg().svg(
    //     url ?? "",
    //     color: color,
    //     width: 20,
    //     height: 20,
    //   );
    //   return SizedBox(
    //     width: width,
    //     height: height,
    //     child: networkSvg(url, fit: fit, color: color),
    //   );
    // } else {
    //   return getImage(
    //     url,
    //     fit: fit,
    //     height: height,
    //     width: width,
    //   );
    // }
  }


  static String removeDoubleSlashUrl(String url) {
    final uri = Uri.parse(url);
   
    final segments = List<String>.from(uri.pathSegments)
      ..removeWhere((element) => element == '');
    Get.log('uri: ${uri}');
    return Uri(
      host: uri.host,
      pathSegments: segments,
      scheme: uri.scheme,
      fragment: uri.fragment,
      queryParameters: uri.queryParameters,
      port: uri.port,
      query: uri.query,
      userInfo: uri.userInfo,
    ).toString();
  }

  // Custom cache manager for images with resizing support
  static final _customCacheManager = _HomyImageCacheManager();

  /// Clear all cached images
  static Future<void> clearImageCache() async {
    await _customCacheManager.emptyCache();
  }

  /// Remove a specific image from cache
  static Future<void> removeImageFromCache(String url) async {
    await _customCacheManager.removeFile(url);
  }

  /// Get cache size information
  static Future<int> getCacheSize() async {
    try {
      // Get cache directory using path_provider
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/homy_images_cache');
      
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        int totalSize = 0;
        for (var file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
        return totalSize;
      }
    } catch (e) {
      Get.log('Error getting cache size: $e');
    }
    return 0;
  }

  /// Preload an image into cache
  static Future<void> preloadImage(String url) async {
    try {
      await _customCacheManager.downloadFile(url);
    } catch (e) {
      Get.log('Failed to preload image: $url - $e');
    }
  }

  /// Get cached image file if exists
  static Future<File?> getCachedImageFile(String url) async {
    try {
      return await _customCacheManager.getSingleFile(url);
    } catch (e) {
      return null;
    }
  }
}

// Custom cache manager for images with resizing support
class _HomyImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'homy_images_cache';
  
  static _HomyImageCacheManager? _instance;
  factory _HomyImageCacheManager() {
    _instance ??= _HomyImageCacheManager._();
    return _instance!;
  }
  
  _HomyImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
