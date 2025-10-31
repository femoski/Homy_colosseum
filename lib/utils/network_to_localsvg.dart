import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _CachedSvg {
  final String data;
  final DateTime timestamp;

  _CachedSvg(this.data) : timestamp = DateTime.now();

  bool get isExpired => 
      DateTime.now().difference(timestamp).inDays >= 1;
}

class NetworkToLocalSvg {
  static final NetworkToLocalSvg _instance = NetworkToLocalSvg._internal();
  factory NetworkToLocalSvg() => _instance;
  NetworkToLocalSvg._internal();

  final Dio dio = Dio();
  
  // Cache for both network and asset SVGs with expiration
  final Map<String, _CachedSvg> _svgCache = {};

  Future<String?> _loadAssetSvg(String assetPath) async {
    // Check cache first and validate expiration
    if (_svgCache.containsKey(assetPath)) {
      final cached = _svgCache[assetPath]!;
      if (!cached.isExpired) {
        return cached.data;
      } else {
        _svgCache.remove(assetPath); // Remove expired cache
      }
    }

    try {
      final svgString = await rootBundle.loadString(assetPath);
      // Cache the result
      _svgCache[assetPath] = _CachedSvg(svgString);
      return svgString;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _loadNetworkSvg(String url) async {
    // Check cache first and validate expiration
    if (_svgCache.containsKey(url)) {
      final cached = _svgCache[url]!;
      if (!cached.isExpired) {
        return cached.data;
      } else {
        _svgCache.remove(url); // Remove expired cache
      }
    }

    try {
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        final svgString = response.data as String;
        // Cache the result
        _svgCache[url] = _CachedSvg(svgString);
        return svgString;
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }

  Widget svg(
    String source, {
    Color? color,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final isNetwork = source.toLowerCase().startsWith('http');

    return FutureBuilder<String?>(
      future: isNetwork ? _loadNetworkSvg(source) : _loadAssetSvg(source),
      builder: (context, snapshot) {
        // Show placeholder while loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? SizedBox(width: width, height: height);
        }

        // Show error widget if loading failed
        if (!snapshot.hasData || snapshot.data == null) {
          return errorWidget ?? Container(
            width: width ?? 24,
            height: height ?? 24,
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported_outlined,
              size: (width ?? 24) * 0.5,
              color: Colors.grey,
            ),
          );
        }

        // Show SVG if loaded successfully
        try {
          return SvgPicture.string(
            snapshot.data!,
            colorFilter: color != null 
                ? ColorFilter.mode(color, BlendMode.srcIn)
                : null,
            width: width,
            height: height,
            fit: fit,
          );
        } catch (e) {
          return errorWidget ?? Container(
            width: width ?? 24,
            height: height ?? 24,
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported_outlined,
              size: (width ?? 24) * 0.5,
              color: Colors.grey,
            ),
          );
        }
      },
    );
  }

  // Method to clear all cache
  void clearCache() {
    _svgCache.clear();
  }
  
  // Method to remove specific SVG from cache
  void removeFromCache(String source) {
    _svgCache.remove(source);
  }

  // Method to clear expired cache entries
  void clearExpiredCache() {
    _svgCache.removeWhere((_, cached) => cached.isExpired);
  }
}

class _SVGBUILDER extends StatefulWidget {
  const _SVGBUILDER();

  @override
  State<_SVGBUILDER> createState() => _SVGBUILDERState();
}

class _SVGBUILDERState extends State<_SVGBUILDER> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
