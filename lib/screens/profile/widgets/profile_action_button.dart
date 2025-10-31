import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';

class ProfileActionButton extends StatelessWidget {
  final VoidCallback onAddReel;
  final VoidCallback onAddProperty;

  const ProfileActionButton({
    super.key,
    required this.onAddReel,
    required this.onAddProperty,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: context.theme.colorScheme.primary,
      foregroundColor: context.theme.colorScheme.onPrimary,
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      spacing: 12,
      children: [
        _buildSpeedDialChild(
          label: 'Add Reel',
          icon: MImages.icReelsIcon,
          onTap: onAddReel,
        ),
        _buildSpeedDialChild(
          label: 'Add Property',
          icon: MImages.homeDashboardIcon,
          onTap: onAddProperty,
        ),
      ],
    );
  }

  SpeedDialChild _buildSpeedDialChild({
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return SpeedDialChild(
      onTap: onTap,
      labelWidget: _ActionLabel(
        icon: icon,
        label: label,
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  final String icon;
  final String label;

  const _ActionLabel({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            color: context.theme.colorScheme.onPrimary,
            height: 20,
            width: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: MyTextStyle.productMedium(
              color: context.theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
} 