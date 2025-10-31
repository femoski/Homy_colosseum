
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) {
    // if(response.statusCode == 401) {
    //   Get.find<AuthController>().clearSharedData(removeToken: false).then((value) {
    //     Get.find<FavouriteController>().removeFavourite();
    //     Get.offAllNamed(RouteHelper.getInitialRoute());
    //   });
    // }else {
    //   if(response.statusText != 'The guest id field is required.') {
    //     showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
    //   }
    // }
  }
}
