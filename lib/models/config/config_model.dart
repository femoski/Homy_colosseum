import 'package:homy/utils/app_constant.dart';

class ConfigModel {
  final String? name;
  final String? keywords;
  final String? email;
  final String? description;
  final String? timezone;
  final bool? maintenance;
  final String? message;
  final String? address;
  final String? phone;
  final CentralizeLogin centralizeLogin;
  final UploadConfig uploadConfig;
  final SocialMedia socialMedia;
  final AdsModel adsModel;
  final AppVersion appVersion;
  final String? serviceFee;
  final String? currencySymbol;
  final String? commissionType;
  final String? commissionValue;
  final Payments payments;
  final ChatConfig chatConfig;
  final SupportConfig supportConfig;
  final AppConfig appConfig;
  ConfigModel({
    this.name,
    this.keywords,
    this.email,
    this.description,
    this.timezone,
    this.maintenance,
    this.message,
    this.address,
    this.phone,
    required this.centralizeLogin,
    required this.uploadConfig,
    required this.socialMedia,
    required this.adsModel,
    required this.appVersion,
    this.serviceFee,
    this.currencySymbol,
    this.commissionType,
    this.commissionValue,
    required this.payments,
    required this.chatConfig,
    required this.supportConfig,
    required this.appConfig,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      name: json['name'],
      keywords: json['keywords'],
      email: json['email'],
      description: json['description'] ?? '',
      timezone: json['timezone'],
      maintenance: json['maintenance'],
      message: json['message'],
      address: json['address'] ?? '',
      phone: json['phone'],
      centralizeLogin: CentralizeLogin.fromJson(json['centralize_login'] ?? {}),
      uploadConfig: UploadConfig.fromJson(json['upload'] ?? {}),
      socialMedia: SocialMedia.fromJson(json['social_media'] ?? {}),
      adsModel: AdsModel.fromJson(json['ads_model'] ?? {}),
      appVersion: AppVersion.fromJson(json['app_version'] ?? {}),
      serviceFee: json['service_fee'] ?? '200',
      currencySymbol: json['currency_symbol'] ?? Constant.currencySymbol,
      commissionType: json['commission_type'] ?? 'percentage',
      commissionValue: json['commission_value'] ?? '10',
      payments: Payments.fromJson(json['payment'] ?? {}),
      chatConfig: ChatConfig.fromJson(json['chat'] ?? {}),
      supportConfig: SupportConfig.fromJson(json['support'] ?? {}),
      appConfig: AppConfig.fromJson(json['app_config'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'keywords': keywords,
      'email': email,
      'description': description,
      'timezone': timezone,
      'maintenance': maintenance,
      'message': message,
      'address': address,
      'phone': phone,
      'centralize_login': centralizeLogin.toJson(),
      'upload': uploadConfig.toJson(),
      'social_media': socialMedia.toJson(),
      'ads_model': adsModel.toJson(),
      'app_version': appVersion.toJson(),
      'service_fee': serviceFee,
      'currency_symbol': currencySymbol,
      'commission_type': commissionType,
      'commission_value': commissionValue,
      'payments': payments.toJson(),
      'chat': chatConfig.toJson(),
      'support': supportConfig.toJson(),
      'app_config': appConfig.toJson(),
    };
  }

  // Getters for ConfigModel
  String get getName => name ?? '';
  String get getKeywords => keywords ?? '';
  String get getEmail => email ?? '';
  String get getDescription => description ?? '';
  String get getTimezone => timezone ?? 'UTC';
  bool get getMaintenance => maintenance ?? false;
  String get getMessage => message ?? '';
  AdsModel get getAdsModel => adsModel;
  AppVersion get getAppVersion => appVersion;
  String get getServiceFee => serviceFee ?? '0';
  String get getCurrencySymbol => currencySymbol ?? Constant.currencySymbol;
  
  String get getAddress => address ?? '';
  String get getPhone => phone ?? '';
  // Delegate getters for nested objects
  bool get isEmailVerificationEnabled => centralizeLogin.emailVerification;
  bool get isPhoneVerificationEnabled => centralizeLogin.phoneVerification;
  bool get isSmsVerificationEnabled => centralizeLogin.smsVerification;
  bool get isSocialLoginEnabled => centralizeLogin.socialLoginStatus;
  bool get isGoogleLoginEnabled => centralizeLogin.googleLoginStatus;
  bool get isFacebookLoginEnabled => centralizeLogin.facebookLoginStatus;
  bool get isWhatsappSmsEnabled => centralizeLogin.whatsappSmsStatus;
  
  double get getMaxUploadSize => uploadConfig.maxUploadSize ?? 5;
  double get getMaxVideoUploadSize => uploadConfig.maxVideoUploadSize ?? 10;
  double get getMaxAudioUploadSize => uploadConfig.maxAudioUploadSize ?? 10;
  double get getMaxDocumentUploadSize => uploadConfig.maxDocumentUploadSize ?? 25;
  String get getAllowedFileTypes => uploadConfig.allowedFileTypes;
  
  String get getFacebookUrl => socialMedia.facebook ?? '';
  String get getTwitterUrl => socialMedia.twitter ?? '';
  String get getInstagramUrl => socialMedia.instagram ?? '';
  String get getBannerIdAndroid => adsModel.bannerIdAndroid ?? '';
  String get getBannerIdIos => adsModel.bannerIdIos ?? '';
  String get getIntersialIdAndroid => adsModel.intersialIdAndroid ?? '';
  String get getIntersialIdIos => adsModel.intersialIdIos ?? '';
  bool get getIsInterstitialAdEnabled => adsModel.isInterstitialAdEnabled;
  String get getCommissionType => commissionType ?? 'percentage';
  String get getCommissionValue => commissionValue ?? '10';
  
  double get getMinimumWithdrawalAmount => payments.minimumWithdrawalAmount ?? 100;
  double get getMaximumWithdrawalAmount => payments.maximumWithdrawalAmount ?? 1000000;
  double get getWithdrawalFee => payments.withdrawalFee ?? 10;

  // Support Config Getters
  String get getChatServer => supportConfig.chatServer;
  String get getSupportId => supportConfig.supportId;
  String get getWhatsappNumber => supportConfig.whatsappNumber;
  String get getTawkId => supportConfig.tawkId;
  String get getOtherLinks => supportConfig.otherLinks;
  bool get getIsDisclaimerEnabled => chatConfig.isDisclaimerEnabled;
  String get getDisclaimerMessage => chatConfig.disclaimerMessage;
  String get getMaintenanceMessage => appConfig.maintenanceMessage;
  String get getUpdateMessage => appConfig.updateMessage;
  String get getUpdateTitle => appConfig.updateTitle;
}

class CentralizeLogin {
  final bool emailVerification;
  final bool phoneVerification;
  final bool smsVerification;
  final bool socialLoginStatus;
  final bool googleLoginStatus;
  final bool facebookLoginStatus;
  final bool whatsappSmsStatus;

  CentralizeLogin({
    this.emailVerification = true,
    this.phoneVerification = false,
    this.smsVerification = false,
    this.socialLoginStatus = false,
    this.googleLoginStatus = false,
    this.facebookLoginStatus = false,
    this.whatsappSmsStatus = false,
  });

  factory CentralizeLogin.fromJson(Map<String, dynamic> json) {
    return CentralizeLogin(
      emailVerification: json['email_verification'] ?? true,
      phoneVerification: json['phone_verification'] ?? false,
      smsVerification: json['sms_verification'] ?? false,
      socialLoginStatus: json['social_login_status'] ?? false,
      googleLoginStatus: json['google_login_status'] ?? false,
      facebookLoginStatus: json['facebook_login_status'] ?? false,
      whatsappSmsStatus: json['whatsapp_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_verification': emailVerification,
      'phone_verification': phoneVerification,
      'sms_verification': smsVerification,
      'social_login_status': socialLoginStatus,
      'google_login_status': googleLoginStatus,
      'facebook_login_status': facebookLoginStatus,
      'whatsapp_enabled': whatsappSmsStatus,
    };
  }

  // Getters
  bool get getEmailVerification => emailVerification;
  bool get getPhoneVerification => phoneVerification;
  bool get getSmsVerification => smsVerification;
  bool get getSocialLoginStatus => socialLoginStatus;
  bool get getGoogleLoginStatus => googleLoginStatus;
  bool get getFacebookLoginStatus => facebookLoginStatus;
  bool get getWhatsappSmsStatus => whatsappSmsStatus;
}

class UploadConfig {
    final double? maxUploadSize;
  final double? maxImageUploadSize;
  final double? maxVideoUploadSize;
  final double? maxAudioUploadSize;
  final double? maxDocumentUploadSize;
  final String allowedFileTypes;

  UploadConfig({
    this.maxUploadSize = 5,
    this.maxImageUploadSize = 10,
    this.maxVideoUploadSize = 10,
    this.maxAudioUploadSize = 10,
    this.maxDocumentUploadSize = 25,
    this.allowedFileTypes = 'jpg,jpeg,png,gif',
  });

  factory UploadConfig.fromJson(Map<String, dynamic> json) {
    return UploadConfig(
      maxUploadSize: json['max_upload_size']?.toDouble() ?? 5.0,
      maxImageUploadSize: json['max_image_upload_size']?.toDouble() ?? 10.0,
      maxVideoUploadSize: json['max_video_upload_size']?.toDouble() ?? 10.0,
      maxAudioUploadSize: json['max_audio_upload_size']?.toDouble() ?? 10.0,
      maxDocumentUploadSize: json['max_document_upload_size']?.toDouble() ?? 25.0,
      allowedFileTypes: json['allowed_file_types'] ?? 'jpg,jpeg,png,gif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_upload_size': maxUploadSize,
      'max_video_upload_size': maxVideoUploadSize,
      'max_audio_upload_size': maxAudioUploadSize,
      'max_document_upload_size': maxDocumentUploadSize,
      'allowed_file_types': allowedFileTypes,
    };
  }

  // Getters
  double get getMaxUploadSize => maxUploadSize ?? 5;
  double get getMaxVideoUploadSize => maxVideoUploadSize ?? 10;
  double get getMaxAudioUploadSize => maxAudioUploadSize ?? 10;
  double get getMaxDocumentUploadSize => maxDocumentUploadSize ?? 25;
  String get getAllowedFileTypes => allowedFileTypes;
}

class SocialMedia {
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? phone;
  final String? email;

  SocialMedia({
    this.facebook,
    this.twitter,
    this.instagram,
    this.phone,
    this.email,
  });


  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      facebook: json['facebook'],
      twitter: json['twitter'],
      instagram: json['instagram'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'phone': phone,
      'email': email,
    };
  }

  // Getters
  String get getFacebook => facebook ?? '';
  String get getTwitter => twitter ?? '';
  String get getInstagram => instagram ?? '';
  String get getPhone => phone ?? '';
  String get getEmail => email ?? '';
} 

class AdsModel {
  final bool isAdsEnabled;
  final String? bannerIdAndroid;
  final String? bannerIdIos;
  final String? intersialIdAndroid;
  final String? intersialIdIos;
  final bool isInterstitialAdEnabled;
  final int interstitialAdInterval;

  AdsModel({
    this.isAdsEnabled = false,
    this.bannerIdAndroid,
    this.bannerIdIos,
    this.intersialIdAndroid,
    this.intersialIdIos,
    this.isInterstitialAdEnabled = false,
    this.interstitialAdInterval = 3,
  });

  factory AdsModel.fromJson(Map<String, dynamic> json) {
    return AdsModel(
      isAdsEnabled: json['is_ads_enabled'] ?? false,
      bannerIdAndroid: json['banner_id_android'],
      bannerIdIos: json['banner_id_ios'],
      intersialIdAndroid: json['intersial_id_android'],
      intersialIdIos: json['intersial_id_ios'],
      isInterstitialAdEnabled: json['is_interstitial_ad_enabled']??false,
      interstitialAdInterval: json['interstitial_ad_interval']??3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_ads_enabled': isAdsEnabled,
      'banner_id_android': bannerIdAndroid,
      'banner_id_ios': bannerIdIos,
      'intersial_id_android': intersialIdAndroid,
      'intersial_id_ios': intersialIdIos,
      'is_interstitial_ad_enabled': isInterstitialAdEnabled,
      'interstitial_ad_interval': interstitialAdInterval,
    };
  }

  // Getters
  bool get getIsAdsEnabled => isAdsEnabled;
  String get getBannerIdAndroid => bannerIdAndroid ?? '';
  String get getBannerIdIos => bannerIdIos ?? '';
  String get getIntersialIdAndroid => intersialIdAndroid ?? '';
  String get getIntersialIdIos => intersialIdIos ?? '';
  bool get getIsInterstitialAdEnabled => isInterstitialAdEnabled;
  int get getInterstitialAdInterval => interstitialAdInterval;
  }

class AppVersion {
  final double appMinimumVersionAndroid;
  final double appMinimumVersionIos;
  final String appUrlAndroid;
  final String appUrlIos;

  AppVersion({this.appMinimumVersionAndroid = 0, this.appMinimumVersionIos = 0, this.appUrlAndroid = '', this.appUrlIos = ''});

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      appMinimumVersionAndroid: json['app_minimum_version_android'] ?? 0,
      appMinimumVersionIos: json['app_minimum_version_ios'] ?? 0,
      appUrlAndroid: json['app_url_android'] ?? '',
      appUrlIos: json['app_url_ios'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_minimum_version_android': appMinimumVersionAndroid,
      'app_minimum_version_ios': appMinimumVersionIos,
      'app_url_android': appUrlAndroid,
      'app_url_ios': appUrlIos,
    };
  }


}

class Payments {
  final double? minimumWithdrawalAmount;
  final double? maximumWithdrawalAmount;
  final double? minimumPointsForWithdrawal;
  final double? pointsPerNaira;
  final double? withdrawalFee;
  final bool? requirePinForWithdrawal;
  final String? currencySymbol;
  final String? solanaWalletAddress;
  final bool? enableSolanaPayments;
  final bool? enableBankWithdrawals;
  final bool? enableCreditCardPayments;
  final String? solanaRpcUrl;
  final String? solanaWebsocketUrl;
  final String? solanaCluster;
  final String? propertyCommissionValue;
  final String? propertyCommissionType;
  final bool? enablePropertyNft;  

