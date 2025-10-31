import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/common/widgets/custom_button.dart';

class TermsConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Terms of Use',
                    style: Get.textTheme.headlineMedium,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'By using this app, you agree to:\n\n'
                    '• Not post any objectionable, offensive, or inappropriate content\n'
                    '• Not engage in harassment or abusive behavior\n'
                    '• Not post false or misleading information\n'
                    '• Allow us to remove content that violates these terms\n'
                    '• Allow us to suspend or terminate accounts that violate these terms',
                    style: Get.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: 'Decline',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      buttonText: 'Accept',
                      onPressed: () {
                        // Save acceptance to storage
                        GetStorage().write('terms_accepted', true);
                        Get.back(result: true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 