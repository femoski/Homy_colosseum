import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/custom_button.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final Function? onAccept;

  const TermsOfServiceScreen({Key? key, this.onAccept}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Content Guidelines'.tr,
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'By using this app, you agree to:'.tr,
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Not post any offensive, inappropriate, or harmful content'),
            _buildBulletPoint('Not engage in harassment or abusive behavior'),
            _buildBulletPoint('Not post false or misleading information about properties'),
            _buildBulletPoint('Respect other users\' privacy and rights'),
            
            const SizedBox(height: 24),
            Text(
              'Content Moderation'.tr,
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'We reserve the right to:'.tr,
              style: Get.textTheme.bodyLarge,
            ),
            _buildBulletPoint('Remove any content that violates our guidelines'),
            _buildBulletPoint('Suspend or terminate accounts of users who violate these terms'),
            _buildBulletPoint('Review and moderate user-generated content'),
            
            const SizedBox(height: 32),
            CustomButton(
              buttonText: 'Accept & Continue'.tr,
              onPressed: () {
                if (onAccept != null) {
                  onAccept!();
                }
                Get.back(result: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: Get.textTheme.bodyLarge),
          Expanded(
            child: Text(text, style: Get.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
} 