  Payments({
    this.minimumWithdrawalAmount = 100,
    this.maximumWithdrawalAmount = 1000000,
    this.minimumPointsForWithdrawal = 100,
    this.pointsPerNaira = 100,
    this.withdrawalFee = 10,
    this.requirePinForWithdrawal = false,
    this.currencySymbol = '₦',
    this.solanaWalletAddress = '',
    this.enableSolanaPayments  = false,
    this.enableBankWithdrawals = false,
    this.enableCreditCardPayments = false,
    this.solanaRpcUrl = 'https://api.devnet.solana.com',
    this.solanaWebsocketUrl = 'wss://api.devnet.solana.com',
    this.solanaCluster = 'devnet',
    this.propertyCommissionValue = '0',
    this.propertyCommissionType = 'percentage',
    this.enablePropertyNft = false,

  });

  factory Payments.fromJson(Map<String, dynamic> json) {
    return Payments(
      minimumWithdrawalAmount: json['minimum_withdrawal_amount']?.toDouble() ?? 100,
      maximumWithdrawalAmount: json['maximum_withdrawal_amount']?.toDouble() ?? 1000000,
      minimumPointsForWithdrawal: json['minimum_points_for_withdrawal']?.toDouble() ?? 100,
      pointsPerNaira: json['points_per_naira']?.toDouble() ?? 100,
      withdrawalFee: json['withdrawal_fee']?.toDouble() ?? 10,
      requirePinForWithdrawal: json['require_pin_for_withdrawal'] ?? false,
      currencySymbol: json['currency_symbol'] ?? '₦',
      solanaWalletAddress: json['solana_wallet_address'] ?? '',
      enableSolanaPayments: json['enable_solana_payments'] ?? false,
      enableBankWithdrawals: json['enable_bank_withdrawals'] ?? false,
      enableCreditCardPayments: json['enable_credit_card_payments'] ?? false,
      solanaRpcUrl: json['solana_rpc_url'] ?? 'https://api.devnet.solana.com',
      solanaWebsocketUrl: json['solana_websocket_url'] ?? 'wss://api.devnet.solana.com',
      solanaCluster: json['solana_cluster'] ?? 'devnet',
      propertyCommissionValue: json['property_commission_value'] ?? '0',
      propertyCommissionType: json['property_commission_type'] ?? 'percentage',
      enablePropertyNft: json['enable_property_nft_minting'] ?? false,
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimum_withdrawal_amount': minimumWithdrawalAmount,
      'maximum_withdrawal_amount': maximumWithdrawalAmount,
      'minimum_points_for_withdrawal': minimumPointsForWithdrawal,
      'points_per_naira': pointsPerNaira,
      'withdrawal_fee': withdrawalFee,
      'require_pin_for_withdrawal': requirePinForWithdrawal,
      'currency_symbol': currencySymbol,
      'solana_wallet_address': solanaWalletAddress,
      'enable_solana_payments': enableSolanaPayments,
      'enable_bank_withdrawals': enableBankWithdrawals,
      'enable_credit_card_payments': enableCreditCardPayments,
      'solana_rpc_url': solanaRpcUrl,
      'solana_websocket_url': solanaWebsocketUrl,
      'solana_cluster': solanaCluster,
      'property_commission_value': propertyCommissionValue,
      'property_commission_type': propertyCommissionType,
      'enable_property_nft': enablePropertyNft,
    };
  }

