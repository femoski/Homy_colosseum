import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/auth/terms_of_service_screen.dart';
import 'package:homy/services/terms_service.dart';

class TermsMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final termsService = Get.find<TermsService>();
    
    if (!termsService.isTermsAccepted) {
      return const RouteSettings(name: '/terms');
    }
    return null;
  }
} 