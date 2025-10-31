import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/agent_model.dart';
import 'package:homy/utils/ui.dart';

class AgentCard extends StatelessWidget {
  const AgentCard({
    required this.agent,
    required this.propertyCount,
    required this.name,
    super.key,
    this.isFirst,
    this.showEndPadding,
  });

  final AgentModel agent;
  final bool? isFirst;
  final bool? showEndPadding;
  final String name;
  final int propertyCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: context.theme.colorScheme.surface,
        border: Border.all(
          width: 1.5,
          color: context.theme.colorScheme.outline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      width: 155,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    color: context.theme.colorScheme.surface,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Ui.getImage(
                    agent.image ?? "",
                    fit: BoxFit.cover,
                  ),
                ),
                if (agent.isVerified)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        // color: context.theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (agent.rating > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: context.theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              agent.rating.toString(),
                              style: Get.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Properties($propertyCount)',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: context.theme.colorScheme.onSurface.withOpacity(0.7),
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
}
