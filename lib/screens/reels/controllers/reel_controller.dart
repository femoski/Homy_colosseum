import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/services/reels_service.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

import '../../../models/reels/reels_model.dart';
import '../../../repositories/reels_repository.dart';
import '../../../services/CacheManager.dart';

class ReelController extends GetxController {
  final RxList<ReelData> reels = RxList.empty();

  final ReelsRepository reelRepository = ReelsRepository();
  ReelsService reelsService = Get.find();
  final RxBool isLoading = false.obs;
  var isVideoInitialized = false.obs;
  var dataLoaded = false.obs;
  var likeShowLoader = false.obs;
  var shareShowLoader = false.obs;
  var showReportLoader = false.obs;
  var showReportMsg = false.obs;
  var loadMoreUpdateView = false.obs;
  var commentsLoader = false.obs;
  var soundShowLoader = false.obs;
  var isFollowedAnyPerson = false.obs;
  var showBannerAd = false.obs;
  var showHomeLoader = false.obs;
  var showLikedAnimation = false.obs;
  var videoObj = ReelData().obs;
  var showProgress = false.obs;
  var onTap = false.obs;
  bool initializePage = true;


    int videoId = 0;
  bool completeLoaded = false;
  String commentValue = '';
  bool textFieldMoveToUp = false;
  DateTime currentBackPressTime = DateTime.now();

  ScrollController scrollController = new ScrollController();
  ScrollController scrollController1 = new ScrollController();

  PanelController pc = new PanelController();
  var commentController = TextEditingController().obs;

    var hideBottomBar = false.obs;


  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  var pageViewController = new PageController(initialPage: 0).obs;


  @override
  void onInit() {
    super.onInit();
    reels.addAll(reels);
  }

  void clearReels() {
    reels.clear();
  }

  Future<void> fetchReels() async {
    reelsService.pageController.value.addListener(() {
      reelsService.pageIndex.value = reelsService.pageController.value.page?.toInt() ?? 0;
    });

    reelsService.pageIndex.value = 0;
    isLoading.value = true;
    isLoading.refresh();

     var distinctIds = reelsService.postIds.toSet().toList();
    try {
      final result = await reelRepository.getForYouReels();
      reelsService.videosData.value.addAll(result);

      Get.log('result: ${result.length}');
      Get.log('reelsService.videosData.value: ${reelsService.videosData.value.length}');
      reelsService.videosData.refresh();
      if (result.isNotEmpty) {
        reels.addAll(result);
      }

   isLoading.value = false;
    isLoading.refresh();
    
      update();
    } catch (e) {
      Get.log('error: $e');
    } finally {
      update();
    }
  }


    Future<void> preCacheVideoThumbs() {
    for (final e in reelsService.videosData.value) {
      ReelData video = e;
      try {
        Get.log("Cache preCacheVideos Errors ${video.thumbnail}");
        CustomCacheManager.instance.downloadFile(video.thumbnail ?? '');
      } on HttpException catch (e) {
        Get.log("Cache preCacheVideos Errors $e");
      }
    }

    return Future.value();
  }


  jumpToCurrentVideo() {
    print("jumpToCurrentVideo ${reelsService.pageIndex.value}");
    pageViewController.value = PageController(initialPage: reelsService.pageIndex.value);
    pageViewController.refresh();
  }


}
