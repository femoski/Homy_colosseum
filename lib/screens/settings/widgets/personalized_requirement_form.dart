import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:homy/models/saved_requirement_model.dart';
import 'package:homy/models/place_model.dart';
import 'package:homy/services/saved_requirement_service.dart';
import 'package:homy/services/categories_service.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/extentions/lib/adaptive_type.dart';
import 'package:homy/screens/location/pick_map_screen.dart';

class PersonalizedRequirementForm extends StatefulWidget {
  const PersonalizedRequirementForm({super.key});

  @override
  State<PersonalizedRequirementForm> createState() => _PersonalizedRequirementFormState();
}

class _PersonalizedRequirementFormState extends State<PersonalizedRequirementForm> {
  final _formKey = GlobalKey<FormState>();
  final _requirementService = Get.find<SavedRequirementService>();
  
  // Form controllers
  final _locationController = TextEditingController();
  
  // Form data
  final List<String> _selectedPropertyTypes = [];
  final List<String> _selectedCategoryIds = [];
  final List<String> _selectedLocations = [];
  String? _selectedMinBedrooms;
  String? _selectedMinBathrooms;
  
  // Price range data
  double _minPrice = Constant.minPriceRange;
  double _maxPrice = Constant.maxPriceRange;
  
  // Area range data
  double _minArea = Constant.minAreaRange;
  double _maxArea = Constant.maxAreaRange;
  
  // Location data
  int _locationType = 0; // 0: by city, 1: by location with radius
  String _selectedLocationName = '';
  double? _latitude;
  double? _longitude;
  double _radius = 0;
  
  // Categories service
  final CategoriesService _categoriesService = Get.find<CategoriesService>();
  List<Map<String, String>> _availablePropertyTypes = [];
  
  

  @override
  void initState() {
    super.initState();
    _loadCurrentRequirement();
    _loadPropertyTypes();
  }
  
  Future<void> _loadPropertyTypes() async {
    try {
      // Load categories from the service
      final categories = await _categoriesService.getAllCategories();
      _availablePropertyTypes = categories.map((category) => {
        'id': category.id ?? '',
        'title': category.title ?? ''
      }).toList();
      Get.log('load categories: $categories');
      setState(() {});
    } catch (e) {
      print('Error loading property types: $e');
      // Fallback to default list if service fails
      _availablePropertyTypes = [
        {'id': '1', 'title': 'Apartment'},
        {'id': '2', 'title': 'Duplex'},
        {'id': '3', 'title': 'Bungalow'},
        {'id': '4', 'title': 'Land'},
        {'id': '5', 'title': 'Commercial'},
        {'id': '6', 'title': 'Office Space'},
        {'id': '7', 'title': 'Shop'},
        {'id': '8', 'title': 'Warehouse'},
        {'id': '9', 'title': 'Hotel'},
        {'id': '10', 'title': 'Event Center'},
      ];
      setState(() {});
    }
  }

  void _loadCurrentRequirement() {
    // First load from local storage for immediate access
    final current = _requirementService.current;
    Get.log('current (local): ${current}');
    
    if (current != null) {
      _populateFormData(current);
      setState(() {});
    }
    
    // Then refresh from backend and update if needed (non-blocking)
    _refreshFromBackend();
  }
  
  Future<void> _refreshFromBackend() async {
    await _requirementService.refreshFromBackend();
    
    final updatedCurrent = _requirementService.current;
    Get.log('current (after backend refresh): ${updatedCurrent}');
    
    if (updatedCurrent != null) {
      // Clear existing data and repopulate with fresh data
      _clearFormData();
      _populateFormData(updatedCurrent);
      setState(() {});
    }
  }
  
