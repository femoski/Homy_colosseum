import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class RichTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool isEnabled;
  final int? maxLines;
  final TextAlign textAlign;
  final Function(String)? onChanged;
  final String? suffixText;
  final bool showPeriodSelector;
  final int? selectedPeriod;
  final ValueChanged<int?>? onPeriodChanged;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const RichTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.isEnabled = true,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.suffixText,
    this.showPeriodSelector = false,
    this.selectedPeriod,
    this.onPeriodChanged,
    this.errorText,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<RichTextField> createState() => _RichTextFieldState();
}

class _RichTextFieldState extends State<RichTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.labelText!,
              style: MyTextStyle.productRegular(
                size: 15,
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
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
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.isEnabled,
                  maxLines: widget.maxLines,
                  textAlign: widget.textAlign,
                  textCapitalization: widget.textCapitalization,
                  keyboardType: widget.keyboardType,
                  onChanged: (text) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(text);
                    }
                  },
                  style: Get.theme.textTheme.bodyMedium!.copyWith(
                    fontSize: 15
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            size: 20,
                            color: Get.theme.colorScheme.primary,
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 0 : 16,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixText: !widget.showPeriodSelector ? widget.suffixText : null,
                  ),
                  textInputAction: widget.textInputAction,
                  focusNode: widget.focusNode,
                ),
              ),
              
              if (widget.showPeriodSelector) ...[
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Get.theme.colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _showPeriodBottomSheet(context),
                    child: Row(
                      children: [
                        Text(
                          _getPeriodLabel(widget.selectedPeriod ?? 1),
                          style: Get.textTheme.bodyMedium!.copyWith(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Get.theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _showPeriodBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Select Period',
                style: MyTextStyle.productRegular(
                  size: 20,
                  color: Get.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: Get.theme.colorScheme.outline.withOpacity(0.2),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPeriodOption(1, 'Per Day', Icons.today),
                  const SizedBox(height: 8),
                  _buildPeriodOption(2, 'Per Week', Icons.today),
                  const SizedBox(height: 8),
                  _buildPeriodOption(3, 'Per Month', Icons.calendar_month),
                  const SizedBox(height: 8),
                  _buildPeriodOption(4, 'Per Year', Icons.calendar_today),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPeriodOption(int value, String label, IconData icon) {
    final isSelected = value == widget.selectedPeriod;
    return InkWell(
      onTap: () {
        widget.onPeriodChanged?.call(value);
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Get.theme.colorScheme.primary.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Get.textTheme.bodyMedium!.copyWith(
                color: isSelected
                    ? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel(int period) {
    switch (period) {
      case 1:
        return '/day';  
      case 1:
        return '/week';
      case 2:
        return '/month';
      case 4:
        return '/year';
      default:
        return '/month';
    }
  }
} 