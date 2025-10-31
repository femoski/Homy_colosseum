import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PropertyFilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const PropertyFilterSheet({
    Key? key,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  String _selectedDateSort = 'any';
  String _selectedPriceSort = 'any';
  String _selectedPopularitySort = 'any';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort Properties',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Filter sections
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Date', Icons.calendar_today),
                  _buildRadioGroup(
                    value: _selectedDateSort,
                    options: {
                      'any': 'Any',
                      'newest': 'Newest First',
                      'oldest': 'Oldest First',
                    },
                    onChanged: (value) {
                      setState(() => _selectedDateSort = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Price', Icons.attach_money),
                  _buildRadioGroup(
                    value: _selectedPriceSort,
                    options: {
                      'any': 'Any',
                      'high_low': 'Highest to Lowest',
                      'low_high': 'Lowest to Highest',
                    },
                    onChanged: (value) {
                      setState(() => _selectedPriceSort = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Popularity', Icons.trending_up),
                  _buildRadioGroup(
                    value: _selectedPopularitySort,
                    options: {
                      'any': 'Any',
                      'most_viewed': 'Most Viewed',
                      'most_liked': 'Most Liked',
                    },
                    onChanged: (value) {
                      setState(() => _selectedPopularitySort = value!);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDateSort = 'any';
                          _selectedPriceSort = 'any';
                          _selectedPopularitySort = 'any';
                        });
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
                        final filters = {
                          'dateSort': _selectedDateSort,
                          'priceSort': _selectedPriceSort,
                          'popularitySort': _selectedPopularitySort,
                        };
                        widget.onApplyFilters(filters);
                        Get.back();
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
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup({
    required String value,
    required Map<String, String> options,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: options.entries.map((entry) {
          return RadioListTile<String>(
            title: Text(
              entry.value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            value: entry.key,
            groupValue: value,
            onChanged: onChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            activeColor: Theme.of(context).colorScheme.primary,
          );
        }).toList(),
      ),
    );
  }
} 