import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/data/mock_property_data.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/repositories/saved_repository.dart';
import 'package:homy/screens/reels_screen/widgets/reel_helper.dart';

class SavedPropertyScreenController extends GetxController {
  List<PropertyData> savedPropertyData = [];
  ScrollController scrollController = ScrollController();
  bool isInApi = false;
  bool isLoading = false;
  int selectedTabIndex = 0;
  List<ReelData> reels = [];
  List<int> removeSavedId = [];
  bool hasMoreData = true;
final SavedRepository savedRepository = SavedRepository();


  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchApi();
  //   scrollToFetchData();
  // }
  
  @override
  void onReady() {
    fetchApi();
    scrollToFetchData();
    super.onReady();
  }

  void onTabChanged(int index) {
    if (selectedTabIndex == index) return;

    selectedTabIndex = index;
    hasMoreData = true;
    // reels = [];
    // savedPropertyData = [];
    scrollController = ScrollController();
    fetchApi();
    update();
  }


  fetchApi() {
    if (selectedTabIndex == 0) {
      fetchSavedPropertyApiCall();
    } else {
      fetchReels();
    }
  }

  void fetchSavedPropertyApiCall() async {
    if (!hasMoreData) return;
    isLoading = true;
    update();
    //  await Future.delayed(const Duration(seconds: 5));
   


final saved = await savedRepository.getSavedProperties();
savedPropertyData=saved;
 isLoading = false;
    update();
    // ApiService().call(
    //     url: UrlRes.fetchSavedProperties,
    //     param: {uUserId: PrefService.id.toString(), uStart: savedPropertyData.length, uLimit: cPaginationLimit},
    //     completion: (response) {
    //       FetchSavedProperty value = FetchSavedProperty.fromJson(response);
    //       if ((value.data?.length ?? 0) < int.parse(cPaginationLimit)) {
    //         hasMoreData = false;
    //       }
    //       savedPropertyData.addAll(value.data ?? []);
    //       isLoading = false;
    //       update();
    //     });
  }

  Future<void> fetchReels() async {
    if (!hasMoreData) return;
    isLoading = true;
    update();
    reels = await savedRepository.getSavedReels();
    isLoading = false;
    update();
    // ApiService().call(
    //   completion: (response) {
    //     FetchReels fetchReel = FetchReels.fromJson(response);
    //     if ((fetchReel.data?.length ?? 0) < int.parse(cPaginationLimit)) {
    //       hasMoreData = false;
    //     }
    //     fetchReel.data?.forEach((element) {
    //       reels.add(element);
    //     });
    //     isLoading = false;
    //     update();
    //   },
    //   url: UrlRes.fetchSavedReels,
    //   param: {
    //     uUserId: PrefService.id,
    //     uStart: reels.length,
    //     uLimit: cPaginationLimit,
    //   },
    // );
  }

  void scrollToFetchData() {
    scrollController.addListener(() {
      if (scrollController.offset >= scrollController.position.maxScrollExtent) {
        if (!isInApi) {
          fetchApi();
        }
      }
    });
  }

  void onRemoveSavedList() {
    for (var id in removeSavedId) {
      reels.removeWhere((element) => element.id == id);
      update();
    }
  }

  void onUpdateReelsList(ReelUpdateType type, ReelData data) {
    if (data.isSaved == 0) {
      removeSavedId.add(data.id ?? -1);
    } else {
      removeSavedId.remove(data.id ?? -1);
    }
    // ReelUpdater.updateReelsList(reelsList: reels, type: type, data: data);
    update(); // Refresh the UI
  }
}
