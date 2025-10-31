import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeTopView extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onResetCityBtn;
  final String address;
  final bool isResetBtnVisible;

  const HomeTopView(
      {super.key,
      required this.onTap,
      required this.address,
      required this.onResetCityBtn,
      required this.isResetBtnVisible});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surface,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select City',
                        style: Get.textTheme.bodyMedium!.copyWith(fontSize: 20, color: context.theme.colorScheme.primary)
                      ),
                      Visibility(
                        visible: isResetBtnVisible,
                        child: InkWell(
                          onTap: onResetCityBtn,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                            decoration:
                                BoxDecoration(color: context.theme.colorScheme.surface, borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              'Reset',
                              style: Get.textTheme.bodyMedium!.copyWith(fontSize: 16, color: context.theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: onTap,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            '$address ',
                            style: Get.textTheme.bodyMedium?.copyWith(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                         Icon(
                          Icons.arrow_drop_down_rounded,
                          color: context.theme.colorScheme.primary,
                          size: 35,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TopIcon(
              icon: Icons.search,
              onTap: () {
                // NavigateService.push(context, const SearchScreen());
              },
            ),
            const SizedBox(
              width: 7,
            ),
            TopIcon(
              icon: Icons.notifications,
              onTap: () {
                // NavigateService.push(Get.context!, const NotificationScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TopIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const TopIcon({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.theme.colorScheme.primary, width: 1.5),
        ),
        child: Icon(
          icon,
          size: 23,
          color: context.theme.colorScheme.primary,
        ),
      ),
    );
  }
}
