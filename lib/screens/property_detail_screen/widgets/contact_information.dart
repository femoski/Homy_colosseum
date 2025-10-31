import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/widgets/verified_icon_custom.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/property_detail_screen/controllers/property_detail_controller.dart';
import 'package:homy/screens/property_detail_screen/widgets/property_header.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/utils/user_image_custom.dart';

import '../../../models/users/fetch_user.dart';


class ContactInformation extends GetView<PropertyDetailScreenController> {
  // final PropertyDetailScreenController controller;

  // const ContactInformation({super.key, required this.controller});

  final AuthService authService= Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    PropertyData? data = controller.propertyData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PropertyHeading(title: 'Contact Information'),
        PropertyProfileCard(
          userData: data?.user,
          onTap: () => controller.onNavigateUserProfile(data),
          onMessageClick: () => controller.onMessageClick(1),
        ),
        const SizedBox(height: 10),

        ContactListTiles(
          title: 'Enquire Info',
          onTap: () => controller.onMessageClick(0),
          isVisible: authService.user.value.id != data?.user?.id,
        ),
        ContactListTiles(
          isVisible: CommonFun.getMedia(m: data?.media ?? [], mediaId: 7).isNotEmpty,
          title: 'Watch Video',
          onTap: controller.onNavigateVideoScreen,
        ),
        ContactListTiles(
          isVisible: CommonFun.getMedia(m: data?.media ?? [], mediaId: 4).isNotEmpty,
          title: 'Floor Plans',
          onTap: controller.onNavigateFloorPlan,
        ),
        ContactListTiles(
          isVisible: authService.user.value.id != data?.user?.id,
          title: 'Schedule Tour',
          onTap: controller.onNavigateScheduledScreen,
        ),
      ],
    ));
  }
}

class PropertyProfileCard extends StatelessWidget {
  final UserData? userData;
  final VoidCallback onTap;
  final VoidCallback onMessageClick;

  const PropertyProfileCard({super.key, this.userData, required this.onTap, required this.onMessageClick});
  @override
  Widget build(BuildContext context) {
    final AuthService authService= Get.find<AuthService>();
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      //   borderRadius: BorderRadius.circular(16),
      //   side: BorderSide(
      //     color: context.theme.colorScheme.outline.withOpacity(0.1),
      //     width: 1,
      //   ),
      // ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: userData?.fullname ?? '',
                child: UserImageCustom(
                  image: userData?.avatar ?? '',
                  name: userData?.fullname ?? '',
                  widthHeight: 65,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userData?.fullname ?? '',
                            style: MyTextStyle.productMedium(
                              size: 18,
                              color: context.theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        VerifiedIconCustom(userData: userData)
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Property Agent',  // Or dynamic role
                      style: MyTextStyle.productLight(
                        color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(authService.user.value.id != userData?.id)
                  _ActionButton(
                    onTap: onMessageClick,
                    icon: MImages.chatIcon,
                    isImage: true,
                  ),
                  const SizedBox(width: 8),
                  // if (userData?.mobileNo != null && userData!.mobileNo!.isNotEmpty)
                  //   _ActionButton(
                  //     onTap: () {
                  //       // launchUrl(Uri.parse('tel:${userData?.mobileNo}'));
                  //     },
                  //     icon: Icons.phone,
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final dynamic icon;
  final bool isImage;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    this.isImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: isImage
              ? Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                  color: context.theme.colorScheme.primary,
                )
              : Icon(
                  icon,
                  size: 20,
                  color: context.theme.colorScheme.primary,
                ),
        ),
      ),
    );
  }
}

class ContactListTiles extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isVisible;

  const ContactListTiles({super.key, required this.title, required this.onTap, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        //   borderRadius: BorderRadius.circular(12),
        //   side: BorderSide(
        //     color: context.theme.colorScheme.outline.withOpacity(0.1),
        //     width: 1,
        //   ),
        // ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _getIcon(title),
                    const SizedBox(width: 12),
                    Text(
                      title.capitalize ?? '',
                      style: MyTextStyle.productMedium(
                        size: 15,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Icon(
                  CupertinoIcons.right_chevron,
                  size: 16,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getIcon(String title) {
    IconData iconData;
    switch (title.toLowerCase()) {
      case 'enquire info':
        iconData = Icons.info_outline;
        break;
      case 'watch video':
        iconData = Icons.play_circle_outline;
        break;
      case 'floor plans':
        iconData = Icons.grid_view;
        break;
      case 'schedule tour':
        iconData = Icons.calendar_today;
        break;
      default:
        iconData = Icons.circle_outlined;
    }
    return Icon(
      iconData,
      size: 22,
      color: Get.theme.colorScheme.primary,
    );
  }
}
