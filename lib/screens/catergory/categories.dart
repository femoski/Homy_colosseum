import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/category.dart';
import 'package:homy/screens/catergory/controllers/categories_controller.dart';
import 'package:homy/utils/ui.dart';


class CategoryList extends GetView<CategoriesController> {
  const CategoryList({super.key, this.from});
  final String? from;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: GetBuilder<CategoriesController>(
        builder: (controller) => AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(
              controller.isSearchMode.value ? Icons.arrow_back : Icons.arrow_back_ios,
              size: 20,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () {
              if (controller.isSearchMode.value) {
                controller.toggleSearchMode();
              } else {
                Get.back();
              }
            },
          ),
          title: _buildAppBarTitle(context),
          actions: [
            IconButton(
              icon: Icon(
                controller.isSearchMode.value ? Icons.close : Icons.search,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              onPressed: () => controller.toggleSearchMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return controller.isSearchMode.value
        ? _buildSearchField(context)
        : Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search categories...',
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1,
          ),
        ),
        // contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        // prefixIcon: Icon(
        //   Icons.search,
        //   color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
        //   size: 20,
        // ),
      ),
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 16,
      ),
      onChanged: controller.searchCategories,
    );
  }    
    
  }

  Widget _buildBody(BuildContext context) {
    return GetBuilder<CategoriesController>(
      builder: (controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!controller.isSearchMode.value) ...[
              const SizedBox(height: 10),
              Text(
                'Find your perfect property type',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return _buildCategoryItem(context, category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.toNamed('/Categories/${category.id}/${category.slug}', arguments: {
              'catID': category.id,
              'catName': category.title,
            });
            // Implement category selection
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Ui.imageType(
                    category.image!,
                     color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

