import 'package:flutter/material.dart';
import 'package:homy/utils/constants/image_string.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';

class MLoginHeader extends StatelessWidget {
  const MLoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(height: 100, image: AssetImage(MImages.logo)),
        Text(MTexts.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: AppSizes.xxs),
        Text(MTexts.loginSubTitle,
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}