import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/agent_model.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import '../../../utils/constants/sizes.dart';
import '../../dashboard/widgets/property_card.dart';
import '../controllers/featured_agent_controller.dart';

class FeaturedAgent extends GetView<FeaturedAgentController> {
  // const FeaturedAgent({super.key});
  final AgentModel agent = Get.arguments;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeaturedAgentController>(
      id: 'agent',
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "${agent.name}'s Properties",
              style: Get.textTheme.titleLarge,
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Agent Info Card
              Container(
                padding: const EdgeInsets.all(AppSizes.sidePadding),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(controller.agent?.image ?? ''),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                controller.agent?.name ?? '',
                                style: Get.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (controller.agent?.isVerified ?? false)
                                Icon(
                                  Icons.verified,
                                  color: Get.theme.colorScheme.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${controller.agent?.propertyCount ?? 0} Properties',
                            style: Get.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Updated Properties List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: controller.properties.isEmpty && controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.properties.isEmpty
                          ? Center(
                              child: CommonUI.noDataFound(
                                width: 150,
                                height: 150,
                                title: 'No properties found',
                              ),
                            )
                          : ListView.builder(
                              controller: controller.scrollController,
                              padding: const EdgeInsets.all(AppSizes.sidePadding),
                              itemCount: controller.properties.length +
                                  (controller.hasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == controller.properties.length) {
                                  return controller.isLoading
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : const SizedBox();
                                }

                                final property = controller.properties[index];
                                return PropertyHorizontalCard(
                                  property: property,
                                  // margin: const EdgeInsets.only(bottom: 16),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}