import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/verified_icon_custom.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/utils/user_image_custom.dart';

class ProfileHeader extends StatelessWidget {
  final UserData? userData;
  final VoidCallback onSettingsTap;

  const ProfileHeader({
    super.key,
    required this.userData,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.colorScheme.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            _buildUserInfo(context),
            if (userData?.address != null) _buildAddressBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Profile',
            style: MyTextStyle.productBold(
              size: 24,
              color: context.theme.colorScheme.onPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: context.theme.colorScheme.onPrimary,
            ),
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              UserImageCustom(
                image: userData?.avatar ?? '',
                name: userData?.fullname ?? '',
                widthHeight: 90,
                borderColor: context.theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('Followers', '${userData?.followers ?? 0}'),
                    _buildStat('Following', '${userData?.following ?? 0}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUserDetails(context),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: MyTextStyle.productBold(
            size: 24,
            color: Get.theme.colorScheme.onPrimary,
          ),
        ),
        Text(
          label,
          style: MyTextStyle.productMedium(
            size: 14,
            color: Get.theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              userData?.fullname ?? 'Guest',
              style: MyTextStyle.productBold(
                size: 20,
                color: context.theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            VerifiedIconCustom(
              isWhiteIcon: true,
              userData: userData,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          userData?.email ?? 'guest@gmail.com',
          style: MyTextStyle.productRegular(
            size: 14,
            color: context.theme.colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressBar(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.primary.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: context.theme.colorScheme.onPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              userData?.address ?? '',
              style: MyTextStyle.productRegular(
                size: 14,
                color: context.theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 