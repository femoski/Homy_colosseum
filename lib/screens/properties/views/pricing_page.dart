import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/properties/controllers/add_edit_property_controller.dart';
import 'package:homy/screens/properties/widgets/modern_text_field.dart';
import 'package:homy/utils/constants/app_colors.dart';

class PricingPage extends StatelessWidget {
  final AddEditPropertyScreenController controller;

  const PricingPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvailabilitySection(controller),
            const SizedBox(height: 24),

            if (controller.availablePropertyIndex == 0) ...[
              _buildSaleSection(controller),
            ] else ...[
              _buildRentSection(controller),
            ],
             const SizedBox(height: 14),
              _buildInspectionFee(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection(AddEditPropertyScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: Get.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 56,
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
            children: List.generate(
              controller.availableProperty.length,
              (index) => Expanded(
                child: _buildAvailabilityOption(controller, index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityOption(AddEditPropertyScreenController controller, int index) {
    return InkWell(
      onTap: () => controller.onAvailablePropertyClick(index),
      child: Container(
        decoration: BoxDecoration(
          color: controller.availablePropertyIndex == index
              ? Get.theme.colorScheme.primary
              : null,
          borderRadius: BorderRadius.horizontal(
            left: index == 0 ? const Radius.circular(12) : Radius.zero,
            right: index == 1 ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              index == 0 ? Icons.sell_outlined : Icons.real_estate_agent_outlined,
              size: 20,
              color: controller.availablePropertyIndex == index
                  ? Colors.white
                  : MColors.faintcolor,
            ),
            const SizedBox(width: 8),
            Text(
              controller.availableProperty[index].toUpperCase(),
              style: Get.textTheme.bodyMedium!.copyWith(
                color: controller.availablePropertyIndex == index
                    ? Colors.white
                    : MColors.faintcolor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleSection(AddEditPropertyScreenController controller) {
    return Column(
      children: [
        ModernTextField(
          controller: controller.firstPriceController,
          labelText: 'Sale Price',
          hintText: 'Enter property price in Naira',
          prefixIcon: Icons.money,
          suffixText: '₦',
          keyboardType: TextInputType.number,
          errorText: controller.showErrorsPricing && controller.firstPriceController.text.isEmpty ? 'Please enter property price' : null,
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Remove any non-digit characters
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digitsOnly.isNotEmpty) {
                // Format the number with commas
                final number = int.parse(digitsOnly);
                final formatted = number.toString().replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                );
                // Update the controller with formatted value
                controller.firstPriceController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }
          },
        ),
        const SizedBox(height: 24),
        ModernTextField(
          controller: controller.secondPriceController,
          labelText: 'Price per Sqft (Optional)',
          hintText: 'Enter price per square foot',
          prefixIcon: Icons.square_foot,
          keyboardType: TextInputType.number,

        ),
      ],
    );
  }

  Widget _buildRentSection(AddEditPropertyScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernTextField(
          controller: controller.firstPriceController,
          labelText: 'Rent Amount',
          hintText: 'Enter rent amount in Naira ',
          prefixIcon: Icons.money,
          suffixText: '₦',
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Remove any non-digit characters
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digitsOnly.isNotEmpty) {
                // Format the number with commas
                final number = int.parse(digitsOnly);
                final formatted = number.toString().replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                );
                // Update the controller with formatted value
                controller.firstPriceController.value = TextEditingValue(   
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }
          },  
          keyboardType: TextInputType.number,
          showPeriodSelector: true,
          selectedPeriod: controller.selectedRentPeriod,
          onPeriodChanged: (value) => controller.onRentPeriodSelect(value),
          errorText: controller.showErrorsPricing && controller.firstPriceController.text.isEmpty ? 'Please enter rent amount' : null,
        ),
      ],
    );
  }


    Widget _buildInspectionFee(AddEditPropertyScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernTextField(
          controller: controller.inspectionFeeController,
          labelText: 'Inspection Fee',
          hintText: 'Enter inspection fee (Optional)',
          prefixIcon: Icons.money,
          suffixText: '₦',
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Remove any non-digit characters
              String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digitsOnly.isNotEmpty) {
                // Format the number with commas
                final number = int.parse(digitsOnly);
                final formatted = number.toString().replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                );
                // Update the controller with formatted value
                controller.inspectionFeeController.value = TextEditingValue(  
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            }
          },
          // errorText: controller.showErrorsPricing && controller.inspectionFeeController.text.isEmpty ? 'Please enter inspection fee' : null,
        ),
      ],
    );
  }
}
