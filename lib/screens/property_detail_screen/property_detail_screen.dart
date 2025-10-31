import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/widgets/ads_widget.dart';

import 'package:homy/common/widgets/image_widget.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/screens/property_detail_screen/controllers/property_detail_controller.dart';
import 'package:homy/screens/property_detail_screen/widgets/contact_information.dart';
import 'package:homy/screens/property_detail_screen/widgets/details.dart';
import 'package:homy/screens/property_detail_screen/widgets/property_location.dart';
import 'package:homy/screens/property_detail_screen/widgets/property_shimmer.dart';
import 'package:homy/screens/property_detail_screen/widgets/utilities.dart';
import 'package:homy/screens/reels_screen/widgets/reel_helper.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';

class PropertyDetailScreen extends GetView<PropertyDetailScreenController> {
  final int propertyId;
  final Function(UserData? userData)? onUpdate;
  final Function(ReelUpdateType type, ReelData data)? onUpdateReel;

  PropertyDetailScreen({super.key, required this.propertyId, this.onUpdate, this.onUpdateReel});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
             if(!kIsWeb){
            await InterstitialAdsService.shared.showInterstitialAds();
          }
        }
      },
      child: Scaffold(
        floatingActionButton: GetBuilder<PropertyDetailScreenController>(
          builder: (c) {
            if (c.isLoading || c.propertyData?.user?.id == AuthHelper.getUserId()) return const SizedBox();
            return AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: c.isScrolledToBottom ? const Offset(0, 2) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: c.isScrolledToBottom ? 0.0 : 1.0,
                child: CustomActionButton(
                  onTap: (index) {},
                ),
                
                //  FloatingActionButton.extended(
                //   backgroundColor: context.theme.colorScheme.primary,
                //   onPressed: () => c.onMessageClick(0),
                //   icon: Icon(Icons.message_rounded, 
                //     color: context.theme.colorScheme.onPrimary),
                //   label: Text('Contact',
                //     style: MyTextStyle.productMedium(
                //       color: context.theme.colorScheme.onPrimary,
                //     ),
                //   ),
                // ),
              ),
            );
          }
        ),
        body: GetBuilder<PropertyDetailScreenController>(
          builder: (c) {
            if (c.isLoading) {
              return PropertyDetailShimmer();
            }

            PropertyData? propertyData = c.propertyData;
            return CustomScrollView(
              controller: c.scrollController,
              slivers: [
                // Modern app bar with hero image
                SliverAppBar(
                  expandedHeight: Get.height * 0.4,
                  pinned: true,
                  stretch: true,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  leading: _buildBackButton(context),
                  actions: [
                    _buildActionButtons(context, propertyData),
                  ],
                  title: _buildScrolledTitle(context, c, propertyData),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Hero Image
                        CommonFun.getMedia(
                          m: propertyData?.media ?? [], 
                          mediaId: 1
                        ).isNotEmpty
                        ? ImageWidget(
                            image: CommonFun.getMedia(
                              m: propertyData?.media ?? [], 
                              mediaId: 1
                            ),
                            height: Get.height,
                            width: double.infinity,
                            borderRadius: 0,
                          )
                        : Container(
                            height: Get.height,
                            width: double.infinity,
                            color: context.theme.scaffoldBackgroundColor,
                            child: Center(
                              child: Image.asset(
                                MImages.logo,
                                height: 100,
                                width: 100,
                                color: context.theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  context.theme.scaffoldBackgroundColor,
                                  context.theme.scaffoldBackgroundColor.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Image counter and view all
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Row(
                            children: [
                              _buildImageCounter(context, propertyData),
                              const SizedBox(width: 8),
                              _buildViewAllButton(context, c),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Property details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price and status
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${Constant.currencySymbol}${(propertyData?.firstPrice ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                    style: MyTextStyle.productBlack(
                                      size: 24,
                                    ).copyWith(
                                      color: context.theme.textTheme.bodyMedium!.color,
                                    ),
                                  ),
                                  if(propertyData?.period != '' && (propertyData?.period?.toLowerCase() == 'daily' || propertyData?.period?.toLowerCase() == 'weekly')) ...[
                                    TextSpan(
                                      text: ' / ${propertyData?.period}',
                                      style: MyTextStyle.productMedium(
                                        size: 12,
                                        color: context.theme.textTheme.bodyMedium!.color,
                                      ).copyWith(
                                        fontSize: 12,
                                        textBaseline: TextBaseline.alphabetic,
                                      ),
                                    ),
                                  ] else if(propertyData?.period != '') ...[
                                    TextSpan(
                                      text: ' / ${propertyData?.period}',
                                      style: MyTextStyle.productMedium(
                                        size: 16,
                                        color: context.theme.textTheme.bodyMedium!.color,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('FOR ${propertyData?.propertyType?.toUpperCase()}',
                                style: MyTextStyle.productMedium(
                                  size: 12,
                                  color: context.theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Title and address
                        Text(
                          propertyData?.title ?? '',
                          style: MyTextStyle.productBlack(size: 20),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          propertyData?.address ?? '',
                          style: MyTextStyle.productLight(
                            size: 15,
                            color: context.theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Property features
                        _buildPropertyFeatures(context, propertyData),

                       

                        if ((propertyData?.about ?? '').isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildAboutSection(context, propertyData),
                        ],

                        const SizedBox(height: 24),
                        
                         if (propertyData != null)
                          const BannerAdsWidget(),
                        // Other sections
                        if (c.propertyData != null) ...[
                          PropertyLocation(),
                          Utilities(),
                          Details(),
                          ContactInformation(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          CupertinoIcons.back,
          color: context.theme.colorScheme.onSurface,
        ),

        onPressed: () async {
             Get.back();
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PropertyData? propertyData) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              propertyData?.savedProperty == true
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              color: context.theme.colorScheme.onSurface,
            ),
            onPressed: () => Get.find<PropertyDetailScreenController>()
                .onPropertySaved(propertyData),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: context.theme.colorScheme.onSurface,
            ),
            onPressed: () => Get.find<PropertyDetailScreenController>()
                .shareProperty(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCounter(BuildContext context, PropertyData? propertyData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '1/${CommonFun.mediaLength(propertyData?.media ?? [])}',
        style: MyTextStyle.productRegular(
          size: 13,
          color: context.theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context, PropertyDetailScreenController c) {
    return InkWell(
      onTap: () => c.onNavigateImageScreen(0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(
              MImages.imageIcon,
              color: context.theme.colorScheme.onSurface,
              width: 20,
              height: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'View All',
              style: MyTextStyle.productRegular(
                size: 13,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyFeatures(BuildContext context, PropertyData? propertyData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (propertyData?.bedrooms != 0)
            _buildFeatureItem(
              context,
              MImages.bedroomIcon,
              '${propertyData?.bedrooms} Beds',
            ),
          if (propertyData?.bathrooms != 0)
            _buildFeatureItem(
              context,
              MImages.bathIcon,
              '${propertyData?.bathrooms} Baths',
            ),
          _buildFeatureItem(
            context,
            MImages.sqftIcon,
            '${propertyData?.area} sqft',
          ),
                    // const BannerAdsWidget()

        ],
        
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String icon, String text) {
    return Column(
      children: [
        Image.asset(
          icon,
          height: 24,
          width: 24,
          color: context.theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: MyTextStyle.productLight(size: 14),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, PropertyData? propertyData) {
    final String aboutText = propertyData?.about ?? '';
    final bool isHtml = aboutText.contains(RegExp(r'<[^>]+>'));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: MyTextStyle.productBlack(size: 18),
        ),
        const SizedBox(height: 8),
        if (isHtml)
          HtmlWidget(
            aboutText,
            textStyle: MyTextStyle.productLight(
              size: 15,
              color: context.theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
            ),
            customStylesBuilder: (element) {
              if (element.localName == 'a') {
                return {
                  'color': context.theme.colorScheme.primary.value.toRadixString(16),
                  'text-decoration': 'none',
                };
              }
              if (element.localName == 'br') {
                return {
                  'margin': '8px 0',
                };
              }
              return null;
            },
            customWidgetBuilder: (element) {
              if (element.localName == 'br') {
                return const SizedBox(height: 8);
              }
              return null;
            },
            onTapUrl: (url) {
              if (url.startsWith('@')) {
                // Handle mention tap
                final username = url.substring(1);
                // You can add your mention handling logic here
                return true;
              }
              return false;
            },
          )
        else
          Text(
            aboutText,
            style: MyTextStyle.productLight(
              size: 15,
              color: context.theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildScrolledTitle(BuildContext context, PropertyDetailScreenController c, PropertyData? propertyData) {
    double threshold = c.maxExtent * 0.7;
    bool shouldShowTitle = c.currentExtent < threshold;
    
    return AnimatedOpacity(
      opacity: shouldShowTitle ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        propertyData?.title ?? '',
        style: MyTextStyle.productMedium(
          size: 18,
          color: context.theme.colorScheme.onBackground,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class RowIconWithText extends StatelessWidget {
  final String icon;
  final String title;
  final bool isVisible;
  final IconData? Icons;

  const RowIconWithText({super.key, required this.icon, required this.title, required this.isVisible, this.Icons});

  @override
  Widget build(BuildContext context) {
    return  Visibility(
        visible: isVisible,
        child: Row(
          children: [
            if (Icons != null) Icon(Icons, size: 20),
            Image.asset(
              icon,
              height: 20,
              width: 20,
              color: context.theme.textTheme.bodyMedium!.color!,
            ),
            SizedBox(width: 2),
            Text(
              '$title',
              style: MyTextStyle.productLight( size: 15),
            ),
          ],
        ),
      
    );
  }
}

class TopAreaImageCount extends StatelessWidget {
  final double opacity;
  final bool isImageVisible;
  final String title;

  const TopAreaImageCount({super.key, required this.opacity, this.isImageVisible = false, required this.title});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        height: 34,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface.withOpacity(0.3),
                  // borderRadius: isImageVisible
                  //     ? (const BorderRadius.only(
                  //         topRight: Radius.circular(30),
                  //         bottomRight: Radius.circular(
                  //           30,
                  //         ),
                  //       ))
                  //     : const BorderRadius.only(
                  //         topLeft: Radius.circular(30),
                  //         bottomLeft: Radius.circular(
                  //           30,
                  //         ),
                  //       ),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Visibility(
                      visible: isImageVisible,
                      child: Image.asset(
                        MImages.logo,
                        color: context.theme.colorScheme.onPrimary,
                        width: 25,
                        height: 20,
                      ),
                    ),
                    SizedBox(
                      width: isImageVisible ? 5 : 0,
                    ),
                    Text(
                      title,
                      style: MyTextStyle.productRegular(size: 13, color: context.theme.colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForSaleCard extends StatelessWidget {
  final PropertyData? data;

  const ForSaleCard({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary,
            borderRadius: CommonFun.getRadius(radius: 30, isRTL: Directionality.of(context) == TextDirection.rtl),
          ),
          alignment: Alignment.center,
          child: Text(
            (data?.propertyAvailableFor == 0 ? 'for sale' : 'for rent').toUpperCase(),
            style: MyTextStyle.productMedium(size: 12, color: context.theme.colorScheme.onPrimary),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: CommonFun.getRadius(
                radius: 30,
                isRTL: Directionality.of(context) != TextDirection.rtl,
              ),
              color: context.theme.colorScheme.surface,
              border: Border.all(color: context.theme.colorScheme.onPrimary, width: 0.5)),
          alignment: Alignment.center,
          child: Text(
            '${Constant.currencySymbol}${(data?.firstPrice ?? 0).toString()}${data?.propertyAvailableFor == 0 ? '' : Constant.monthly}',
            style: MyTextStyle.productBlack(
              size: 15,
            ),
          ),
        ),
      ],
    );
  }
}


class CustomActionButton extends GetView<PropertyDetailScreenController> {
  final Function(int index) onTap;

  const CustomActionButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      // overlayColor: context.theme.colorScheme.primary,
      backgroundColor: context.theme.colorScheme.primary,
      activeIcon: Icons.clear,
      children: [
        SpeedDialChild(
          onTap: () {
                     controller.onNavigateScheduledScreen();

          },
          labelWidget:
              const LabelWidget(image: MImages.calendarIcon, title: 'Schedule Tour'),
        ),
        SpeedDialChild(
          onTap: () {
           controller.onMessageClick(0);
            // Get.to(() => const AddEditPropertyScreen(screenType: 0))
            //     ?.then((value) {
            //   // fetchProfile();
            // });
          },
          labelWidget: const LabelWidget(
              image: MImages.messageIcon, title: 'Contact Agent'),
        ),
      ],
    );
  }
}

class LabelWidget extends StatelessWidget {
  final String image;
  final String title;

  const LabelWidget({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            image,
            color: context.theme.colorScheme.onPrimary,
            height: 20,
            width: 20,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: MyTextStyle.productMedium(
                color: context.theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

