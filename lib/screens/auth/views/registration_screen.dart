import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/constants/text_strings.dart';
import 'package:hugeicons/hugeicons.dart';
import '../controllers/registration_controller.dart';

class RegistrationScreen extends GetView<RegistrationController> {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background design
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, 
                          color: context.theme.colorScheme.onSurface),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Header
                  Text(
                    MTexts.signupTitle,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    MTexts.signupSubTitle,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.xl),
                  
                  // Form
                  Form(
                    key: controller.formKey,
                    child: Card(
                      color: context.theme.colorScheme.surface ,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: context.theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: controller.fullNameController,
                              label: MTexts.cUsername,
                              icon: HugeIcons.strokeRoundedUser,
                              maxLength: 15,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Username';
                                }
                                if (value.length < 5) {
                                  return 'Username must be at least 5 characters';
                                }
                                if (value.length > 15) {
                                  return 'Username must be 10 characters or less';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.md),
                            _buildTextField(
                              controller: controller.emailController,
                              label: MTexts.email,
                              icon: HugeIcons.strokeRoundedInbox,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Email';
                                }
                                if (!GetUtils.isEmail(value)) {
                                  return 'Please enter a valid Email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.md),
                            _buildTextField(
                              controller: controller.phoneController,
                              label: MTexts.cPhone,
                              icon: HugeIcons.strokeRoundedSmartPhone01,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                // Check if the value contains only numbers
                                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Please enter numbers only';
                                }
                                if (value.length < 11) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.md),
                            Obx(() => _buildTextField(
                              controller: controller.passwordController,
                              label: MTexts.password,
                              icon: HugeIcons.strokeRoundedLockPassword,
                              isPassword: true,
                              isPasswordVisible: controller.isPasswordVisible.value,
                              onVisibilityChanged: controller.togglePasswordVisibility,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            )),
                            const SizedBox(height: AppSizes.md),
                            Obx(() => _buildTextField(
                              controller: controller.confirmPasswordController,
                              label: 'Confirm Password',
                              icon: HugeIcons.strokeRoundedLockPassword,
                              isPassword: true,
                              isPasswordVisible: controller.isConfirmPasswordVisible.value,
                              onVisibilityChanged: controller.toggleConfirmPasswordVisibility,
                              validator: (value) {
                                if (value != controller.passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            )),

                            const SizedBox(height: AppSizes.md),
                             _buildTextField(
                              controller: controller.referralCodeController,
                              label: 'Referral Code (optional)',
                              icon: HugeIcons.strokeRoundedUserSwitch,
                              keyboardType: TextInputType.text,
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Terms and Conditions
                  Obx(() => CheckboxListTile(
                    value: controller.hasAcceptedTerms.value,
                    onChanged: (value) async {
                      if (value == true) {
                        await controller.showTermsIfNeeded();
                      }
                    },
                    title: Text.rich(
                      TextSpan(
                        text: 'I agree to the '.tr,
                        children: [
                          TextSpan(
                            text: 'Terms of Use'.tr,
                            style: TextStyle(
                              color: context.theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed('/html-page?page=terms-and-condition');
                              },
                          ),
                        ],
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Sign Up Button
                  Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value 
                        ? null 
                        : controller.register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: context.theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            MTexts.signUp,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Sign In Link
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: context.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: MTexts.signIn,
                              style: TextStyle(
                                color: context.theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onVisibilityChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? initialValue,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: isPassword && !(isPasswordVisible ?? false),
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
              decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Get.theme.colorScheme.primary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ?? false
                        ? HugeIcons.strokeRoundedView
                        : HugeIcons.strokeRoundedViewOffSlash,
                    color: Get.theme.colorScheme.primary,
                  ),
                  onPressed: onVisibilityChanged,
                )
              : null,
          counterText: "", // Hide the character counter
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Get.theme.brightness == Brightness.dark ? Get.theme.colorScheme.surface : Get.theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Get.theme.colorScheme.primary,
          ),
        ),
        filled: true,
        fillColor: Get.theme.colorScheme.surface,
      ),
    );
  }
} 