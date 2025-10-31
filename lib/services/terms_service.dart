import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TermsService extends GetxService {
  final _storage = GetStorage();
  final String _termsAcceptedKey = 'terms_accepted';
  final RxBool hasAcceptedTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
    hasAcceptedTerms.value = _storage.read(_termsAcceptedKey) ?? false;
  }

  Future<void> acceptTerms() async {
    await _storage.write(_termsAcceptedKey, true);
    hasAcceptedTerms.value = true;
  }

  bool get isTermsAccepted => hasAcceptedTerms.value;
} 