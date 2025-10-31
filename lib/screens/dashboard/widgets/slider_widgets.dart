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
    viewportFraction: 1.0,
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
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final nextIndex = (_bannerIndex.value + 1) % bannerSlides.length;
      _bannerIndex.value = nextIndex;
      
      if (_pageController.hasClients && mounted) {
        if (nextIndex == 0) {
          // When reaching the end, jump to the first page without animation
          _pageController.jumpToPage(0);
        } else {
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeIn,
          );
        }
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