  void _clearFormData() {
    _selectedPropertyTypes.clear();
    _selectedCategoryIds.clear();
    _selectedLocations.clear();
    _selectedMinBedrooms = null;
    _selectedMinBathrooms = null;
    _minPrice = Constant.minPriceRange;
    _maxPrice = Constant.maxPriceRange;
    _minArea = Constant.minAreaRange;
    _maxArea = Constant.maxAreaRange;
    _locationType = 0;
    _selectedLocationName = '';
    _latitude = null;
    _longitude = null;
    _radius = 0;
  }
  
  void _populateFormData(SavedRequirement requirement) {
    _selectedPropertyTypes.addAll(requirement.propertyTypes);
    _selectedCategoryIds.addAll(requirement.selectedCategoryIds);
    _selectedMinBedrooms = requirement.minBedrooms?.toString();
    _selectedMinBathrooms = requirement.minBathrooms?.toString();
    
    if (requirement.minPrice != null) {
      _minPrice = requirement.minPrice!.toDouble();
    }
    if (requirement.maxPrice != null) {
      _maxPrice = requirement.maxPrice!.toDouble();
    }
    
    if (requirement.minArea != null) {
      _minArea = requirement.minArea!;
    }
    if (requirement.maxArea != null) {
      _maxArea = requirement.maxArea!;
    }
    
    _locationType = requirement.locationType ?? 0;
    
    // Load location data based on mode
    if (_locationType == 0) {
      // Load cities
      _selectedLocations.addAll(requirement.locations);
    } else {
      // Load single location
      _selectedLocationName = requirement.selectedLocationName ?? '';
      _latitude = requirement.latitude;
      _longitude = requirement.longitude;
      _radius = requirement.radius ?? 0;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _saveRequirement() async {
    if (!_formKey.currentState!.validate()) return;

    final requirement = SavedRequirement(
      locations: _locationType == 0 ? _selectedLocations : [],
      minPrice: _minPrice != Constant.minPriceRange ? _minPrice.toInt() : null,
      maxPrice: _maxPrice != Constant.maxPriceRange ? _maxPrice.toInt() : null,
      propertyTypes: _selectedPropertyTypes,
      selectedCategoryIds: _selectedCategoryIds,
      minBedrooms: _selectedMinBedrooms != null ? int.tryParse(_selectedMinBedrooms!) : null,
      minBathrooms: _selectedMinBathrooms != null ? int.tryParse(_selectedMinBathrooms!) : null,
      minArea: _minArea != Constant.minAreaRange ? _minArea : null,
      maxArea: _maxArea != Constant.maxAreaRange ? _maxArea : null,
      locationType: _locationType,
      selectedLocationName: _locationType == 1 && _selectedLocationName.isNotEmpty ? _selectedLocationName : null,
      latitude: _locationType == 1 ? _latitude : null,
      longitude: _locationType == 1 ? _longitude : null,
      radius: _locationType == 1 && _radius > 0 ? _radius : 1,
      createdAt: _requirementService.current?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _requirementService.saveRequirement(requirement);
    Get.back();
    Get.snackbar(
      'Success',
      'Your property requirements have been saved!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void _clearAll() {
    setState(() {
      _selectedPropertyTypes.clear();
      _selectedCategoryIds.clear();
      _selectedMinBedrooms = null;
      _selectedMinBathrooms = null;
      _minPrice = Constant.minPriceRange;
      _maxPrice = Constant.maxPriceRange;
      _minArea = Constant.minAreaRange;
      _maxArea = Constant.maxAreaRange;
      _locationType = 0;
      _selectedLocations.clear();
      _selectedLocationName = '';
      _latitude = null;
      _longitude = null;
      _radius = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Property Preferences',
          style: MyTextStyle.productLight(
            size: 20,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        actions: [
          if (_requirementService.hasRequirements)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      color: Get.theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Set your property preferences to get personalized recommendations and get notified when a property matches your criteria ',
                        style: MyTextStyle.productLight(
                          size: 14,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Location Section
              _buildSectionTitle('Where would you like to find property?'),
              const SizedBox(height: 8),
              _buildLocationSelector(),
              
              const SizedBox(height: 24),
                 
              // Property Type Section
              _buildSectionTitle('Property Types'),
              const SizedBox(height: 8),
              _buildPropertyTypeSelector(),
              
              const SizedBox(height: 24),
              // Price Range Section
              _buildSectionTitle('Budget Range'),
              const SizedBox(height: 8),
              _buildPriceRangeSelector(),
              
              // const SizedBox(height: 24),
              
              // // Area Range Section
              // _buildSectionTitle('Area Size'),
              // const SizedBox(height: 8),
              // _buildAreaRangeSelector(),
              
              // const SizedBox(height: 24),
           
              
              // Bedrooms & Bathrooms Section
              _buildSectionTitle('Bedrooms & Bathrooms'),
              const SizedBox(height: 8),
              _buildBedroomBathroomSelector(),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRequirement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.primary,
                    foregroundColor: Get.theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Obx(() => _requirementService.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Requirements',
                          style: MyTextStyle.productRegular(
                            size: 16,
                            color: Get.theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
                        style: MyTextStyle.productRegular(
                          size: 16,
                          fontWeight: FontWeight.w600,
                          color: Get.theme.colorScheme.primary,
                        ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search by city or enable location for nearby properties',
          style: MyTextStyle.productRegular(
            size: 14,
            color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),
        
        // Location Options
        Row(
          children: [
            Expanded(
              child: _buildLocationOptionCard(
                icon: Icons.location_city_rounded,
                title: 'Search by Cities',
                isSelected: _locationType == 0,
                onTap: () {
                  setState(() {
                    _locationType = 0;
                    _selectedLocationName = '';
                    _latitude = null;
                    _longitude = null;
                    _radius = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLocationOptionCard(
                icon: Icons.my_location_rounded,
                title: 'Search by Location',
                isSelected: _locationType == 1,
                onTap: () {
                  setState(() {
                    _locationType = 1;
                    _selectedLocationName = '';
                    _latitude = null;
                    _longitude = null;
                    _radius = 0;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // City Selection (when location type is 0)
        if (_locationType == 0) ...[
          _buildCitySelector(),
        ],

        // Location Selection (when location type is 1)
        if (_locationType == 1) ...[
          _buildLocationPicker(),

          const SizedBox(height: 24),

          // Radius Selector
          Text(
            'Search Radius',
            style: MyTextStyle.productMedium(size: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_radius.toInt()}',
                      style: MyTextStyle.productBold(size: 24),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'km',
                      style: MyTextStyle.productMedium(
                        size: 16,
                        color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    min: Constant.minRadius,
                    max: Constant.maxRadius,
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                      });
                    },
                    value: _radius,
                    activeColor: Get.theme.colorScheme.primary,
                    inactiveColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _RangeCard(
                range: _minPrice,
                onChanged: (value) {
                  setState(() {
                    _minPrice = double.parse(value);
                  });
                },
                minValue: Constant.minPriceRange,
                maxValue: _maxPrice,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'To',
              style: MyTextStyle.productLight(size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RangeCard(
                range: _maxPrice,
                onChanged: (value) {
                  setState(() {
                    _maxPrice = double.parse(value);
                  });
                },
                minValue: _minPrice,
                maxValue: Constant.maxPriceRange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            labels: RangeLabels(
              _minPrice.toInt().numberFormat.toString(),
              _maxPrice.toInt().numberFormat.toString(),
            ),
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
            min: Constant.minPriceRange,
            max: Constant.maxPriceRange,
            activeColor: Get.theme.colorScheme.primary,
            inactiveColor: Get.theme.colorScheme.primary.withOpacity(0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Selected types
          if (_selectedPropertyTypes.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedPropertyTypes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final type = entry.value;
                  final categoryId = index < _selectedCategoryIds.length ? _selectedCategoryIds[index] : '';
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type,
                              style: MyTextStyle.productLight(
                                size: 12,
                                color: Get.theme.colorScheme.onPrimary,
                              ),
                            ),
                            // if (categoryId.isNotEmpty)
                            //   Text(
                            //     'ID: $categoryId',
                            //     style: MyTextStyle.productLight(
                            //       size: 10,
                            //       color: Get.theme.colorScheme.onPrimary.withOpacity(0.8),
                            //     ),
                            //   ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final typeIndex = _selectedPropertyTypes.indexOf(type);
                              _selectedPropertyTypes.remove(type);
                              if (typeIndex < _selectedCategoryIds.length) {
                                _selectedCategoryIds.removeAt(typeIndex);
                              }
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Get.theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // Add type button or loading state
          InkWell(
            onTap: _availablePropertyTypes.isNotEmpty ? _showPropertyTypePicker : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: Get.theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _availablePropertyTypes.isEmpty
                        ? Text(
                            'Loading property types...',
                            style: MyTextStyle.productLight(
                              size: 14,
                              color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          )
                        : Text(
                            _selectedPropertyTypes.isEmpty 
                                ? 'Add property types'
                                : 'Add more types',
                            style: MyTextStyle.productLight(
                              size: 14,
                              color: Get.theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  if (_availablePropertyTypes.isNotEmpty)
                    Icon(
                      CupertinoIcons.forward,
                      color: Get.theme.colorScheme.primary,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _AreaRangeCard(
                range: _minArea,
                onChanged: (value) {
                  setState(() {
                    _minArea = double.parse(value);
                  });
                },
                minValue: Constant.minAreaRange,
                maxValue: _maxArea,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'To',
              style: MyTextStyle.productLight(size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AreaRangeCard(
                range: _maxArea,
                onChanged: (value) {
                  setState(() {
                    _maxArea = double.parse(value);
                  });
                },
                minValue: _minArea,
                maxValue: Constant.maxAreaRange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: RangeSlider(
            values: RangeValues(_minArea, _maxArea),
            labels: RangeLabels(
              _minArea.toInt().toString(),
              _maxArea.toInt().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _minArea = values.start;
                _maxArea = values.end;
              });
            },
            min: Constant.minAreaRange,
            max: Constant.maxAreaRange,
            activeColor: Get.theme.colorScheme.primary,
            inactiveColor: Get.theme.colorScheme.primary.withOpacity(0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildBedroomBathroomSelector() {
    return Row(
      children: [
        Expanded(
          child: _BathBedCard(
            title: 'Bedrooms',
            list: CommonFun.getBedRoomList(),
            selectedValue: _selectedMinBedrooms,
            onChange: (value) {
              setState(() {
                _selectedMinBedrooms = value;
              });
            },
            isResident: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _BathBedCard(
            title: 'Bathrooms',
            list: CommonFun.getBathRoomList(),
            selectedValue: _selectedMinBathrooms,
            onChange: (value) {
              setState(() {
                _selectedMinBathrooms = value;
              });
            },
            isResident: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationOptionCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Get.theme.colorScheme.primary.withOpacity(0.1)
                : Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.onBackground.withOpacity(0.6),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: MyTextStyle.productMedium(
                  size: 14,
                  color: isSelected
                      ? Get.theme.colorScheme.primary
                      : Get.theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Selected cities
          if (_selectedLocations.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedLocations.map((location) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          location,
                          style: MyTextStyle.productRegular(
                            size: 12,
                            color: Get.theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLocations.remove(location);
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Get.theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // Add city button
          InkWell(
            onTap: _showLocationPicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.add_location_outlined,
                    color: Get.theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedLocations.isEmpty 
                        ? 'Add preferred cities'
                        : 'Add more cities',
                    style: MyTextStyle.productRegular(
                      size: 14,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    CupertinoIcons.forward,
                    color: Get.theme.colorScheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Get.theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onLocationCardClick,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: Get.theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedLocationName.isNotEmpty
                        ? _selectedLocationName
                        : 'Search city or enable location',
                    style: MyTextStyle.productRegular(
                      size: 16,
                      color: _selectedLocationName.isNotEmpty
                          ? Get.theme.colorScheme.onBackground
                          : Get.theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedLocationName.isNotEmpty)
                  Icon(
                    Icons.check_circle,
                    color: Get.theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLocationCardClick() async {
    if (_locationType == 0) {
      // Search by cities - show city picker
      _showLocationPicker();
    } else {
      // Search by location - use the same map picker as search screen
      Get.to(() => PickMapScreen(
        fromAddAddress: false, 
        fromLandingPage: true,
        onPicked: (place) {
          setState(() {
            _selectedLocationName = place.description;
            _latitude = double.tryParse(place.latitude ?? '');
            _longitude = double.tryParse(place.longitude ?? '');
          });
        }
      ));
    }
  }

  Future<void> _showLocationPicker() async {
    // Directly open the search screen for city selection
    final place = await Get.toNamed('/search-place');
    if (place != null) {
      final placeModel = place as PlaceModel;
      final cityName = placeModel.city ?? placeModel.description;
      if (!_selectedLocations.contains(cityName)) {
        setState(() {
          _selectedLocations.add(cityName);
        });
      }
    }
  }

  void _showPropertyTypePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PropertyTypePickerSheet(
        availableTypes: _availablePropertyTypes,
        selectedTypes: _selectedPropertyTypes,
        onSelectionChanged: (types) {
          setState(() {
            _selectedPropertyTypes.clear();
            _selectedCategoryIds.clear();
            _selectedPropertyTypes.addAll(types);
            
            // Collect corresponding category IDs
            for (String type in types) {
              final typeMap = _availablePropertyTypes.firstWhere(
                (map) => map['title'] == type,
                orElse: () => {'id': '', 'title': type},
              );
              if (typeMap['id']!.isNotEmpty) {
                _selectedCategoryIds.add(typeMap['id']!);
              }
            }
          });
        },
      ),
    );
  }


}

// Property Type Picker Sheet
class _PropertyTypePickerSheet extends StatefulWidget {
  final List<Map<String, String>> availableTypes;
  final List<String> selectedTypes;
  final Function(List<String>) onSelectionChanged;

  const _PropertyTypePickerSheet({
    required this.availableTypes,
    required this.selectedTypes,
    required this.onSelectionChanged,
  });

  @override
  State<_PropertyTypePickerSheet> createState() => _PropertyTypePickerSheetState();
}

class _PropertyTypePickerSheetState extends State<_PropertyTypePickerSheet> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Select Property Types',
                  style: MyTextStyle.productRegular(
                      size: 18,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.primary,
                    ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onSelectionChanged(_tempSelected);
                    Get.back();
                  },
                  child: Text(
                    'Done',
                    style: MyTextStyle.productRegular(
                      size: 16,
                      color: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Types list
          Expanded(
            child: widget.availableTypes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Get.theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading property types...',
                          style: MyTextStyle.productRegular(
                            size: 16,
                            color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.availableTypes.length,
                    itemBuilder: (context, index) {
                      final typeMap = widget.availableTypes[index];
                      final typeTitle = typeMap['title'] ?? '';
                      final typeId = typeMap['id'] ?? '';
                      final isSelected = _tempSelected.contains(typeTitle);
                      Get.log('typesss: $typeMap');
                      
                      return CheckboxListTile(
                        title: Text(
                          typeTitle,
                          style: MyTextStyle.productLight(size: 16),
                        ),
                        subtitle: Text(
                          'ID: $typeId',
                          style: MyTextStyle.productLight(size: 12, color: Get.theme.colorScheme.outline),
                        ),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _tempSelected.add(typeTitle);
                            } else {
                              _tempSelected.remove(typeTitle);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


// Range Card Widget (from search screen)
class _RangeCard extends StatelessWidget {
  final double range;
  final Function(String)? onChanged;
  final double minValue;
  final double maxValue;

  const _RangeCard({
    required this.range,
    this.onChanged,
    required this.minValue,
    required this.maxValue,
  });

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: range.toInt().numberFormat.toString()
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Price',
                style: MyTextStyle.productBold(size: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: MyTextStyle.productMedium(size: 18),
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: MyTextStyle.productMedium(
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = controller.text.replaceAll(',', '');
                        if (double.tryParse(value) != null) {
                          final numValue = double.parse(value);
                          if (numValue >= minValue && numValue <= maxValue) {
                            onChanged?.call(value);
                            Get.back();
                          } else {
                            Get.snackbar(
                              'Invalid Value',
                              'Please enter a value between ${minValue.toInt()} and ${maxValue.toInt()}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: MyTextStyle.productMedium(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged != null ? () => _showEditDialog(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.outline,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: Get.width / 8.5,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: CommonFun.getRadius(
                  radius: 8,
                  isRTL: Directionality.of(context) == TextDirection.rtl,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                Constant.currencySymbol,
                style: MyTextStyle.productMedium(size: 22, color: Get.theme.colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    range.toInt().numberFormat.toString(),
                    style: MyTextStyle.productMedium(color: Get.theme.colorScheme.primary, size: 17),
                  ),
                  if (onChanged != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Get.theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bath Bed Card Widget (from search screen)
class _BathBedCard extends StatelessWidget {
  final String title;
  final List<dynamic> list;
  final dynamic selectedValue;
  final Function(String? value)? onChange;
  final bool isResident;

  const _BathBedCard({
    required this.title,
    required this.list,
    this.selectedValue,
    this.onChange,
    required this.isResident,
  });

  void _showBottomSheet(BuildContext context) {
    if (!isResident) return;
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Enhanced Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        title == 'Bedrooms' ? Icons.king_bed_rounded : Icons.shower_rounded,
                        color: Get.theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select $title',
                          style: MyTextStyle.productBold(size: 20),
                        ),
                        Text(
                          title == 'Bedrooms' ? 'How many bedrooms?' : 'Number of bathrooms',
                          style: MyTextStyle.productLight(
                            size: 14,
                            color: Get.theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      style: IconButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.background,
                        padding: const EdgeInsets.all(8),
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Get.theme.colorScheme.onBackground.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider with gradient
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Get.theme.colorScheme.primary.withOpacity(0.1),
                      Get.theme.colorScheme.primary.withOpacity(0.05),
                      Get.theme.colorScheme.outline.withOpacity(0.05),
                    ],
                  ),
                ),
              ),

              // Enhanced Options List
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: list.map((value) {
                      final isSelected = value.toString() == selectedValue?.toString();
                      
                      return InkWell(
                        onTap: () {
                          onChange?.call(value.toString());
                          Get.back();
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Get.theme.colorScheme.primary
                                : Get.theme.colorScheme.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Get.theme.colorScheme.primary
                                  : Get.theme.colorScheme.outline.withOpacity(0.1),
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Get.theme.colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Enhanced number indicator
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : Get.theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Number
                                      Text(
                                        value.toString(),
                                        style: MyTextStyle.productBold(
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : Get.theme.colorScheme.primary,
                                        ),
                                      ),
                                      // Icon overlay
                                      if (isSelected)
                                        Positioned(
                                          right: 4,
                                          bottom: 4,
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white.withOpacity(0.9),
                                            size: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Enhanced content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            title == 'Bedrooms'
                                                ? Icons.bed_rounded
                                                : Icons.bathroom_rounded,
                                            size: 16,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.7)
                                                : Get.theme.colorScheme.onBackground.withOpacity(0.4),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            title == 'Bedrooms'
                                                ? '${value == "1" ? "Single Bedroom" : "$value Bedrooms"}'
                                                : '${value == "1" ? "Single Bathroom" : "$value Bathrooms"}',
                                            style: MyTextStyle.productMedium(
                                              size: 16,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Get.theme.colorScheme.onBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            size: 14,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.5)
                                                : Get.theme.colorScheme.onBackground.withOpacity(0.3),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getDescription(title, value.toString()),
                                            style: MyTextStyle.productLight(
                                              size: 13,
                                              color: isSelected
                                                  ? Colors.white.withOpacity(0.7)
                                                  : Get.theme.colorScheme.onBackground.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  String _getDescription(String type, String value) {
    if (type == 'Bedrooms') {
      switch (value) {
        case '1':
          return 'Studio or single bedroom setup';
        case '2':
          return 'Suitable for couples or small families';
        case '3':
          return 'Comfortable for families';
        case '4':
          return 'Spacious family home';
        default:
          return 'Large family residence';
      }
    } else {
      switch (value) {
        case '1':
          return 'Single bathroom unit';
        case '2':
          return 'Master and guest bathrooms';
        case '3':
          return 'Multiple bathroom setup';
        default:
          return 'Luxury configuration';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showBottomSheet(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isResident 
                  ? Get.theme.colorScheme.primary.withOpacity(0.2)
                  : Get.theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            color: isResident ? null : Get.theme.colorScheme.background.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            title == 'Bedrooms' 
                                ? Icons.king_bed_rounded 
                                : Icons.shower_rounded,
                            color: Get.theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: MyTextStyle.productMedium(
                            size: 14,
                            color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    
                    // Selected Value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedValue?.toString() ?? 'Select',
                          style: selectedValue != null
                              ? MyTextStyle.productBold(
                                  size: 24,
                                  color: Get.theme.colorScheme.primary,
                                )
                              : MyTextStyle.productLight(
                                  size: 16,
                                  color: Get.theme.colorScheme.onBackground.withOpacity(0.5),
                                ),
                        ),
                        if (selectedValue != null)
                          Text(
                            title == 'Bedrooms'
                                ? '${selectedValue == "1" ? "Bedroom" : "Bedrooms"}'
                                : '${selectedValue == "1" ? "Bathroom" : "Bathrooms"}',
                            style: MyTextStyle.productLight(
                              size: 14,
                              color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tap indicator
              if (isResident)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
  }
}

// Area Range Card Widget (similar to RangeCard but for area)
class _AreaRangeCard extends StatelessWidget {
  final double range;
  final Function(String)? onChanged;
  final double minValue;
  final double maxValue;

  const _AreaRangeCard({
    required this.range,
    this.onChanged,
    required this.minValue,
    required this.maxValue,
  });

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: range.toInt().toString()
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Area',
                style: MyTextStyle.productBold(size: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: MyTextStyle.productMedium(size: 18),
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: MyTextStyle.productMedium(
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = controller.text.replaceAll(',', '');
                        if (double.tryParse(value) != null) {
                          final numValue = double.parse(value);
                          if (numValue >= minValue && numValue <= maxValue) {
                            onChanged?.call(value);
                            Get.back();
                          } else {
                            Get.snackbar(
                              'Invalid Value',
                              'Please enter a value between ${minValue.toInt()} and ${maxValue.toInt()}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: MyTextStyle.productMedium(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged != null ? () => _showEditDialog(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.outline,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: Get.width / 8.5,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: CommonFun.getRadius(
                  radius: 8,
                  isRTL: Directionality.of(context) == TextDirection.rtl,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Sqft',
                style: MyTextStyle.productMedium(size: 22, color: Get.theme.colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    range.toInt().toString(),
                    style: MyTextStyle.productMedium(color: Get.theme.colorScheme.primary, size: 17),
                  ),
                  if (onChanged != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Get.theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
