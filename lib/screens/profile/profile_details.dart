import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/screens/profile/controllers/profile_details_controller.dart';
import 'package:homy/utils/textbox.dart';



class ProfileDetailsScreen extends GetView<ProfileDetailScreenController> {

  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Details',
          style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GetBuilder(
        init: controller,
        builder: (controller) {
          return Stack(
            children: [
              Container(
               
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GetBuilder(
                      init: controller,
                      builder: (controller) {
                        return Column(
                          children: [
                            _buildProfileImage(controller),
                            const SizedBox(height: 32),
                            _buildPersonalInfo(controller),
                            const SizedBox(height: 24),
                            _buildContactInfo(controller),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildSubmitButton(controller),
            ],
          ),
        ],
      ) ;
  }));
  }

  Widget _buildProfileImage(ProfileDetailScreenController controller) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Get.theme.colorScheme.primary,
              child: CircleAvatar(
                radius: 58,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: !kIsWeb && controller.fileImage?.path != null
                      ? Image.file(
                          File(controller.fileImage?.path ?? ''),
                          fit: BoxFit.cover,
                          width: 116,
                          height: 116,
                        )
                      : Image.network(
                              '${controller.userData?.avatar}',
                              fit: BoxFit.cover,
                              width: 116,
                              height: 116,
                              errorBuilder: (context, error, stackTrace) {
                                return CommonUI.errorUserPlaceholder(
                                    width: 116, height: 116);
                              },
                            ),
                          // : CommonUI.errorUserPlaceholder(
                          //     width: 116, height: 116),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: controller.onProfileClick,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Get.theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
    ),
    );
  }

  Widget _buildPersonalInfo(ProfileDetailScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          labelText: 'First Name',
          controller: controller.firstNameController,
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          suffixIcon: controller.userData?.is_editable ?? false ?  null : Icons.verified,
          enabled: controller.userData?.is_editable ?? false,
        ),

         ModernTextField(
          labelText: 'Last Name',
          controller: controller.lastNameController,
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          suffixIcon: controller.userData?.is_editable ?? false ?  null : Icons.verified,
          enabled: controller.userData?.is_editable ?? false,
        ),
        // ModernTextField(
        //   labelText: 'What Are You Here For',
        //   controller: controller.fullnameController,
        //   prefixIcon: Icons.help_outline,
        // ),
        ModernTextField(
          labelText: 'About Yourself',
          controller: controller.aboutController,
          prefixIcon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildContactInfo(ProfileDetailScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
           ModernTextField(
          labelText: 'Email',
          controller: controller.emailController,
          prefixIcon: Icons.email_outlined,
          suffixIcon: Icons.verified,
          keyboardType: TextInputType.emailAddress,
          enabled:  false,
        ),
        ModernTextField(
          labelText: 'Mobile (Optional)',
          controller: controller.mobileController,
          prefixIcon: Icons.smartphone_outlined,
          suffixIcon: Icons.verified,
          keyboardType: TextInputType.phone,
          enabled:  false,
        ),
        ModernTextField(
          labelText: 'Address (Optional)',
          controller: controller.addressController,
          prefixIcon: Icons.location_on_outlined,
        ),
        ModernTextField(
          labelText: 'Phone Office (Optional)',
          controller: controller.phoneOfficeController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
    
        ModernTextField(
          labelText: 'Fax (Optional)',
          controller: controller.faxController,
          prefixIcon: Icons.fax_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ProfileDetailScreenController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomButton(
          buttonText: controller.isLoading ? 'Updating...' : 'Save Changes',
          onPressed: controller.onSubmitClick,
          isLoading: controller.isLoading,
        ),
      ),
    );
  }
}
