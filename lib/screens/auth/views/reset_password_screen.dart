import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:hugeicons/hugeicons.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
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
                Text(
                  'Create New Password',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Your new password must be different from previously used passwords',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Password Field
                Obx(() => TextFormField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(
                      HugeIcons.strokeRoundedLockPassword,
                      color: context.theme.colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: controller.togglePasswordVisibility,
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? HugeIcons.strokeRoundedView
                            : HugeIcons.strokeRoundedViewOffSlash,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: AppSizes.lg),

                // Confirm Password Field
                Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(
                      HugeIcons.strokeRoundedLockPassword,
                      color: context.theme.colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: controller.toggleConfirmPasswordVisibility,
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? HugeIcons.strokeRoundedView
                            : HugeIcons.strokeRoundedViewOffSlash,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: AppSizes.xl),

                // Reset Button
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
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Reset Password'),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 