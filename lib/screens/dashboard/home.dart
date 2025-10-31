import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
  import 'package:homy/screens/dashboard/widgets/home_search.dart';
import 'package:homy/screens/dashboard/widgets/location_widgets.dart';
  import 'package:homy/screens/dashboard/widgets/recent_properties.dart';
import 'package:homy/screens/dashboard/widgets/slider_widgets.dart';
  import 'package:homy/screens/dashboard/widgets/catergories.dart';
import 'package:homy/screens/dashboard/widgets/nearby_properties.dart';
import 'package:homy/screens/dashboard/widgets/featured_properties.dart';
import 'package:homy/screens/dashboard/widgets/most_liked_properties.dart';
import 'package:homy/screens/dashboard/widgets/popular_city_properties.dart';
 import 'package:homy/screens/dashboard/widgets/featured_agents.dart';
import 'package:homy/screens/dashboard/widgets/all_properties_list.dart';
import 'package:homy/screens/dashboard/widgets/personalized_properties.dart';
import 'package:homy/services/notifications/shared_notification_service.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: context.theme.colorScheme.tertiary,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async {
          // Add your refresh logic here


          controller.nearByProperties.clear();
          controller.allProperties.clear();
          controller.featuredProperties.clear();
          controller.recentlyAddedProperties.clear();
          controller.mostLikedProperties.clear();
          controller.nearByProperties.clear();
          controller.personalizedProperties.clear();

          controller.currentPage = 1;
          controller.currentNearbyPage = 1;
          controller.currentRecentPage = 1;
          // controller.currentFeaturedPage = 1;
          // controller.currentPopularCityPage = 1;
          // controller.currentFeaturedAgentsPage = 1;


          controller.isLoadingAllProperties = false;
          controller.isLoadingNearbyProperties = false;
          controller.isLoadingFeaturedProperties = false;
          controller.isLoadingRecentProperties = false;
          controller.isLoadingPopularCity = false;
          controller.isLoadingFeaturedAgents = false;
          controller.isLoadingPersonalizedProperties = false;

          await Future.delayed(const Duration(seconds: 2));
          controller.fetchAllProperties();
          controller.fetchNearByProperties();
          controller.fetchFeaturedProperties();
          controller.fetchRecentlyAddedProperties();
          controller.fetchPopularCity();
          controller.fetchFeaturedAgents();
          controller.fetchPersonalizedProperties();
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10),
              child: LocationWidget()
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the notification page
                    Get.toNamed('/notifications');
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(
                        //   color: Colors.grey.shade300,
                        //   width: 1,
                        // ),
                      ),
                      child: const Icon(HugeIcons.strokeRoundedNotification03, size: 24),
                    ),
                   Obx( () {
                     final sharedService = Get.find<SharedNotificationService>();
                     return sharedService.unreadCount > 0 ? Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${sharedService.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                     ) : const SizedBox.shrink();
                   }),
                  ],
                ),
              )),
            ],
            backgroundColor: Colors.transparent,
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: SingleChildScrollView(
            controller: controller.allPropertiesScrollController,
            physics: const BouncingScrollPhysics(),
            // padding: EdgeInsets.symmetric(
            //   vertical: MediaQuery.of(context).padding.top,
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // HomeTopView(
                //  onTap: controller.getCityName,
                //   address: controller.selectedCity,
                //   onResetCityBtn: controller.onResetCityBtn,
                //   isResetBtnVisible: controller.isResetBtnVisible,
                // ),
                const SizedBox(height: 10),
                 HomeSearchField(),
                const SliderWidget(),
                 CategoryWidget(),
                 const PersonalizedPropertyWidget(),
                 NearbyPropertiesWidget(),
                

                const FeaturedPropertiesWidget(),
                // const PersonalizedPropertyWidget(),
                const RecentPropertiesSectionWidget(),
                const MostLikedPropertiesWidget(),
                const PopularCityPropertiesWidget(),
                const FeaturedAgentsWidget(),
                const AllPropertiesListWidget(),


                ...List.generate(
                  4,
                  (index) => const SizedBox(),  // Placeholder for your content
                ), 
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

