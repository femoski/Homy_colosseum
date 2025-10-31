import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Language',
                style: Get.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.close,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LanguageOption(
            title: 'English',
            subtitle: 'English',
            isSelected: true,
            onTap: () {
              Get.updateLocale(const Locale('en', 'US'));
              Get.back();
            },
          ),
          // _LanguageOption(
          //   title: 'العربية',
          //   subtitle: 'Arabic',
          //   isSelected: false,
          //   onTap: () {
          //     Get.updateLocale(const Locale('ar', 'SA'));
          //     Get.back();
          //   },
          // ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Get.theme.colorScheme.primary.withOpacity(0.1)
              : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Get.theme.colorScheme.primary
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MyTextStyle.productLight(
                      size: 16,
                      color: isSelected
                          ? Get.theme.colorScheme.primary
                          : Get.theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: MyTextStyle.productLight(
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Get.theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
} 