  // Getters  
  double get getMinimumWithdrawalAmount => minimumWithdrawalAmount ?? 100;
  double get getMaximumWithdrawalAmount => maximumWithdrawalAmount ?? 1000000;
  double get getMinimumPointsForWithdrawal => minimumPointsForWithdrawal ?? 100;
  double get getPointsPerNaira => pointsPerNaira ?? 100;
  double get getWithdrawalFee => withdrawalFee ?? 50;
  bool get getRequirePinForWithdrawal => requirePinForWithdrawal ?? false;
  String get getCurrencySymbol => currencySymbol ?? '₦';
  String get getSolanaWalletAddress => solanaWalletAddress ?? '';
  bool get getEnableSolanaPayments => enableSolanaPayments ?? false;
  bool get getEnableBankWithdrawals => enableBankWithdrawals ?? false;
  bool get getEnableCreditCardPayments => enableCreditCardPayments ?? false;
  String get getSolanaRpcUrl => solanaRpcUrl ?? 'https://api.devnet.solana.com';
  String get getSolanaWebsocketUrl => solanaWebsocketUrl ?? 'wss://api.devnet.solana.com';
  String get getSolanaCluster => solanaCluster ?? 'devnet';
  String get getPropertyCommissionValue => propertyCommissionValue ?? '2';
  String get getPropertyCommissionType => propertyCommissionType ?? 'percentage';
  bool get getEnablePropertyNft => enablePropertyNft ?? false;
  }

class ChatConfig {
  final String server;
  final int port;
  final int sslPort;
  final String system;
  final bool isDisclaimerEnabled;
  final String disclaimerMessage;
  ChatConfig({
    this.server = 'localhost',
    this.port = 8080,
    this.sslPort = 8443,
    this.system = 'Websocket',
    this.isDisclaimerEnabled = true,
    this.disclaimerMessage = 'Please do not share sensitive information in this chat. Stay safe!',
  });

