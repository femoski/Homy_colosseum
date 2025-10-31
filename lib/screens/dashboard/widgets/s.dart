// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:homy/models/homeslider_model.dart';
// import 'package:homy/repositories/home_repository.dart';
// import 'package:homy/screens/dashboard/widgets/promoted_card.dart';
// import 'package:homy/utils/constants/sizes.dart';
// import 'package:homy/utils/responsiveSize.dart';
// import 'package:homy/utils/ui.dart';


// class SliderWidget extends StatefulWidget {
//   const SliderWidget({Key? key}) : super(key: key);

//   @override
//   State<SliderWidget> createState() => _SliderWidgetState();
// }

// class _SliderWidgetState extends State<SliderWidget>
//     with AutomaticKeepAliveClientMixin {
//   final ValueNotifier<int> _bannerIndex = ValueNotifier(0);
//   final homeRepository = HomeRepository();
//   List<HomeSlider> bannerSlides = [];
//   bool isLoading = true;
//   late Timer _timer;
//   final PageController _pageController = PageController(
//     initialPage: 0,
//   );
  
//   // AdMob related variables
//   BannerAd? _bannerAd;
//   bool _isAdLoaded = false;
//   static const String _adUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ad unit ID

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     loadSliders();
//     _loadAd();
//   }

//   void _loadAd() {
//     _bannerAd = BannerAd(
//       adUnitId: _adUnitId,
//       request: const AdRequest(),
//       size: AdSize.banner,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _isAdLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           _isAdLoaded = false;
//         },
//       ),
//     );
//     _bannerAd?.load();
//   }

//   void startAutoSlide() {
//     if (bannerSlides.length <= 1) return;
    
//     _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
//       if (!mounted) return;
      
//       final nextIndex = (_bannerIndex.value + 1) % (bannerSlides.length + (_isAdLoaded ? 1 : 0));
//       _bannerIndex.value = nextIndex;
      
//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           nextIndex,
//           duration: const Duration(milliseconds: 1000),
//           curve: Curves.easeIn,
//         );
//       }
//     });
//   }

//   Future<void> loadSliders() async {
//     try {
//       setState(() => isLoading = true);
//       bannerSlides = await homeRepository.getSliders();
//       if (mounted) {
//         setState(() => isLoading = false);
//         startAutoSlide();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//       // Handle error appropriately
//     }
//   }

