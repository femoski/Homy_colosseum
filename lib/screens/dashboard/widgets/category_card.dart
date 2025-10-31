
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/category.dart';
import 'package:homy/utils/extentions/extentions.dart';
import 'package:homy/utils/helpers/design_helper.dart';
import 'package:homy/utils/responsiveSize.dart';
import 'package:homy/utils/ui.dart';



class CategoryCard extends StatelessWidget {
  final bool? frontSpacing;
  final Function(Category category) onTapCategory;
  final Category category;
  const CategoryCard(
      {super.key,
      required this.frontSpacing,
      required this.onTapCategory,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: frontSpacing == true ? 5.0 : 0,
        end: .0,
      ),
      child: GestureDetector(
        onTap: () {
          onTapCategory.call(category);
        },
        child: Row(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                minWidth: 100.rw(context),
              ),
              height: 44.rh(context),
              alignment: Alignment.center,
              decoration: DesignConfig.boxDecorationBorder(
                color: context.theme.colorScheme.surface,
                radius: 10,
                borderWidth: 1.5,
                borderColor: context.theme.colorScheme.outline,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ui.imageType(category.image!,
                        width: 20,
                        height: 20,
                        color: context.theme.colorScheme.tertiary
                        ),
                    SizedBox(width: 12.rw(context)),
                    SizedBox(
                      child: Text(category.title!,
                      // style: TextStyle(color: context.theme.colorScheme.outline),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis)
                          .size(14.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
