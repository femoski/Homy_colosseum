import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/screens/settings/controllers/settings_controller.dart';
import 'package:homy/utils/my_text_style.dart';
import '../../screens/settings/widgets/language_selection_sheet.dart';
import '../../screens/settings/widgets/personalized_requirement_form.dart';
import 'package:homy/services/saved_requirement_service.dart';

class SettingsScreen extends StatelessWidget {
  final Function(int type, UserData? userData)? onUpdate;
  final UserData? userData;

  const SettingsScreen({super.key, this.onUpdate, this.userData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsScreenController(onUpdate));
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', 
          style: MyTextStyle.productLight(
            size: 20, 
            color: Get.theme.colorScheme.primary,
            // fontWeight: FontWeight.w600
          ),
        ),
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Get.theme.colorScheme.primary),
        //   onPressed: () => Get.back(),
        // ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: GetBuilder(
                init: controller,
                builder: (controller) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        GestureDetector(
                          onTap: () {
                            if(AuthHelper.isLoggedIn()){
                              Get.toNamed('/profile');
                            }else{
                              Get.toNamed('/login');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                if(!Get.isDarkMode)
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Get.theme.colorScheme.primary,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.user?.fullname ?? 'Homy User', // Replace with actual user name
                                       style: Get.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                                      ),
                                      Text(
                                        'View Profile',
                                            style: MyTextStyle.productLight(
                                              size: 14,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.forward,
                                  color: Get.theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Text(
                          'Preferences',
                          style: Get.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Get.theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Settings Cards
                        Container(
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if(!Get.isDarkMode)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Dark Mode Toggle
                            Obx(() =>  ModernSettingsTile(
                                icon: Icons.dark_mode_outlined,
                                title: 'Dark Mode',
                                trailing: Switch.adaptive(
                                  value: controller.isDarkMode.value,
                                  onChanged: (value) {
                                    controller.toggleTheme();
                                    controller.isDarkMode.value = value;
                                  },
                                ),
                              )),
                               
                              // // Notification Toggle
                              // ModernSettingsTile(
                              //   icon: CupertinoIcons.bell,
                              //   title: 'Push Notifications',
                              //   trailing: Switch.adaptive(
                              //     value: controller.notificationStatus == 1,
                              //     onChanged: (value) {
                              //       // controller.onNotificationTap();
                              //     },
                              //   ),
                              // ),

                                  ModernSettingsTile(
                                icon: Icons.home_outlined,
                                title: 'Property Preferences',
                                onTap: () {
                                  if(AuthHelper.isLoggedIn()){  
                                    Get.toNamed('/personalized-requirement');
                                  }else{
                                    Get.toNamed('/login');
                                  }
                                },
                              ),


     ModernSettingsTile(
                                icon: Icons.language_outlined,
                                title: 'Change Language',
                                onTap: () {
                                  Get.bottomSheet(
                                    const LanguageSelectionSheet(),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                              ),

                            ],
                          ),
                        ),

                        

                        const SizedBox(height: 24),
                        Text(
                          'Account',
                          style: Get.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Get.theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Account Settings
                        Container(
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if(!Get.isDarkMode)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [




                         if(Get.find<ConfigService>().config.value?.payments.getEnableSolanaPayments ?? false)
                            ...[
                                  ModernSettingsTile(
                                icon: Icons.token,
                                title: 'Connect Solana Wallet',
                                onTap: () {
                                  if(AuthHelper.isLoggedIn()){
                                    Get.toNamed('/wallet-connect');
                                  }else{
                                    Get.toNamed('/login');
                                  }
                                },
                              ),
                            ],

if(Get.find<ConfigService>().config.value?.payments.getEnablePropertyNft ?? false)
                            ...[
                            ModernSettingsTile(
                              icon: Icons.sell_outlined,
                              title: 'My NFTs',
                              onTap: () {
                                if(AuthHelper.isLoggedIn()){
                                  Get.toNamed('/my-nfts');
                                }else{
                                  Get.toNamed('/login');
                                }
                              },
                            ),
                            ],

                              ModernSettingsTile(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'My Wallet',
                                onTap: () {
                                  if(AuthHelper.isLoggedIn()){
                                    Get.toNamed('/wallet');
                                  }else{
                                    Get.toNamed('/login');
                                  }
                                },
                              ),

                                 ModernSettingsTile(
                                icon: Icons.stars_outlined,
                                title: 'Homy Point',
                                onTap: () {
                                  if(AuthHelper.isLoggedIn()){
                                    Get.toNamed('/points');
                                  }else{
                                    Get.toNamed('/login');
                                  }
                                },
                              ),

                          

                              // ModernSettingsTile(
                              //   icon: Icons.home_outlined,
                              //   title: 'My Property Requirements',
                              //   onTap: () {
                              //     Get.toNamed('/personalized-requirement');
                              //   },
                              //   trailing: Obx(() {
                              //     final requirementService = Get.find<SavedRequirementService>();
                              //     if (requirementService.hasRequirements) {
                              //       return Container(
                              //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              //         decoration: BoxDecoration(
                              //           color: Get.theme.colorScheme.primary,
                              //           borderRadius: BorderRadius.circular(12),
                              //         ),
                              //         child: Text(
                              //           'Set',
                              //           style: MyTextStyle.productRegular(
                              //             size: 12,
                              //             color: Get.theme.colorScheme.onPrimary,
                              //             fontWeight: FontWeight.w600,
                              //           ),
                              //         ),
                              //       );
                              //     }
                              //     return const SizedBox.shrink();
                              //   }),
                              // ),

                              ModernSettingsTile(
                                icon: Icons.lock_outline,
                                title: 'Change Password',
                                onTap: () {
                                  if(AuthHelper.isLoggedIn()){
                                    Get.toNamed('/change-password');
                                  }else{
                                    Get.toNamed('/login');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'Support',
                          style: Get.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Get.theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Support Settings
                        Container(
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if(!Get.isDarkMode)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ModernSettingsTile(
                              //   icon: Icons.help_outline,
                              //   title: 'FAQs',
                              //   onTap: () {
                              //     Get.toNamed('/html-page?page=faqs');
                              //   },
                              // ),
                              ModernSettingsTile(
                                icon: Icons.support_agent_outlined,
                                title: 'Support',
                                onTap: () {
                                  Get.toNamed('/support');
                                },
                              ),
                              ModernSettingsTile(
                                icon: Icons.description_outlined,
                                title: 'Terms of Use',
                                onTap: () {
                                  Get.toNamed('/html-page?page=terms-and-condition');
                                },
                              ),
                              ModernSettingsTile(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy Policy',
                                onTap: () {
                                  Get.toNamed('/html-page?page=privacy-policy');
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        
                        // Danger Zone
                        Container(
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if(!Get.isDarkMode)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if(AuthHelper.isLoggedIn())...[
                              ModernSettingsTile(
                                icon: Icons.logout,
                                title: 'Log Out',
                                iconColor: Colors.orange,
                                onTap: () {
                                  controller.onLogoutClick();
                                },
                              ),
                              ModernSettingsTile(
                                icon: Icons.delete_outline,
                                title: 'Delete Account',
                                iconColor: Colors.red,
                                onTap: () {
                                  controller.onDeleteAccountClick();
                                },
                              ),
                            ]else...[
                              ModernSettingsTile(
                                icon: Icons.login,
                                title: 'Login',
                                onTap: () {
                                  Get.toNamed('/login');
                                },
                                iconColor: Colors.orange,
                              ),
                            ]],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const ModernSettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Get.theme.colorScheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Get.theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: MyTextStyle.productLight(
                  size: 16,
                  // color: Get.theme.colorScheme.primary,
                ),
              ),
            ),
            trailing ?? Icon(
              CupertinoIcons.forward,
              color: Get.theme.colorScheme.primary.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