  factory ChatConfig.fromJson(Map<String, dynamic> json) {
    return ChatConfig(
      server: json['server'] ?? 'localhost',
      port: json['port'] ?? 8080,
      sslPort: json['ssl_port'] ?? 8443,
      system: json['system'] ?? 'Websocket',
      isDisclaimerEnabled: json['is_disclaimer_enabled'] ?? true,
      disclaimerMessage: json['disclaimer_message'] ?? 'Please do not share sensitive information in this chat. Stay safe!',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server': server,
      'port': port,
      'ssl_port': sslPort,
      'system': system,
      'is_disclaimer_enabled': isDisclaimerEnabled,
      'disclaimer_message': disclaimerMessage,
    };
  }

  // Getters
  String get getServer => server;
  int get getPort => port;
  int get getSslPort => sslPort;
  String get getSystem => system;
  bool get getIsDisclaimerEnabled => isDisclaimerEnabled;
  String get getDisclaimerMessage => disclaimerMessage;
  }

class SupportConfig {
  final String chatServer;
  final String supportId;
  final String whatsappNumber;
  final String tawkId;
  final String otherLinks;

  SupportConfig({
    this.chatServer = 'system',
    this.supportId = '1',
    this.whatsappNumber = '+1234567890',
    this.tawkId = '1',
    this.otherLinks = '',
  });

