import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/screens/dispute/controllers/dispute_list_controller.dart';
import 'package:homy/screens/dispute/widgets/dispute_card.dart';

class DisputeListScreen extends GetView<DisputeListController> {
  const DisputeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputes'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return Center(
            child: Text(
              controller.error.value ?? 'An error occurred',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (controller.disputes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonUI.noDataFound(
                  height: 150,
                  width: 150,
                  title: 'No disputes found',
                  subTitle: 'You have no active disputes',
                ),
                const SizedBox(height: 16),
                
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.disputes.length,
          itemBuilder: (context, index) {
            final dispute = controller.disputes[index];
            return DisputeCard(
              dispute: dispute,
              onTap: () => controller.onDisputeTap(dispute),
            );
          },
        );
      }),
    );
  }
} 