import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/utils/my_text_style.dart';

class PropertyFilterBottomSheet extends StatefulWidget {
  final String? initialSortBy;
  final Function(String sortBy) onApplyFilters;

  const PropertyFilterBottomSheet({
    Key? key,
    this.initialSortBy,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<PropertyFilterBottomSheet> createState() => _PropertyFilterBottomSheetState();
}

class _PropertyFilterBottomSheetState extends State<PropertyFilterBottomSheet> {
  late String? selectedSortBy;

  @override
  void initState() {
    super.initState();
    selectedSortBy = widget.initialSortBy;
  }

  void updateSortBy(String value) {
    setState(() {
      selectedSortBy = value;
    });
  }

  void resetFilters() {
    setState(() {
      selectedSortBy = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                'Filter Properties',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
               FilterChip(
                selected: selectedSortBy == 'newest',
                label: const Text('Newest'),
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                onSelected: (selected) => updateSortBy('newest'),
                selectedColor: Theme.of(context).colorScheme.primary,
              ),
              FilterChip(
                selected: selectedSortBy == 'oldest',
                label: const Text('Oldest'),
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                onSelected: (selected) => updateSortBy('oldest'),
                selectedColor: Theme.of(context).colorScheme.primary,
              ),
              FilterChip(
                selected: selectedSortBy == 'price_desc',
                label: const Text('Price: High to Low'),
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                onSelected: (selected) => updateSortBy('price_desc'),
                selectedColor: Theme.of(context).colorScheme.primary,
              ),
              FilterChip(
                selected: selectedSortBy == 'price_asc',
                label: const Text('Price: Low to High'),
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                onSelected: (selected) => updateSortBy('price_asc'),
                selectedColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    resetFilters();
                    Get.back();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Get.theme.colorScheme.primary),
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: MyTextStyle.productMedium(
                      size: 16,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    widget.onApplyFilters(selectedSortBy ?? 'newest');
                    Get.back();
                  },
                  buttonText: 'Apply',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
} 