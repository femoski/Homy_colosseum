import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:pinput/pinput.dart';
import '../controllers/verify_reset_password_controller.dart';

class VerifyResetPasswordScreen extends GetView<VerifyResetPasswordController> {
  const VerifyResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Code',
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
                  'Verification Code',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Enter the verification code sent to ${controller.email}',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // PIN Input
                Center(
                  child: Pinput(
                    controller: controller.codeController,
                    length: 6,
                    onCompleted: (_) => controller.verifyCode(),
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.theme.colorScheme.primary.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.verifyCode,
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
                        : const Text('Verify Code'),
                  )),
                ),
                const SizedBox(height: AppSizes.lg),

                // Resend Code
                Center(
                  child: Obx(() => TextButton(
                    onPressed: controller.canResendCode.value
                        ? controller.resendCode
                        : null,
                    child: Text(
                      controller.canResendCode.value
                          ? 'Resend Code'
                          : 'Resend code in ${controller.resendTimer.value}s',
                      style: TextStyle(
                        color: controller.canResendCode.value
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
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