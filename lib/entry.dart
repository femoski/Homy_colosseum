import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:homy/app_pages.dart';
import 'package:homy/bindings.dart';
// import 'package:homy/services/ads_service.dart';
// import 'package:homy/services/deep_link_service.dart';
// import 'package:homy/services/websocket_service.dart';
import 'package:homy/utils/theme/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

class App extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  const App({super.key, required this.languages});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    _intializeservices();
  }

  void _intializeservices()async {
  // Initialize for specific locales
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('ar', null),
    // Add other locales as needed
  ]);
  
  }


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Homy',
      debugShowCheckedModeBanner: false,
      themeMode: MAppTheme.getThemeMode(),
      theme: MAppTheme.lightTheme,
      darkTheme: MAppTheme.darkTheme,
      initialRoute: AppPages.INITIAL,
      initialBinding: GeneralBindings(),
      getPages: AppPages.routes,
    );
  }
}