//   @override
//   void dispose() {
//     _bannerIndex.dispose();
//     _timer.cancel();
//     _pageController.dispose();
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
    
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (bannerSlides.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       children: <Widget>[
//         SizedBox(height: 15.rh(context)),
//         SizedBox(
//           height: 130.rh(context),
//           child: Stack(
//             children: [
//               PageView.builder(
//                 controller: _pageController,
//                 clipBehavior: Clip.antiAlias,
//                 physics: const BouncingScrollPhysics(
//                   decelerationRate: ScrollDecelerationRate.fast,
//                 ),
//                 itemCount: bannerSlides.length + (_isAdLoaded ? 1 : 0),
//                 onPageChanged: (index) {
//                   _bannerIndex.value = index;
//                 },
//                 itemBuilder: (context, index) {
//                   if (_isAdLoaded && index == bannerSlides.length) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
//                       child: AdWidget(ad: _bannerAd!),
//                     );
//                   }
//                   return _buildBanner(bannerSlides[index]);
//                 },
//               ),
//               Positioned(
//                 bottom: 10,
//                 left: 0,
//                 right: 0,
//                 child: ValueListenableBuilder<int>(
//                   valueListenable: _bannerIndex,
//                   builder: (context, value, child) {
//                     return pageindicator(
//                       index: value,
//                       length: bannerSlides.length + (_isAdLoaded ? 1 : 0),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBanner(HomeSlider banner) {
//     return GestureDetector(
//       onTap: () async {
//         // try {
//         //   PropertyRepository fetch = PropertyRepository();

//         //   Widgets.showLoader(context);

//         //   DataOutput<PropertyModel> dataOutput =
//         //       await fetch.fetchPropertyFromPropertyId(banner.propertysId);

//         //   Future.delayed(
//         //     Duration.zero,
//         //     () {
//         //       Widgets.hideLoder(context);
//         //       HelperUtils.goToNextPage(
//         //         Routes.propertyDetails,
//         //         context,
//         //         false,
//         //         args: {
//         //           'propertyData': dataOutput.modelList[0],
//         //           'propertiesList': dataOutput.modelList,
//         //           'fromMyProperty': false,
//         //         },
//         //       );
//         //     },
//         //   );
//         // } catch (e) {
//         //   Widgets.hideLoder(context);
//         //   HelperUtils.showSnackBarMessage(context,
//         //       UiUtils.getTranslatedLabel(context, "somethingWentWrng"));
//         // }
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
//         child: Stack(
//           clipBehavior: Clip.antiAlias,
//           children: [
//             Container(
//               clipBehavior: Clip.antiAlias,
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height * 0.3,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(11),
//                 border: Border.all(
//                   color: Colors.transparent,
//                 ),
//               ),
//               child: ClipRRect(
//                 clipBehavior: Clip.antiAlias,
//                 borderRadius: BorderRadius.circular(11),
//                 child: Ui.getImage(
//                   banner.media!.url,
//                   width: MediaQuery.of(context).size.width,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             PositionedDirectional(
//                 top: 10,
//                 start: 10,
//                 child: Visibility(
//                     visible: banner.promoted ?? false,
//                     child: const PromotedCard(type: PromoteCardType.icon)))
//           ],
//         ),
//       ),
//     );
//   }

  
//   Row pageindicator({required int index, required int length}) {
//     return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(length, (indexDots) {
//           return AnimatedContainer(
//               duration: const Duration(microseconds: 300),
//               margin: const EdgeInsets.symmetric(horizontal: 5),
//               width: index == indexDots ? 8 : 6,
//               height: index == indexDots ? 8 : 6,
//               decoration: BoxDecoration(
//                   color: index == indexDots
//                       ? context.theme.colorScheme.primary
//                       : Colors.transparent,
//                   borderRadius: const BorderRadius.all(Radius.circular(40)),
//                   border: Border.all(
//                       color: context.theme.colorScheme.primary, width: 1)));
//         }));
//   }
// }














import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/homeslider_model.dart';
import 'package:homy/repositories/home_repository.dart';
import 'package:homy/screens/dashboard/widgets/promoted_card.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/responsiveSize.dart';
import 'package:homy/utils/ui.dart';
import 'package:shimmer/shimmer.dart';


class SliderWidget extends StatefulWidget {
  const SliderWidget({Key? key}) : super(key: key);

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}
  List<HomeSlider> bannerSlides = [];

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _bannerIndex = ValueNotifier(0);
  final homeRepository = HomeRepository();
  bool isLoading = true;
  Timer? _timer;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (bannerSlides.isEmpty) {
      loadSliders();
    } else {
      isLoading = false;
      startAutoSlide();
    }
  }

  void startAutoSlide() {
    if (bannerSlides.length <= 1) return;
    
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final nextIndex = (_bannerIndex.value + 1) % bannerSlides.length;
      _bannerIndex.value = nextIndex;
      
      if (_pageController.hasClients && mounted) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> loadSliders() async {
    try {
      setState(() => isLoading = true);
      bannerSlides = await homeRepository.getSliders();
      if (mounted) {
        setState(() => isLoading = false);
        startAutoSlide();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      // Handle error appropriately
    }
  }

  @override
  void dispose() {
    _bannerIndex.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bannerSlides.isEmpty) {
      loadSliders();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (isLoading && bannerSlides.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 15.rh(context)),
          SizedBox(
            height: 130.rh(context),
            child: Shimmer.fromColors(
              baseColor: context.isDarkMode 
                ? Colors.grey[800]! 
                : Colors.grey[300]!,
              highlightColor: context.isDarkMode 
                ? Colors.grey[700]! 
                : Colors.grey[100]!,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (bannerSlides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        SizedBox(height: 15.rh(context)),
        SizedBox(
          height: 130.rh(context),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.antiAlias,
                physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast,
                ),
                itemCount: bannerSlides.length,
                onPageChanged: (index) {
                  if (mounted) {
                    _bannerIndex.value = index;
                  }
                },
                itemBuilder: (context, index) {
                  return _buildBanner(bannerSlides[index]);
                },
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<int>(
                  valueListenable: _bannerIndex,
                  builder: (context, value, child) {
                    return pageindicator(
                      index: value,
                      length: bannerSlides.length,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(HomeSlider banner) {
    return GestureDetector(
      onTap: () async {
        // try {
        //   PropertyRepository fetch = PropertyRepository();

        //   Widgets.showLoader(context);

        //   DataOutput<PropertyModel> dataOutput =
        //       await fetch.fetchPropertyFromPropertyId(banner.propertysId);

        //   Future.delayed(
        //     Duration.zero,
        //     () {
        //       Widgets.hideLoder(context);
        //       HelperUtils.goToNextPage(
        //         Routes.propertyDetails,
        //         context,
        //         false,
        //         args: {
        //           'propertyData': dataOutput.modelList[0],
        //           'propertiesList': dataOutput.modelList,
        //           'fromMyProperty': false,
        //         },
        //       );
        //     },
        //   );
        // } catch (e) {
        //   Widgets.hideLoder(context);
        //   HelperUtils.showSnackBarMessage(context,
        //       UiUtils.getTranslatedLabel(context, "somethingWentWrng"));
        // }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(11),
                child: Ui.getImage(
                  banner.media!.url,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            PositionedDirectional(
                top: 10,
                start: 10,
                child: Visibility(
                    visible: banner.promoted ?? false,
                    child: const PromotedCard(type: PromoteCardType.icon)))
          ],
        ),
      ),
    );
  }

  
  Row pageindicator({required int index, required int length}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(length, (indexDots) {
          return AnimatedContainer(
              duration: const Duration(microseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: index == indexDots ? 8 : 6,
              height: index == indexDots ? 8 : 6,
              decoration: BoxDecoration(
                  color: index == indexDots
                      ? context.theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  border: Border.all(
                      color: context.theme.colorScheme.primary, width: 1)));
        }));
  }
}
