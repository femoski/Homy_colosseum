import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/constants/text_strings.dart';
import 'package:hugeicons/hugeicons.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MTexts.forgotPasswordTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Subtitle
                Text(
                  'Forgot your password?',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Enter your email address to receive a password reset link',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Email TextField
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: MTexts.email,
                    prefixIcon: Icon(
                      HugeIcons.strokeRoundedInbox,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.xl),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Text('Send Reset Link'),
                  )),
                ),
                const SizedBox(height: AppSizes.lg),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: RichText(
                      text: TextSpan(
                        text: "Remember your password? ",
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
        ),
      ),
    );
  }
} 