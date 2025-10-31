import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../dashboard/controller/home_screen_controller.dart';
import '../../dashboard/widgets/agent_card.dart';

class AllFeaturedAgentsPage extends StatelessWidget {
  AllFeaturedAgentsPage({Key? key}) : super(key: key);

  final HomeScreenController homeController = Get.find<HomeScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Featured Agents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<HomeScreenController>(
        id: 'featured_agents',
        builder: (controller) => controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  controller: controller.featuredAgentsScrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                    itemCount: controller.featuredAgents.length,
                  itemBuilder: (context, index) {
                    final agent = controller.featuredAgents[index];
                    return
                    GestureDetector(
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
      ),
    );
  }
}
