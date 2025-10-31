import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../utils/constants/sizes.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.lottie,
    required this.title,
    required this.subtitle,
  });

  final Future<Uint8List> lottie;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<Uint8List>(
            future: lottie,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Lottie.memory(
                  snapshot.data!,
                  height: MediaQuery.of(context).size.height * 0.4,
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.smd),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
