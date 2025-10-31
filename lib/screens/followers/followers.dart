import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/screens/followers/controllers/followers_controller.dart';
import 'package:homy/utils/extentions/extentions.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/utils/user_image_custom.dart';
import '../../common/ui.dart';
import 'package:homy/screens/followers/widgets/followers_shimmer.dart';

enum FollowFollowingType { followers, following }

class FollowersFollowingScreen extends StatelessWidget {
  final FollowFollowingType followFollowingType;
  final int? userId;

  const FollowersFollowingScreen({
    super.key,
    required this.followFollowingType,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = FollowersFollowingScreenController(followFollowingType, userId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, controller),
      body: Obx(() => _buildBody(context, controller)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, FollowersFollowingScreenController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      title: Obx(() => controller.isSearching.value
        ? _buildSearchField(controller)
        : _buildTitleSection(controller)
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => controller.onFilterTap(),
        ),
        IconButton(
          icon: Icon(controller.isSearching.value ? Icons.close : Icons.search),
          onPressed: () => controller.onSearchTap(),
        ),
      ],
    );
  }

  Widget _buildSearchField(FollowersFollowingScreenController controller) {
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search by name or email',
        border: InputBorder.none,
        hintStyle: MyTextStyle.productLight(size: 16, color: Colors.grey),
      ),
      style: MyTextStyle.productMedium(size: 16),
      onChanged: controller.onSearchChanged,
    );
  }

  Widget _buildTitleSection(FollowersFollowingScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          followFollowingType == FollowFollowingType.followers ? 'Followers' : 'Following',
          style: MyTextStyle.productBold(size: 24),
        ),
        Obx(() {
          final count = controller.filteredList.length;
          final filterText = controller.selectedFilter.value != 'All' 
            ? ' (${controller.selectedFilter.value})'
            : '';                                                                                                                                                                 
          return Text(
            '$count ${followFollowingType == FollowFollowingType.followers ? 'followers' : 'following'}$filterText',
            style: MyTextStyle.productLight(size: 14, color: Colors.grey),
          );
        }),
      ],
    );
  }

  Widget _buildBody(BuildContext context, FollowersFollowingScreenController controller) {
    if (controller.isLoading.value) {
      return const FollowersShimmer();
    }

    if (controller.userList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.filteredList.length,
        itemBuilder: (context, index) => _buildUserCard(
          context, 
          controller.filteredList[index], 
          controller
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonUI.noDataFound(width: 120, height: 120
          ,title: followFollowingType == FollowFollowingType.followers
                ? 'No followers yet'
                : 'Not following anyone',
          subTitle: 'Explore users to follow',
          ),
          const SizedBox(height: 16),
          
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text(
              'Explore Users',
              style: MyTextStyle.productMedium(size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserData user, FollowersFollowingScreenController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.onNavigateUserProfile(user),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'profile_${user.id ?? ""}',
                child: UserImageCustom(
                  image: (user.avatar ?? ''),
                  name: user.fullname ?? '',
                  widthHeight: 50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.fullname ?? 'Unknown User',
                                  style: MyTextStyle.productMedium(size: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (user.isVerified ?? false) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Get.theme.primaryColor,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _getUserType(user.userType),
                            style: MyTextStyle.productMedium(
                              color: Get.theme.primaryColor,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            HelperUtils.maskSensitiveInfo(user.email ?? 'No email', isEmail: true),
                            style: MyTextStyle.productLight(
                              size: 14,
                              color: Get.theme.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (followFollowingType == FollowFollowingType.following)
                          _buildActionButtons(user, controller),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(UserData user, FollowersFollowingScreenController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // IconButton(
        //   icon: const Icon(Icons.message_outlined, size: 20),
        //   onPressed: () => controller.onMessageTap(user),
        //   constraints: const BoxConstraints(minWidth: 40),
        //   padding: EdgeInsets.zero,
        // ),
        OutlinedButton(
          onPressed: () => controller.onUnfollowTap(user),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Get.theme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
          child: Text(
            'Unfollow',
            style: MyTextStyle.productMedium(
              color: Get.theme.primaryColor,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _getUserType(int? userType) {
    try {
      if(userType==null){
        return 'User';
      }
      else if(userType==0){
        return 'User';
      }
      else if(userType==1){
        return 'Agent';
      }
      else if(userType==2){
        return 'Broker';
      }
      else if(userType==3){
        return 'Agency';
      }
      return (userType ?? 0).getUserType;

    } catch (e) {
      return 'User';
    }
  }
}
