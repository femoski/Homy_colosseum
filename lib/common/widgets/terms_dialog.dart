import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsDialog extends StatelessWidget {
  const TermsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Terms of Use'.tr,
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'By continuing, you agree to:'.tr,
                  style: Get.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                _buildTermPoint('Not post any objectionable or inappropriate content'),
                _buildTermPoint('Not engage in harassment or abusive behavior'),
                _buildTermPoint('Not post false or misleading information'),
                _buildTermPoint('Allow us to remove content that violates these terms'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          'Decline'.tr,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Accept'.tr),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/html-page?page=terms-and-condition');
                  },
                  child: Text(
                    'Read Full Terms'.tr,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: Get.textTheme.bodyMedium),
          Expanded(
            child: Text(
              text.tr,
              style: Get.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
} 