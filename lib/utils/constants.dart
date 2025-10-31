class Constants {
  static const double appVersion = 1.4; ///Flutter Version: 3.24.5
  static const String appBaseUrl = 'http://localhost';
  static const String baseUrl = '$appBaseUrl/';
  static const String googleApiKey = '';
  static const String geocodeUri = 'geocode-api';
  static const String paymentSuccessUrl = '$baseUrl/schedule-tour/payment/paid';
  static const String paymentPaidUrl = '${baseUrl}paid';

  static const String paymentFundingUrl = '$baseUrl/wallet/add-funds/paid';
  static const String paymentCancelUrl = '$baseUrl/payment/cancel';
  static const String paymentFailedUrl = '$baseUrl/payment/failed';
  static const String fontFamily = 'Roboto';

  static const String termsAndConditionUri = '/page/terms-and-conditions';
  static const String privacyPolicyUri = '/page/privacy-policy';
  static const String aboutUsUri = '/page/about-us';
  static const String shippingPolicyUri = '/page/shipping-policy';
  static const String cancellationUri = '/page/cancellation-policy';
  static const String refundUri = '/page/refund-policy';
  
  // static const String geocodeUri = 'https://maps.googleapis.com/maps/api/geocode/json';
  // ... other constants
} 
