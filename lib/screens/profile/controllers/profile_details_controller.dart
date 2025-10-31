import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/utils/constants/text_strings.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDetailScreenController extends GetxController {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneOfficeController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController faxController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  UserData? userData;
  XFile? fileImage;
  String? networkImage;
  String? userType;
  int? selectedTypeIndex;
  List<String> hereFor = [
    'To Buy Property',
    'To Sell Property',
    'I Am A Broker',
    'We Are Agency',
  ];
  ImagePicker picker = ImagePicker();

  ProfileDetailScreenController();

  AuthService authService = Get.find<AuthService>();
  bool isLoading = false;
  UserRepository userRepository = UserRepository();
  @override
  void onReady() {
    getPrefData();
    super.onReady();
  }

  void getPrefData() async {
    CommonUI.loader();
    userData = authService.user.value;
    firstNameController = TextEditingController(text: userData?.firstName ?? '');
    lastNameController = TextEditingController(text: userData?.lastName ?? '');
    aboutController = TextEditingController(text: userData?.about ?? '');
    addressController = TextEditingController(text: userData?.address ?? '');
    phoneOfficeController = TextEditingController(text: userData?.phoneOffice ?? '');
    mobileController = TextEditingController(text: userData?.mobileNo ?? '');
    faxController = TextEditingController(text: userData?.fax ?? '');
    emailController = TextEditingController(text: userData?.email ?? '');
    userType = hereFor.elementAt(userData?.userType ?? 0);
    selectedTypeIndex = hereFor.indexOf(userType ?? '');
    update();
    Get.back();
  }

  void onTypeChange(value) {
    userType = value;
    selectedTypeIndex = hereFor.indexOf(value);
    update();
  }

  void onProfileClick() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: cMaxHeightImage,
        maxWidth: cMaxWidthImage,
        imageQuality: cQualityImage,
      );
      if (image == null) {
        return;
      } else {
        fileImage = image;
      }
      update();
    } catch (e) {
      CommonUI.snackBar(title: 'You Not Allow Photo Access');
    }
  }

  void onSubmitClick() async {
    if (firstNameController.text.trim().isEmpty) {
      return CommonUI.snackBar(title: 'Please Enter First Name');
    }
    if (lastNameController.text.trim().isEmpty) {
      return CommonUI.snackBar(title: 'Please Enter Last Name');
    }
    if (aboutController.text.trim().isEmpty) {
      return CommonUI.snackBar(title: 'Please Enter About Yourself');
    }

// Map<String, List<XFile>> filesMap = {
//   uProfile: [fileImage]
// };

try{
  isLoading = true;
  update();
Map<String, dynamic> userDataMap = {
  'about': aboutController.text.trim(),
  'address': addressController.text.trim(),
  'fax': faxController.text.trim(),
  'first_name': firstNameController.text.trim(),
  'last_name': lastNameController.text.trim(),
  'phone_number': mobileController.text.trim(),
  'phone_office': phoneOfficeController.text.trim(),
};

  Map<String, List<XFile>> filesMap = {};

        if (fileImage != null) {
          filesMap['avatar'] = [fileImage!];
        }

// Map<String, List<XFile>> filesMap = {
//   'avatar': [fileImage ?? {}]
// };

      final user = await userRepository.updateProfile(userDataMap, filesMap);
      authService.user.value = user;
      isLoading = false;

      Get.showSnackbar(CommonUI.SuccessSnackBar(message: 'Profile Updated'));
      update();
    } catch (e) {
      CommonUI.snackBar(title: e.toString());
      isLoading = false;
      update();
    }
  }
}
