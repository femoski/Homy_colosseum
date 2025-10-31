import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class ModernSelectField extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? errorText;
  final Color? color;
  const ModernSelectField({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MyTextStyle.productRegular(
            size: 15,
            color: Get.theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: color ?? Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Get.theme.colorScheme.primary.withOpacity(0.1)
                    : Get.theme.colorScheme.primary.withOpacity(0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.primary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Get.theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: Get.theme.textTheme.bodyMedium!.copyWith(
                      fontSize: 15,
                      color: isSelected
                          ? null
                          : Get.theme.inputDecorationTheme.hintStyle!.color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Get.theme.colorScheme.outline,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Get.theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
} 