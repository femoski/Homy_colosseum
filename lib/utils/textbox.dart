import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModernTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final int? maxLines;
  final String? initialValue;
  final bool enabled;

  const ModernTextField({
    Key? key,
    required this.labelText,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.initialValue,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.controller != null) {
      widget.controller!.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: widget.prefixIcon != null 
              ? Icon(
                  widget.prefixIcon, 
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                )
              : null,
          suffixIcon: widget.suffixIcon != null 
              ? Icon(
                  widget.suffixIcon, 
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isDark ? Get.theme.colorScheme.primary.withOpacity(0.2) : Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Get.theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.white,
        ),
      ),
    );
  }
} 