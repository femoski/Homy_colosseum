
import 'package:flutter/cupertino.dart';
import 'package:homy/utils/my_text_style.dart';

class PropertyHeading extends StatelessWidget {
  final String title;

  const PropertyHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            title,
            style: MyTextStyle.productMedium(size: 16).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
