import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:pinput/pinput.dart';
import '../controllers/verification_controller.dart';

class VerificationScreen extends GetView<VerificationController> {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Account',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.xl,
          ),
          child: Column(
            children: [
              // Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: Obx(() => Row(
                  children: [
                    Expanded(
                      flex: controller.currentStep.value == 0 ? 2 : 1,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: controller.isEmailVerified.value 
                              ? Colors.green 
                              : context.theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: controller.currentStep.value == 1 ? 2 : 1,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: controller.isPhoneVerified.value 
                              ? Colors.green
                              : controller.currentStep.value == 1 
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.onBackground.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              const SizedBox(height: AppSizes.xl),

              // Verification Cards
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.currentStep.value == 0
                    ? _buildVerificationCard(
                        key: const ValueKey('email'),
                        title: 'Email Verification',
                        subtitle: 'Enter the code sent to:',
                        value: controller.email,
                        isVerified: controller.isEmailVerified.value,
                        pinController: controller.emailPinController,
                        onVerify: controller.verifyEmail,
                        canResend: controller.canResendEmailCode.value,
                        onResend: controller.resendEmailCode,
                        resendTimer: controller.emailResendTimer.value,
                        context: context,
                        isDark: isDark,
                        onChangeEmail: () => showEditDialog(
                          context: context,
                          title: 'Edit Email',
                          initialValue: controller.email,
                          keyboardType: TextInputType.emailAddress,
                          onSave: (value) => controller.validateAndUpdateEmail(value),
                        ),
                      )
                    : _buildVerificationCard(
                        key: const ValueKey('phone'),
                        title: 'Phone Verification',
                        subtitle: 'Enter the code sent to:',
                        value: controller.phone,
                        isVerified: controller.isPhoneVerified.value,
                        pinController: controller.phonePinController,
                        onVerify: controller.verifyPhone,
                        canResend: controller.canResendPhoneCode.value,
                        onResend: controller.resendPhoneCode,
                        resendTimer: controller.phoneResendTimer.value,
                        context: context,
                        isPhone: true,
                        isDark: isDark,
                        onChangePhone: () => showEditDialog(
                          context: context,
                          title: 'Edit Phone',
                          initialValue: controller.phone,
                          keyboardType: TextInputType.phone,
                          onSave: (value) => controller.validateAndUpdatePhone(value),
                        ),
                      ),
              )),
              const SizedBox(height: AppSizes.xl),

              // Navigation Buttons
              Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value || 
                               (controller.currentStep.value == 0 && !controller.isEmailPinValid.value && !controller.isEmailVerified.value) ||
                               (controller.currentStep.value == 1 && !controller.isPhonePinValid.value && !controller.isPhoneVerified.value)
                        ? null
                        : controller.currentStep.value == 0 
                            ? controller.isEmailVerified.value
                                ? () => controller.nextStep()  // Go to phone verification
                                : controller.verifyEmail
                            : controller.isPhoneVerified.value
                                ? () => controller.completeVerification()  // Complete verification
                                : controller.verifyPhone,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: context.theme.colorScheme.primary,
                      foregroundColor: context.theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      controller.currentStep.value == 0
                          ? controller.isEmailVerified.value
                              ? Icons.arrow_forward_rounded
                              : Icons.mark_email_read_rounded
                          : controller.isPhoneVerified.value
                              ? Icons.check_circle_rounded
                              : Icons.phone_android_rounded
                    ),
                    label: controller.isLoading.value
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
                        : Text(
                            controller.currentStep.value == 0
                                ? controller.isEmailVerified.value
                                    ? 'Next'
                                    : 'Verify Email'
                                : controller.isPhoneVerified.value
                                    ? 'Continue'
                                    : 'Verify Phone'
                          ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard({
    required Key key,
    required String title,
    required String subtitle,
    required String value,
    required bool isVerified,
    required TextEditingController pinController,
    required Function() onVerify,
    required bool canResend,
    required Function() onResend,
    required int resendTimer,
    required BuildContext context,
    required bool isDark,
    bool isPhone = false,
    Function()? onChangePhone,
    Function()? onChangeEmail,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark 
            ? context.theme.colorScheme.surface 
            : context.theme.colorScheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(isDark ? 0.3 : 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPhone 
                  ? Icons.smartphone_rounded
                  : Icons.mark_email_read_rounded,
              size: 48,
              color: context.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          if (!isVerified) ...[
          // Subtitle and Value
          Text(
            subtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              if (!isVerified) ...[
                const SizedBox(width: 8),
                if (isPhone)
                  TextButton.icon(
                    onPressed: onChangePhone,
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: context.theme.colorScheme.primary,
                    ),
                    label: Text(
                      'Change',
                      style: TextStyle(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: onChangeEmail,
                    icon: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: context.theme.colorScheme.primary,
                    ),
                    label: Text(
                      'Change',
                      style: TextStyle(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.xl),

          // PIN Input
            Text(
              'Enter verification code',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Pinput(
              length: 6,
              controller: pinController,
              enabled: !isVerified,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 55,
                textStyle: context.textTheme.titleMedium,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 50,
                height: 55,
                textStyle: context.textTheme.titleMedium,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Only show resend button
            TextButton.icon(
              onPressed: canResend ? () {
                if (isPhone) {
                  if (controller.isWhatsappSmsEnabled) {
                    _showResendMethodDialog(
                      context: context,
                      onSmsSelected: onResend,
                      onWhatsAppSelected: () => controller.resendPhoneCode(isWhatsApp: true),
                    );
                  } else {
                    onResend();
                  }
                } else {
                  onResend();
                }
              } : null,
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: canResend 
                    ? context.theme.colorScheme.primary
                    : context.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              label: Text(
                canResend
                    ? 'Resend Code'
                    : 'Resend in ${resendTimer}s',
                style: TextStyle(
                  color: canResend 
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showResendMethodDialog({
    required BuildContext context,
    required Function() onSmsSelected,
    required Function() onWhatsAppSelected,
  }) {
    final isDark = context.theme.brightness == Brightness.dark;
  
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark 
                ? context.theme.colorScheme.surface 
                : context.theme.colorScheme.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Verification Method',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildMethodOption(
                      context: context,
                      icon: Icons.sms_rounded,
                      title: 'SMS',
                      subtitle: 'Receive code via text message',
                      onTap: () {
                        Get.back();
                        onSmsSelected();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMethodOption(
                      context: context,
                      icon: Icons.message_rounded,
                      title: 'WhatsApp',
                      subtitle: 'Receive code via WhatsApp',
                      onTap: () {
                        Get.back();
                        onWhatsAppSelected();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildMethodOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: context.theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern dialog for editing email or phone
  void showEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    required TextInputType keyboardType,
    required Future<bool> Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();
    final isDark = context.theme.brightness == Brightness.dark;
    final isLoading = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark 
                ? context.theme.colorScheme.surface 
                : context.theme.colorScheme.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    keyboardType == TextInputType.emailAddress 
                        ? Icons.email_rounded 
                        : Icons.phone_rounded,
                    color: context.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form
              Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  autofocus: true,
                  style: context.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark 
                        ? context.theme.colorScheme.surfaceVariant.withOpacity(0.5)
                        : context.theme.colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.theme.colorScheme.error,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintText: 'Enter ${title.toLowerCase()}',
                    hintStyle: context.textTheme.bodyLarge?.copyWith(
                      color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field cannot be empty';
                    }
                    if (keyboardType == TextInputType.emailAddress && !GetUtils.isEmail(value)) {
                      return 'Enter a valid email';
                    }
                    if (keyboardType == TextInputType.phone && value.length < 11) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        isLoading.value = true;
                        final success = await onSave(controller.text.trim());
                        if (success) {
                          // Get.back();
                        }
                        isLoading.value = false;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: context.theme.colorScheme.primary,
                      foregroundColor: context.theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Obx(() => isLoading.value
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
                      : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
} 