import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/agent_model.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/dashboard/widgets/agent_card.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/utils/constants/sizes.dart';

import '../../agents/views/featured_agent.dart';

class FeaturedAgentsWidget extends GetView<HomeScreenController> {
  const FeaturedAgentsWidget({super.key});

  static final List<AgentModel> agents = [
    AgentModel(
      id: "1",
      name: "John Smith",
      image: "https://picsum.photos/200/200?random=1",
      email: "john@example.com",
      phone: "+234 123 456 7890",
      propertyCount: 15,
      description: "Luxury property specialist with 10 years experience",
      isVerified: true,
      rating: 4.8,
      reviewCount: 124,
    ),
    AgentModel(
      id: "2",
      name: "Sarah Johnson",
      image: "https://picsum.photos/200/200?random=2",
      email: "sarah@example.com",
      phone: "+234 123 456 7891",
      propertyCount: 23,
      description: "Commercial property expert",
      isVerified: true,
      rating: 4.9,
      reviewCount: 89,
    ),
    AgentModel(
      id: "3",
      name: "Michael Brown",
      image: "https://picsum.photos/200/200?random=3",
      email: "michael@example.com",
      phone: "+234 123 456 7892",
      propertyCount: 18,
      description: "Residential property specialist",
      isVerified: true,
      rating: 4.7,
      reviewCount: 156,
    ),
    AgentModel(
      id: "4",
      name: "Emma Wilson",
      image: "https://picsum.photos/200/200?random=4",
      email: "emma@example.com",
      phone: "+234 123 456 7893",
      propertyCount: 12,
      description: "New construction and modern homes expert",
      isVerified: false,
      rating: 4.6,
      reviewCount: 78,
    ),
    AgentModel(
      id: "5",
      name: "David Clark",
      image: "https://picsum.photos/200/200?random=5",
      email: "david@example.com",
      phone: "+234 123 456 7894",
      propertyCount: 20,
      description: "Investment property consultant",
      isVerified: true,
      rating: 4.9,
      reviewCount: 143,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'featured_agents',
      builder: (controller) {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeader(
          title: "Featured Agents",
          onSeeAll: () {
            Get.toNamed('/all-featured-agent');
            // Get.toNamed(Routes.agentListScreen);
          },
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            itemCount: controller.featuredAgents.length.clamp(0, 5),
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final agent = controller.featuredAgents[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/featured-agent/${agent.id}', arguments: agent);
                  // Get.to(() => FeaturedAgent());
                },
                child: AgentCard(
                  agent: agent,
                  propertyCount: agent.propertyCount,
                  name: agent.name,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20), // Bottom spacing
      ],
    );
    });
  }
}
