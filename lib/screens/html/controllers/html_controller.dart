import 'package:get/get.dart';

import '../../../repositories/html_repository.dart';
import '../../../utils/html_type.dart';

class HtmlController extends GetxController implements GetxService {
  final HtmlRepository htmlRepository = HtmlRepository();

  @override
  void onInit() {
    super.onInit();
    getHtmlText(Get.parameters['page'] == 'terms-and-condition' ? HtmlType.termsAndCondition
            : Get.parameters['page'] == 'privacy-policy' ? HtmlType.privacyPolicy
            : Get.parameters['page'] == 'shipping-policy' ? HtmlType.shippingPolicy
            : Get.parameters['page'] == 'cancellation-policy' ? HtmlType.cancellation
            : Get.parameters['page'] == 'refund-policy' ? HtmlType.refund : HtmlType.aboutUs);
  }

  String? _htmlText;
  String? get htmlText => _htmlText;
  bool isLoading = false;

  Future<void> getHtmlText(HtmlType htmlType) async {
    try {
      isLoading = true;
      update();
      
      _htmlText = null;
      final response = await htmlRepository.getHtmlText(htmlType);
      if (response != null) {
        if(response['content'] != null && response['content'].isNotEmpty && response['content'] is String){
          _htmlText = response['content'];
        }else{
          _htmlText = '';
        }
        if(_htmlText != null && _htmlText!.isNotEmpty) {
          _htmlText = _htmlText!.replaceAll('href=', 'target="_blank" href=');
        }else {
          _htmlText = '';
        }
      }
    } catch (e) {
      _htmlText = null;
    } finally {
      isLoading = false;
      update();
    }
  }

}