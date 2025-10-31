import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/widgets/verified_icon_custom.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/extentions/lib/adaptive_type.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/utils/user_image_custom.dart';


class EnquireProfileCard extends StatelessWidget {
  final UserData? userData;
  final bool isBlock;
  final EnquireInfoScreenController controller;

  const EnquireProfileCard({super.key, this.userData, required this.isBlock, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Get.theme.colorScheme.primary,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            width: double.infinity,
            // color: Get.theme.colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserImageCustom(
                      image: userData?.avatar ?? '',
                      name: userData?.fullname ?? '',
                      widthHeight: 90,
                      borderColor: Get.theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 30),
                    FollowFollowersItem(
                      count: (userData?.followers ?? 0).numberFormat,
                      label: 'Followers',
                      onTap: () {
                        Get.toNamed('/followers/${userData?.id??0}', arguments: {'type': 0, 'id': userData?.id.toString()},preventDuplicates: false);
                          // Get.to(
                          //     () => FollowersFollowingScreen(
                          //           followFollowingType: FollowFollowingType.followers,
                          //           userId: userData?.id,
                          //         ),
                          //     preventDuplicates: true);
                        },
                    ),
                    FollowFollowersItem(
                      count: (userData?.following ?? 0).numberFormat,
                      label: 'Following',
                      onTap: () {
                        Get.toNamed('/following/${userData?.id??0}', arguments: {'type': 1, 'id': userData?.id.toString()});
                        // Get.to(
                        //     () => FollowersFollowingScreen(
                        //           followFollowingType: FollowFollowingType.following,
                        //           userId: userData?.id,
                        //         ),
                        //     preventDuplicates: true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        userData?.fullname ?? '',
                        style: MyTextStyle.productMedium(size: 26, color: Get.theme.colorScheme.onPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    VerifiedIconCustom(isWhiteIcon: true, userData: userData),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                      decoration: BoxDecoration(
                          color: Get.theme.colorScheme.onPrimary.withOpacity(0.20), borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        '${userData?.role?.toCapitalized() ?? 'User'}',
                        style: MyTextStyle.productRegular(size: 15, color: Get.theme.colorScheme.onPrimary),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  HelperUtils.maskSensitiveInfo(userData?.email ?? '', isEmail: true),
                  style: MyTextStyle.productLight(color: Get.theme.colorScheme.onPrimary, size: 16),
                ),

                const SizedBox(height: 10),
                if (userData?.id != AuthHelper.getUserId())
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: controller.onFollowUnfollowTap,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: userData?.followingStatus == 2 || userData?.followingStatus == 3
                                  ? Get.theme.colorScheme.onPrimary.withOpacity(.2)
                                  : Get.theme.colorScheme.onPrimary,
                              border: userData?.followingStatus == 2 || userData?.followingStatus == 3
                                  ? Border.all(color: Get.theme.colorScheme.onPrimary.withOpacity(.2))
                                  : null,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              userData?.followingStatus == 2 || userData?.followingStatus == 3
                                  ? 'Following'
                                  : 'Follow',
                              style: MyTextStyle.productMedium(
                                  size: 18,
                                  color: userData?.followingStatus == 2 || userData?.followingStatus == 3
                                      ? Get.theme.colorScheme.onPrimary
                                      : Get.theme.colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.onNavigateChat(userData),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30), border: Border.all(color: Get.theme.colorScheme.onPrimary)),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(MImages.chatIcon, color: Get.theme.colorScheme.onPrimary, height: 16, width: 16),
                                const SizedBox(width: 10),
                                Text('Chat',
                                    style: MyTextStyle.productMedium(size: 18, color: Get.theme.colorScheme.onPrimary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: userData?.address != null,
            child: Container(
              color: Get.theme.colorScheme.onPrimary.withOpacity(0.10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                   Icon(
                    Icons.fmd_good_rounded,
                    color: Get.theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      userData?.address ?? '',
                      style: MyTextStyle.productLight(color: Get.theme.colorScheme.onPrimary, size: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FollowFollowersItem extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback onTap;

  const FollowFollowersItem({
    super.key,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              count,
              style: MyTextStyle.productMedium(size: 26, color: Get.theme.colorScheme.onPrimary),
            ),
            Text(
              label,
              style: MyTextStyle.productMedium(size: 16, color: Get.theme.colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