  factory SupportConfig.fromJson(Map<String, dynamic> json) {
    return SupportConfig(
      chatServer: json['chat_server'] ?? 'system',
      supportId: json['support_id'] ?? '1',
      whatsappNumber: json['whatsapp_number'] ?? '+1234567890',
      tawkId: json['tawk_id'] ?? '1',
      otherLinks: json['other_links'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_server': chatServer,
      'support_id': supportId,
      'whatsapp_number': whatsappNumber,
      'tawk_id': tawkId,
      'other_links': otherLinks,
    };
  }

  // Getters
  String get getChatServer => chatServer;
  String get getSupportId => supportId;
  String get getWhatsappNumber => whatsappNumber;
  String get getTawkId => tawkId;
  String get getOtherLinks => otherLinks;
}

class AppConfig {
  final String maintenanceMessage;
  final String maintenanceTitle;
  final String updateMessage;
  final String updateTitle;
  AppConfig({this.maintenanceMessage = '', this.maintenanceTitle = '', this.updateMessage = '', this.updateTitle = ''});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      maintenanceMessage: json['maintenance_message'] ?? '',
      maintenanceTitle: json['maintenance_title'] ?? '',
      updateMessage: json['update_message'] ?? '',
      updateTitle: json['update_title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maintenance_message': maintenanceMessage,
      'maintenance_title': maintenanceTitle,
      'update_message': updateMessage,
      'update_title': updateTitle,
    };
  }

  // Getters
  String get getMaintenanceMessage => maintenanceMessage;
  String get getMaintenanceTitle => maintenanceTitle;
  String get getUpdateMessage => updateMessage;
  String get getUpdateTitle => updateTitle;
}   