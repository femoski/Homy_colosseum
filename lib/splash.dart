import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/screens/update/update_screen.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/services/location_service.dart';
import 'package:homy/screens/maintenance/maintenance_screen.dart';
import 'package:homy/utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:homy/services/solana_exchange_service.dart';
import 'package:homy/services/solana_wallet_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late GetStorage _box;
  // final locationService = Get.find<LocationService>();
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _box = GetStorage();
    init();
  }

  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> init() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final hasConnection = await checkConnectivity();
    if (!hasConnection) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      final configService = await ConfigService.getConfig();
      final locationService = await LocationService.getLocation();

      if (configService.isMaintenanceMode) {
        Get.offAll(() => const MaintenanceScreen());
        return;
      }
      
      await checkUpdate();

       Get.put(SolanaExchangeService());
 Get.put(SolanaWalletService());

      if (!_box.hasData('isFirstTime')) {
        _box.write('isFirstTime', true);
        Get.offNamed('/OnBoardingscreen');
      } else if (locationService.place.value.city != null) {
        Get.offNamed('/root');
      } else {
        Get.offNamed('/location-permission');
      }
    } catch (e) {
      Get.log('Error in SplashScreen: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  checkUpdate() async {
    final configService = await ConfigService.getConfig();

    double? minimumVersion = 0;
    const appVersion = Constants.appVersion;

    if(GetPlatform.isAndroid) {
      minimumVersion = configService.appVersion.appMinimumVersionAndroid;
    }else if(GetPlatform.isIOS) {
      minimumVersion = configService.appVersion.appMinimumVersionIos;
    }

 

    if(appVersion < minimumVersion) {
         Get.log('minimumVersion: $minimumVersion');
    Get.log('appVersion: $appVersion');
      Get.off(() => const UpdateScreen(isUpdate: true));
      throw Exception('Update Required');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 70,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 50),
              if (_hasError) ...[
                // Lottie.asset(
                //   'assets/lottie/no_internet.json',
                //   width: 200,
                //   height: 200,
                //   fit: BoxFit.contain,
                // ),
                const SizedBox(height: 24),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontFamily: 'NeueMontreal',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your connection and try again',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontFamily: 'NeueMontreal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: init,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NeueMontreal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Welcome to Homy',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontFamily: 'NeueMontreal',
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Luxury Living Made Simple',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    letterSpacing: 0.5,
                    fontFamily: 'NeueMontreal',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(flex: 2),
              if (_isLoading)
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

