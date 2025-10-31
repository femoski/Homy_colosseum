import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/repositories/reels_repository.dart';


class ReelsController extends GetxController {
  final _videos = <ReelData>[].obs;
  final _isLoading = false.obs;
  final _currentIndex = 0.obs;
  final _initializationFutures = <int, Future<void>>{}.obs;

  ReelsRepository _reelsRepository = ReelsRepository();
  bool get isLoading => _isLoading.value;
  List<ReelData> get videos => _videos;
  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {


      _isLoading.value = true;
      // Replace with your API endpoint
      final response = await _reelsRepository.getForYouReels();
      
    
      _videos.addAll(response);
      _preloadInitialVideos();
    } catch (e) {
      debugPrint('Error fetching videos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _preloadInitialVideos() {
    for (int i = 0; i < 3 && i < _videos.length; i++) {
      _preloadVideo(i);
    }
  }

  Future<void> _preloadVideo(int index) async {
    if (!_initializationFutures.containsKey(index) && 
        index >= 0 && 
        index < _videos.length) {
      _initializationFutures[index] = DefaultCacheManager()
          .getSingleFile(_videos[index].content!)
          .then((value) => null);
    }
  }

  void onPageChanged(int index) {
    _currentIndex.value = index;
    
    // Preload next videos
    _preloadVideo(index + 1);
    _preloadVideo(index + 2);

    // Load more videos if we're near the end
    if (index >= _videos.length - 2) {
      fetchVideos();
    }
  }

  Future<void>? getInitializationFuture(int index) {
    return _initializationFutures[index];
  }
} 