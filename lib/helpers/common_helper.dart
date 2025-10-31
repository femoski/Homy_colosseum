import 'package:flutter/material.dart';

class CommonHelper {
  static Widget showLoaderSpinner(Color backgroundColor) {
    return Container(
      color: backgroundColor,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 