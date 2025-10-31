import 'package:flutter/material.dart';
// import 'package:homy/screens/properties/controllers/area_properties_controller.dart';

class PropertyFilterSheet extends StatelessWidget {
  final controller;

  const PropertyFilterSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Properties',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Type
                      _buildSectionTitle(context, 'Property Type'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterChip(
                              context,
                              label: 'All',
                              isSelected: controller.selectedPropertyType == null,
                              onSelected: (selected) {
                                setState(() {
                                  controller.updatePropertyType(null);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterChip(
                              context,
                              label: 'Rent',
                              isSelected: controller.selectedPropertyType == 'rent',
                              onSelected: (selected) {
                                setState(() {
                                  controller.updatePropertyType('rent');
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterChip(
                              context,
                              label: 'Sale',
                              isSelected: controller.selectedPropertyType == 'sales',
                              onSelected: (selected) {
                                setState(() {
                                  controller.updatePropertyType('sales');
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price Range
                      _buildSectionTitle(context, 'Price Range'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceField(
                              context,
                              controller: controller.minPriceController,
                              label: 'Min Price',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPriceField(
                              context,
                              controller: controller.maxPriceController,
                              label: 'Max Price',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bedrooms
                      _buildSectionTitle(context, 'Bedrooms'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(
                            context,
                            label: 'Any',
                            isSelected: controller.selectedBedrooms == null,
                            onSelected: (selected) {
                              setState(() {
                                controller.updateBedrooms(null);
                              });
                            },
                          ),
                          ...List.generate(4, (index) => 
                            _buildFilterChip(
                              context,
                              label: '${index + 1}',
                              isSelected: controller.selectedBedrooms == index + 1,
                              onSelected: (selected) {
                                setState(() {
                                  controller.updateBedrooms(index + 1);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bathrooms
                      _buildSectionTitle(context, 'Bathrooms'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(
                            context,
                            label: 'Any',
                            isSelected: controller.selectedBathrooms == null,
                            onSelected: (selected) {
                              setState(() {
                                controller.updateBathrooms(null);
                              });
                            },
                          ),
                          ...List.generate(4, (index) => 
                            _buildFilterChip(
                              context,
                              label: '${index + 1}',
                              isSelected: controller.selectedBathrooms == index + 1,
                              onSelected: (selected) {
                                setState(() {
                                  controller.updateBathrooms(index + 1);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sort By
                      _buildSectionTitle(context, 'Sort By'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(
                            context,
                            label: 'Newest',
                            isSelected: controller.sortBy == 'newest',
                            onSelected: (selected) {
                              setState(() {
                                controller.updateSortBy('newest');
                              });
                            },
                          ),
                          _buildFilterChip(
                            context,
                            label: 'Oldest',
                            isSelected: controller.sortBy == 'oldest',
                            onSelected: (selected) {
                              setState(() {
                                controller.updateSortBy('oldest');
                              });
                            },
                          ),
                          _buildFilterChip(
                            context,
                            label: 'Price: High to Low',
                            isSelected: controller.sortBy == 'price_desc',
                            onSelected: (selected) {
                              setState(() {
                                controller.updateSortBy('price_desc');
                              });
                            },
                          ),
                          _buildFilterChip(
                            context,
                            label: 'Price: Low to High',
                            isSelected: controller.sortBy == 'price_asc',
                            onSelected: (selected) {
                              setState(() {
                                controller.updateSortBy('price_asc');
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            controller.resetFilters();
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected 
          ? Theme.of(context).colorScheme.primary 
          : Theme.of(context).textTheme.bodyLarge?.color,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).dividerColor,
        ),
      ),
    );
  }

  Widget _buildPriceField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
} 