import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/screens/properties/add_edit_property.dart';
import 'package:homy/screens/reels_screen/your_reels.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import '../../common/widgets/primary_header.dart';
import '../../common/widgets/top_bar_header.dart';
import '../../common/widgets/user_image_custom.dart';
import '../../common/widgets/verified_icon_custom.dart';
import '../../models/users/fetch_user.dart';
import '../../utils/my_text_style.dart';
import '../dashboard/widgets/header_card.dart';
import '../reels_screen/reels_screen.dart';
import '../reels_screen/widgets/reel_grid_card_widget.dart';
import 'controllers/profile_controller.dart';
import '../properties/widgets/become_agent_dialog.dart';
import '../profile/widgets/tour_requests_section.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: GetBuilder<ProfileController>(
            init: ProfileController(),
            builder: (controller) {
              UserData? user = controller.user?.value;
              return Scaffold(
                body: Column(
                  children: [
                    MPrimaryHeader(
                      bgColor: context.theme.colorScheme.primary,
                      child: Column(
                        children: [
                          TopBarHeader(
                              title: 'Profile',
                              isBtnVisible: true,
                              onTap: () {
                                Get.toNamed('/settings');
                              }),
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          UserImageCustom(
                                            image: user?.avatar ?? '',
                                            name: user?.fullname ?? '',
                                            widthHeight: 90,
                                            borderColor: context
                                                .theme.colorScheme.onPrimary,
                                          ),
                                          const SizedBox(width: 30),
                                          FollowFollowersItem(
                                            count: '${user?.followers ?? 0}',
                                            label: 'Followers',
                                            onTap: () {
                                              if (!AuthHelper.isLoggedIn()) {
                                                controller.showLoginmodal();
                                                return;
                                              }

                                              // controller.onNavigateUserList(0, user),
                                              Get.toNamed(
                                                  '/followers/${user?.id??0}',
                                                  arguments: {
                                                    'type': 0,
                                                    'id': user?.id ?? '1'
                                                  });
                                            },
                                          ),
                                          FollowFollowersItem(
                                            count: '${user?.following ?? 0}',
                                            label: 'Following',
                                            onTap: () {
                                              if (!AuthHelper.isLoggedIn()) {
                                                controller.showLoginmodal();
                                                return;
                                              }

                                              // controller.onNavigateUserList(0, user),
                                              Get.toNamed(
                                                  '/following/${user?.id??0}',
                                                  arguments: {
                                                    'type': 1,
                                                    'id': user?.id ?? '1'
                                                  });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            user?.fullname ?? 'Guest',
                                            style: MyTextStyle.productMedium(
                                                    size: 26,
                                                    color: context.theme
                                                        .colorScheme.onPrimary)
                                                .copyWith(
                                                    fontFamily: 'bold',
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          VerifiedIconCustom(
                                              isWhiteIcon: true,
                                              userData: user),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 7),
                                            decoration: BoxDecoration(
                                                color: context
                                                    .theme.colorScheme.onPrimary
                                                    .withOpacity(0.20),
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Text(
                                              '${user?.role?.toCapitalized() ?? 'Vistor'}',
                                              style: MyTextStyle.productRegular(
                                                  size: 15,
                                                  color: context.theme
                                                      .colorScheme.onPrimary),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        user?.email ?? 'guest@gmail.com',
                                        style: MyTextStyle.productLight(
                                            color: context
                                                .theme.colorScheme.onPrimary,
                                            size: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: user?.address != null,
                                  child: Container(
                                    color: context.theme.colorScheme.background
                                        .withOpacity(0.10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.fmd_good_rounded,
                                          color: context
                                              .theme.colorScheme.onPrimary,
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          user?.address ?? '',
                                          style: MyTextStyle.productLight(
                                              color: context
                                                  .theme.colorScheme.onPrimary,
                                              size: 15),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // DashboardTopBar(
                    //     title: S.of(context).profile,
                    //     isBtnVisible: true,
                    //     onTap: controller.onNavigateOptionScreen),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                   
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    //   child: TextButtonCustom(
                                    //       onTap: controller.onNavigateAddProperty,
                                    //       title: S.of(context).addProperty,
                                    //       bgColor: Get.theme.colorScheme.primary),
                                    // ),
                                    
                                    // if ((user?.yourReels ?? []).isNotEmpty)
                                      // RowTowText(
                                      //   title: 'Your Reels',
                                      //   onTap: () {
                                      //     // Get.to(() => YourReelsScreen(
                                      //     //       userId: controller.userData?.id,
                                      //     //       onUpdateReel:
                                      //     //           controller.onUpdateReelsList,
                                      //     //       reelType: ReelType.userReel,
                                      //     //       reels: user?.yourReels ?? [],
                                      //     //     ));
                                      //   },
                                      //   isShowAllVisible:
                                      //       (user?.yourReels?.length ?? 0) > 3,
                                      // ),


                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    //   child: TextButtonCustom(
                                    //     onTap: controller.onNavigateCameraScreen,
                                    //     title: S.of(context).addReel,
                                    //     bgColor: ColorRes.white,
                                    //     border: Border.all(color: ColorRes.royalBlue, width: 2),
                                    //     titleColor: ColorRes.royalBlue,
                                    //   ),
                                    // ),
                                    if(!AuthHelper.isLoggedIn() || user?.role == 'agent')...[  


                                       TitleHeader(
                                      onSeeAll: () {
                                        Get.toNamed('/my-properties/all',
                                            arguments: {'type': 0});
                                      },
                                      title: "Your Properties",
                                    ),

                                    RowTwoCard(
                                      value1: '${user?.forRentProperty ?? 0}',
                                      title1: 'For Rent',
                                      value2: '${user?.forSaleProperty ?? 0}',
                                      title2: 'For Sale',
                                      onTap1: () {
                                        Get.toNamed('/my-properties/rent',
                                            arguments: {'type': 1});
                                      },
                                      onTap2: () {
                                        Get.toNamed('/my-properties/sale',
                                            arguments: {'type': 2});
                                      },
                                    ),

                                    TitleHeader(
                                      onSeeAll: () {
                                        Get.toNamed('/tour-requests/received/upcoming');
                                      },
                                      title: "Tour Requests Received",
                                    ),

                                    RowTwoCard(
                                      value1:
                                          '${user?.waitingTourRecivedRequest ?? 0}',
                                      title1: 'Waiting',
                                      value2:
                                          '${user?.upcomingTourRecivedRequest ?? 0}',
                                      title2: 'Upcoming',
                                      onTap1: () {
                                        Get.toNamed(
                                            '/tour-requests/received/waiting');

                                        // controller.onNavigateTourScreen(0, 0);
                                      },
                                      onTap2: () {
                                        Get.toNamed(
                                            '/tour-requests/received/upcoming');

                                        // controller.onNavigateTourScreen(0, 1);
                                      },
                                    ),
                                    ],
                                    TitleHeader(
                                      onSeeAll: () {
                                         Get.toNamed(
                                            '/tour-requests/sent/all');
                                      },
                                      title: "Tour Requests Submitted",
                                    ),

                                    RowTwoCard(
                                      value1:
                                          '${user?.waitingTourSubmittedRequest ?? 0}',
                                      title1: 'Waiting',
                                      value2:
                                          '${user?.upcomingTourSubmittedRequest ?? 0}',
                                      title2: 'Upcoming',
                                      onTap1: () {
                                        // Get.to(() => TourRequestsScreen(type: 1, selectedTab: 0));
                                        Get.toNamed(
                                            '/tour-requests/sent/waiting');
                                      },
                                      onTap2: () {
                                        Get.toNamed(
                                            '/tour-requests/sent/upcoming');
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // if ((user?.yourReels ?? []).isNotEmpty)
                                //   RowTowText(
                                //     title: 'Your Reels',
                                //     onTap: () {
                                //       // Get.to(() => YourReelsScreen(
                                //       //       userId: controller.userData?.id,
                                //       //       onUpdateReel:
                                //       //           controller.onUpdateReelsList,
                                //       //       reelType: ReelType.userReel,
                                //       //       reels: user?.yourReels ?? [],
                                //       //     ));
                                //     },
                                //     isShowAllVisible:
                                //         (user?.yourReels?.length ?? 0) > 3,
                                //   ),

                                // const ReelsSection(reels: [], userId: ''),




                                    if ((user?.yourReels ?? []).isNotEmpty)...[
                                       TitleHeader(
                                      onSeeAll: () {
                                     Get.to(() => YourReelsScreen(
                                              
                                                reelType: ReelType.userReel,
                                                reels: user?.yourReels ?? [],
                                              ));
                                      },
                                      title: "Your Reels",
                                      enableShowAll: (user?.yourReels?.length ?? 0) > 3,
                                    ),
                                      SizedBox(
                                        height: 180,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.only(left: 15),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: user?.yourReels?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            return ReelGridCardWidget(
                                              onTap: () {
                                                Get.to(
                                                  () => ReelsScreen(
                                                    screenType:
                                                        ScreenTypeIndex.user,
                                                    reels: user?.yourReels ?? [],
                                                      // onUpdateReel: controller
                                                      //     .onUpdateReelsList,
                                                    position: index,
                                                    userID: user?.id,
                                                  ),
                                                  preventDuplicates: true,
                                                );
                                              },
                                              reelData: user?.yourReels?[index],
                                              onDeleteTap: (reel) => controller.onDeleteReel(reel),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                              ],
                            ),
                          ),
                          // if (controller.isLoading) CommonUI.loaderWidget()
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: CustomActionButton(
                  onTap: (index) {},
                ),
              );
            }));
  }
}

class CustomActionButtonold extends StatelessWidget {
  final Function(int index) onTap;

  const CustomActionButtonold({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Image.asset(
                      MImages.icReelsIcon,
                      color: context.theme.colorScheme.onSurface,
                      height: 24,
                      width: 24,
                    ),
                    title: Text(
                      'Add Reel',
                      style: MyTextStyle.productMedium(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      // onTap(1);
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      MImages.homeDashboardIcon,
                      color: context.theme.colorScheme.onSurface,
                      height: 24,
                      width: 24,
                    ),
                    title: Text(
                      'Add Property',
                      style: MyTextStyle.productMedium(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onTap(2);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      backgroundColor: context.theme.colorScheme.primary,
      child: Icon(Icons.add, color: context.theme.colorScheme.onPrimary),
    );
  }
}

class CustomActionButton extends GetView<ProfileController> {
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
            if (!AuthHelper.isLoggedIn()) {
              controller.showLoginmodal();
              return;
            }

            Get.toNamed('/reels-upload');
            // Get.put(ReelsUploadController());
            // Get.to(() => const ReelUploadScreen())?.then((value) {
            //   // fetchProfile();
            // }),
          },
          labelWidget:
              const LabelWidget(image: MImages.icReelsIcon, title: 'Add Reel'),
        ),
        SpeedDialChild(
          onTap: () {
            if (!AuthHelper.isLoggedIn()) {
              controller.showLoginmodal();
              return;
            }

            // Check if user is an agent
            if (controller.user?.value?.role != 'agent') {
              Get.dialog(
                const BecomeAgentDialog(),
                barrierDismissible: true,
                barrierColor: Colors.black54,
              );
              return;
            }

            Get.to(() => const AddEditPropertyScreen(screenType: 0))
                ?.then((value) {
              // fetchProfile();
            });
          },
          labelWidget: const LabelWidget(
              image: MImages.homeDashboardIcon, title: 'Add Property'),
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

class RowTowText extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isShowAllVisible;

  const RowTowText(
      {super.key,
      required this.title,
      required this.onTap,
      this.isShowAllVisible = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: MyTextStyle.productMedium(size: 16),
          ),
          const Spacer(),
          if (isShowAllVisible)
            InkWell(
              onTap: onTap,
              child: Text(
                'Show All',
                style: MyTextStyle.productLight(
                    size: 15, color: context.theme.colorScheme.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

class RowTwoCard extends StatelessWidget {
  final String value1;
  final String title1;
  final String value2;
  final String title2;
  final VoidCallback onTap1;
  final VoidCallback onTap2;

  const RowTwoCard(
      {super.key,
      required this.value1,
      required this.title1,
      required this.value2,
      required this.title2,
      required this.onTap1,
      required this.onTap2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap1,
              child: ProfileCard(
                value: value1,
                title: title1,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: InkWell(
              onTap: onTap2,
              child: ProfileCard(
                value: value2,
                title: title2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String value;
  final String title;

  const ProfileCard({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        border:
            Border.all(color: context.theme.colorScheme.outline, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: MyTextStyle.productMedium(
                    size: 30, color: context.theme.colorScheme.primary)
                .copyWith(fontFamily: 'bold', fontWeight: FontWeight.w500),
          ),
          Text(
            title,
            style: MyTextStyle.productLight(
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyReelsCard extends StatelessWidget {
  const EmptyReelsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.background.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        'No Reels Uploaded',
        style: MyTextStyle.productLight(
            size: 16, color: context.theme.colorScheme.onPrimary),
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
              style: MyTextStyle.productMedium(
                      size: 26, color: context.theme.colorScheme.onPrimary)
                  .copyWith(fontFamily: 'bold', fontWeight: FontWeight.w500),
            ),
            Text(
              label,
              style: MyTextStyle.productMedium(
                      size: 16, color: context.theme.colorScheme.onPrimary)
                  .copyWith(fontFamily: 'bold', fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
