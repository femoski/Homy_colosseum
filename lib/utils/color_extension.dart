import 'package:flutter/material.dart';

extension ColorExtension on BuildContext {
  _ColorPalette get color => _ColorPalette(this);
}

class _ColorPalette {
  final BuildContext context;
  
  _ColorPalette(this.context);

  Color get primaryColor => Theme.of(context).primaryColor;
  Color get secondaryColor => Theme.of(context).colorScheme.secondary;
  Color get tertiaryColor => Theme.of(context).colorScheme.tertiary;
} 