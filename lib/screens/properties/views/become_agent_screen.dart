import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/become_agent_controller.dart';
import 'dart:io';

class BecomeAgentScreen extends StatelessWidget {
  const BecomeAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BecomeAgentController>(
      init: BecomeAgentController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.theme.colorScheme.onSurface,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Become an Agent',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: controller.isCheckingRegistration 
          ? Center(
              child: _buildLoadingState(context),
            )
          : controller.isRegistrationPending
            ? _buildPendingState(context)
            : Stepper(
              currentStep: controller.currentStep,
              onStepContinue: () {
                controller.goToNextStep();
              },
              onStepCancel: () {
                if (controller.currentStep > 0) {
                  controller.currentStep--;
                  controller.update();
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                    
                          if (controller.currentStep > 0) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Back',
                                  style: context.textTheme.titleMedium?.copyWith(
                                    color: context.theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                          ],

                                Expanded(
                            child: ElevatedButton(
                              onPressed: controller.isLoading ? null : details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: context.theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: controller.isLoading && controller.currentStep == 2
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      controller.currentStep == 2 ? 'Submit' : 'Continue',
                                      style: context.textTheme.titleMedium?.copyWith(
                                        color: context.theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: Text(
                    'Personal Information',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: _buildPersonalInfoForm(context, controller),
                  isActive: controller.currentStep >= 0,
                  state: controller.currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text(
                    'Business Details',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: _buildBusinessDetailsForm(context, controller),
                  isActive: controller.currentStep >= 1,
                  state: controller.currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text(
                    'Document Upload',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: _buildDocumentUploads(context, controller),
                  isActive: controller.currentStep >= 2,
                  state: controller.currentStep > 2 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Shimmer.fromColors(
            baseColor: context.isDarkMode 
              ? Colors.grey[800]! 
              : Colors.grey[300]!,
            highlightColor: context.isDarkMode 
              ? Colors.grey[700]! 
              : Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Checking your registration status...',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty,
                size: 48,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Registration Pending',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your agent registration is currently under review. We will notify you once it\'s approved.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Go Back',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm(BuildContext context, BecomeAgentController controller) {
    return Form(
      key: controller.personalInfoFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(
                Icons.person_outline,
                color: context.theme.colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.nationalIdController,
            decoration: const InputDecoration(
              labelText: 'National ID Number',
              hintText: 'Enter your national ID number',
              prefixIcon: Icon(Icons.numbers),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter national ID number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              hintText: 'Enter years of experience in real estate',
              prefixIcon: Icon(Icons.work_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter years of experience';
              }
              if (!GetUtils.isNum(value)) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsForm(BuildContext context, BecomeAgentController controller) {
    return Form(
      key: controller.businessDetailsFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.businessNameController,
            decoration: const InputDecoration(
              labelText: 'Agency/Business Name',
              hintText: 'Enter your agency name',
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter agency name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.businessAddressController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Office Address',
              hintText: 'Enter your office address',
              prefixIcon: Icon(Icons.location_on_outlined),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter office address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Business Email',
              hintText: 'Enter your business email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter business email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Business Phone',
              hintText: 'Enter your business phone number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              if (!GetUtils.isPhoneNumber(value)) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploads(BuildContext context, BecomeAgentController controller) {
    return Column(
      children: [
        // ID Card Upload
        _buildUploadSection(
          context,
          controller,
          title: 'Identity Card',
          subtitle: 'Upload a clear photo of your ID card',
          icon: Icons.badge_outlined,
          photo: controller.idCardPhoto,
          onTap: controller.captureIdCard,
          onDelete: () {
            controller.idCardPhoto = null;
            controller.update();
          },
          showError: controller.showIdCardError && controller.idCardPhoto == null,
          errorText: 'ID card photo is required',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // ID Card with Selfie Upload
        _buildUploadSection(
          context,
          controller,
          title: 'ID Card with Selfie',
          subtitle: 'Take a photo of yourself holding your ID card',
          icon: Icons.camera_alt_outlined,
          photo: controller.idCardSelfiePhoto,
          onTap: controller.captureIdWithSelfie,
          onDelete: () {
            controller.idCardSelfiePhoto = null;
            controller.update();
          },
          showError: controller.showIdCardSelfieError && controller.idCardSelfiePhoto == null,
          errorText: 'ID card with selfie photo is required',
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // CAC Document Upload
        _buildUploadSection(
          context,
          controller,
          title: 'CAC Document',
          subtitle: 'Upload your CAC document (PDF, Image)',
          icon: Icons.upload_file_outlined,
          document: controller.cacDocument,
          onTap: controller.pickCACDocument,
          onDelete: () {
            controller.cacDocument = null;
            controller.update();
          },
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildUploadSection(
    BuildContext context,
    BecomeAgentController controller, {
    required String title,
    required String subtitle,
    required IconData icon,
    dynamic photo,
    dynamic document,
    required Function() onTap,
    required Function() onDelete,
    bool showError = false,
    String errorText = '',
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (photo != null || document != null) ...[
            if (photo != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: !kIsWeb
                        ? Image.file(
                            File(photo.path),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            photo.path,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: context.theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (document != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.file_present,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.name,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Document uploaded',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: context.theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: (photo != null || document != null)
                    ? const BorderRadius.vertical(bottom: Radius.circular(15))
                    : BorderRadius.circular(15),
                border: showError
                    ? Border.all(color: context.theme.colorScheme.error)
                    : null,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isRequired) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '*',
                                    style: context.textTheme.titleMedium?.copyWith(
                                      color: context.theme.colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              subtitle,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: context.theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  if (showError) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: context.theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            errorText,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 