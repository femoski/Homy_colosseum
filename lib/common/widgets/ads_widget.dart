import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/services/config_service.dart';

class BannerAdsWidget extends StatefulWidget {
  const BannerAdsWidget({super.key});

  @override
  State<BannerAdsWidget> createState() => _BannerAdsWidgetState();
}

class _BannerAdsWidgetState extends State<BannerAdsWidget> {
  BannerAd? _bannerAd;
  AuthService authService = AuthService();
  RxBool isSubscribed = false.obs;
  bool isFailed = false;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    getLocalData();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // TODO: replace this test ad unit with your own ad unit.
  String? adUnitId;

  final configService = ConfigService.getConfig();

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId ?? '',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isFailed = false;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          setState(() {
            isFailed = true;
          });
          Get.log('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    Get.log('isFailed: $isFailed');
    if (_bannerAd == null) {
      return const SizedBox.shrink();
    }

    if (isFailed) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  void getLocalData() async {
    Future.delayed(
      const Duration(milliseconds: 200),
      () async {
        final configService = await ConfigService.getConfig();
        adUnitId = Platform.isAndroid
            ? configService.adsModel.bannerIdAndroid
            : configService.adsModel.bannerIdIos;
        setState(() {});

        if (configService.adsModel.getIsAdsEnabled) {
          Get.log('ads is enabled');
          if (!_authService.user.value.isSubscribed) {
            loadAd();
          }
        }
      },
    );
  }
}

class InterstitialAdsService {
  static final shared = InterstitialAdsService();
  InterstitialAd? interstitialAd;
  final AuthService _authService = Get.find<AuthService>();
  int _requestCount = 0;
  bool _isLoading = false;

  loadingInterstitialAd(String? adUnitId) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId ?? 'NO Ads ID',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint('onAdShowedFullScreenContent');
              },
              onAdImpression: (ad) {
                debugPrint('onAdImpression');
              },
              onAdFailedToShowFullScreenContent: (ad, err) {
                debugPrint('onAdFailedToShowFullScreenContent: $err');
                ad.dispose();
                interstitialAd = null;
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                interstitialAd = null;
                debugPrint('onAdDismissedFullScreenContent');
              },
              onAdClicked: (ad) {
                debugPrint('onAdClicked');
              },
            );

            Get.log('Interstitial ad loaded successfully');
            interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            Get.log('InterstitialAd failed to load: $error');
            interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      Get.log('Error loading interstitial ad: $e');
      interstitialAd = null;
    } finally {
      _isLoading = false;
    }
  }

  void loadAd() async {
    if (_isLoading) return;
    
    final configService = await ConfigService.getConfig();
    String? adUnitId = Platform.isAndroid
        ? configService.adsModel.intersialIdAndroid
        : configService.adsModel.intersialIdIos;

    int interstitialAdInterval = configService.adsModel.getInterstitialAdInterval;
    bool isInterstitialAdEnabled = configService.adsModel.getIsInterstitialAdEnabled;

    if (adUnitId == null) {
      Get.log('No Ads ID');
      return;
    }

    if (interstitialAd != null) {
      Get.log('InterstitialAd already loaded');
      return;
    }

    if (configService.adsModel.getIsAdsEnabled && isInterstitialAdEnabled) {
      if (!_authService.user.value.isSubscribed) {
        _requestCount++;
        if (_requestCount >= interstitialAdInterval) {
          await loadingInterstitialAd(adUnitId);
          _requestCount = 0;
        }
      }
    }
  }

  Future<void> showInterstitialAds() async {
    final configService = await ConfigService.getConfig();
    if (!configService.adsModel.getIsAdsEnabled || _authService.user.value.isSubscribed) {
      return;
    }

    if (interstitialAd == null) {
      Get.log('No interstitial ad available to show');
      return;
    }

    try {
      await interstitialAd?.show();
    } catch (e) {
      Get.log('Error showing interstitial ad: $e');
      interstitialAd = null;
    }
  }

  Future<void> show() async {
    if (interstitialAd == null || _authService.user.value.isSubscribed) {
      Get.back();
      return;
    }

    try {
      await interstitialAd?.show();
      Get.back();
    } catch (e) {
      Get.log('Error showing interstitial ad: $e');
      interstitialAd = null;
      Get.back();
    }
  }
}
